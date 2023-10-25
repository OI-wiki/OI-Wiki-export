"use strict";

import { unified } from "unified";
import remarkParse from "remark-parse";
import remarkMath from "remark-math";
import remarkDetails from "remark-details";
import remarkGfm from "remark-gfm";
import { latex } from "remark-latex";
import remarkFootnotes from "remark-footnotes";
import { read, writeSync } from "to-vfile";
import { Type, Schema, load } from "js-yaml";
import { join } from "path";
import { promises as fs } from "fs";
import { snippet } from "./snippet.js";
import remarkTabbed from "remark-tabbed";
import escape from "escape-latex";

const prefixRegEx = /[^a-zA-Z0-9]/gi;

async function exists(file) {
  try {
    await fs.access(file);
  } catch (e) {
    return false;
  }
  return true;
}

async function main() {
  if (process.argv.length !== 3) {
    console.log(
      "Usage: node " + __filename.split("/").pop() + " <oi-wiki-root>"
    );
    process.exit();
  }

  const oiwikiRoot = process.argv[2]; // OI Wiki 根目录
  const yamlFile = join(oiwikiRoot, "mkdocs.yml"); // YAML 配置文件

  console.log("Processing snippets");

  await snippet(oiwikiRoot);

  console.log("Checking for tex/ directory");

  try {
    await fs.mkdir("tex");
    await fs.mkdir("images");
  } catch (e) {}
  console.log("[Info] Exporting OI Wiki from directory: " + oiwikiRoot);

  if (!(await exists(yamlFile))) {
    console.log("Error: config file 'mkdocs.yml' does not exist");
    process.exit();
  }

  console.log("Config file: " + yamlFile);

  const yamlFileContent = await fs.readFile(yamlFile, "utf8");

  // fix YAMLException: unknown tag
  const types = yamlFileContent.match(/!!python\/name:.*/g).map(
    (s) =>
      new Type(s.replace("!!", "tag:yaml.org,2002:"), {
        kind: "mapping",
        construct: function (data) {
          return data;
        },
      })
  );
  const CONFIG_SCHEMA = new Schema(types);

  const config = load(yamlFileContent, { schema: CONFIG_SCHEMA });
  const catalog = config.nav; // 文档目录

  let includes = "";
  for (const id in catalog) {
    const texModule = join("tex", id.toString());
    await fs.writeFile(
      texModule + ".tex",
      await exportRecursive(catalog[id], 0)
    );
    includes += "\\input{" + texModule + "}\n"; // 输出 includes.tex 章节目录文件
  }

  await fs.writeFile("includes.tex", includes);
  console.log("Complete");

  async function convertMarkdown(filename, depth) {
    if (!filename.endsWith(".md")) {
      console.log("Error: File '" + filename + "' is not a markdown file");
      process.exit();
    }

    if (!(await exists(filename))) {
      console.log("Error: File '" + filename + "' does not exist");
      process.exit();
    }

    unified()
      .use(remarkParse)
      .use(remarkMath)
      .use(remarkGfm)
      .use(remarkDetails)
      .use(remarkTabbed)
      .use(remarkFootnotes)
      .use(latex, {
        prefix: filename.replace(prefixRegEx, "").replace(/md$/, ""), // 根据路径生成 ID，用作 LaTeX label
        depth: depth, // 标题 h1 深度
        current: filename, // 带 md 后缀的文件名
        root: join(oiwikiRoot, "docs"), // docs/ 目录
        nested: false,
        forceEscape: false,
        path: filename.replace(/\.md$/, "/"), // 由文件名转换而来的路径
      })
      .process(await read(filename), function (err, file) {
        if (err) {
          throw err;
        }
        file.dirname = "tex";
        file.stem = filename.replace(prefixRegEx, "");
        file.extname = ".tex";
        writeSync(file);
      });
  }

  // 递归处理各个 chapter
  async function exportRecursive(object, depth) {
    const block = [
      "chapter",
      "section",
      "subsection",
      "subsubsection",
      "paragraph",
      "subparagraph",
    ]; // 各层次对应的 TeX 命令
    let result = "";
    depth = Math.min(depth, block.length);
    for (const key in object) {
      console.log("[Info] Exporting: " + key);
      result += "\\" + block[depth] + "{" + escape(key) + "}\n";
      if (typeof object[key] === "string") {
        // 对应页面
        await convertMarkdown(
          join(oiwikiRoot, "docs", object[key]),
          depth + 1
        );
        result += "\\input{" + escape(getTexModuleName(object[key])) + "}\n";
      } else {
        // 对应子目录
        for (const id in object[key]) {
          result += await exportRecursive(object[key][id], depth + 1);
        }
      }
    }
    return result;
  }

  function getTexModuleName(name) {
    return join(
      "tex",
      join(oiwikiRoot, "docs", name).replace(prefixRegEx, "")
    );
  }
}

main();
