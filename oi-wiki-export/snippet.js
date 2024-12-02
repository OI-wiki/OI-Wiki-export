import glob from "tiny-glob";
import { promises as fs } from "fs";
import { resolve } from "path";
const SNIPPET_TOKEN = "--8<-- ";

let oi_wiki_root = ".";

function resolvePath(snip, spacesAtStart) {
  const str = snip.substring(SNIPPET_TOKEN.length + spacesAtStart);
  let res = { "path": str, "beg_line": undefined, "end_line": undefined };
  if (
    (str.startsWith('"') && str.endsWith('"')) ||
    (str.startsWith("'") && str.endsWith("'"))
  ) {
    const strs = str.substring(1, str.length - 1).split(":");
    res.path = strs[0];
    if (strs.length == 3) {
      res.beg_line = Number(strs[1]) - 1;
      res.end_line = Number(strs[2]);
    } else if (strs.length != 1) {
      console.error("cannot parse snippet:", snip);
    }
  } else {
    console.error("cannot parse snippet:", snip);
  }
  res.path = resolve(oi_wiki_root, res.path);
  return res;
}

async function process_snippet(file) {
  const content = await fs.readFile(file, "utf8");
  const res = (
    await Promise.all(
      content.split("\n").map(async (line) => {
        const spacesAtStart = line.length - line.trimLeft().length;
        const spaceString = " ".repeat(spacesAtStart);
        if (line.trim().startsWith(SNIPPET_TOKEN)) {
          const res = resolvePath(line, spacesAtStart);
          line = await fs.readFile(res.path, "utf8");
          line = line
            .split("\n")
            .slice(res.beg_line, res.end_line)
            .map((l) => spaceString + l)
            .join("\n");
        }
        return line;
      })
    )
  ).join("\n");
  await fs.writeFile(file, res);
}

export async function snippet(root) {
  oi_wiki_root = root;
  const files = await glob(`${resolve(root)}/**/*.md`);
  await Promise.all(files.map(process_snippet));
}
