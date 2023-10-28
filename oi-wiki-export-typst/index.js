'use strict'

import { join } from 'path'
import { promises as fs } from 'fs'

import { unified } from 'unified'
import remarkParse from 'remark-parse'
import remarkMath from 'remark-math'
import remarkDetails from 'remark-details'
import remarkGfm from 'remark-gfm'
import remarkTabbed from 'remark-tabbed'
import { read, writeSync } from 'to-vfile'
import { Type, Schema, load } from 'js-yaml'

import { snippet as _snippet } from './snippet.js'
import remarkTypst from '../remark-typst/index.js'
import escape from '../remark-typst/escape-typst/src/index.js'
// import remarkTabbed from '../remark-tabbed/lib/index.js'

const PREFIX_REGEX = /[^a-zA-Z0-9]/ig

const INFO = "\x1b[1;32m[INFO]\x1b[0m "
const ERROR = "\x1b[1;31m[ERROR]\x1b[0m "

// Traversed non-page labels.
// Used to avoid multiple label definition, which typst will
// consider to be an error.
const labelHistory = new Array()

async function exists(file) {
  try {
    await fs.access(file)
  } catch (e) {
    return false
  }
  return true
}

async function main() {
  if (process.argv.length !== 3) {
    console.log('Usage: node ' + __filename.split('/').pop() + ' <oi-wiki-root>')
    process.exit()
  }

  const oiwikiRoot = process.argv[2] // OI Wiki 根目录
  const yamlFile = join(oiwikiRoot, 'mkdocs.yml') // YAML 配置文件

  console.log(INFO + 'Processing snippets')

  await _snippet(oiwikiRoot)

  console.log(INFO + 'Checking for typ/ directory')

  try {
    await fs.mkdir('typ')
    await fs.mkdir('images')
  } catch (e) {}
  console.log(INFO + 'Exporting OI Wiki from directory: ' + oiwikiRoot)

  if (!await exists(yamlFile)) {
    console.error(ERROR + 'Config file \'mkdocs.yml\' does not exist')
    process.exit()
  }

  console.log(INFO + 'Config file: ' + yamlFile)

  const yamlFileContent = await fs.readFile(yamlFile, 'utf8');

  // fix YAMLException: unknown tag
  const types = yamlFileContent
    .match(/!!python\/name:.*/g)
    .map(s => new Type(s.replace('!!', 'tag:yaml.org,2002:'), {
      kind: 'mapping',
      construct: function (data) {
        return data
      }
    }))
  const configSchema = new Schema(types)

  const config = load(yamlFileContent, { schema: configSchema })
  const catalog = config.nav // 文档目录

  let includes = ''
  const exportPromises = []
  for (const id in catalog) {
    const texModule = join('typ', id.toString())
    await fs.writeFile(texModule + '.typ', exportRecursive(catalog[id], 0))
    includes += '#include "' + texModule + '.typ"\n' // 输出 includes.typ 章节目录文件
  }
  await Promise.all(exportPromises)

  await fs.writeFile('includes.typ', includes)
  console.log(INFO + 'Export successful.')

  async function convertMarkdown(filename, depth, title) {
    if (!filename.endsWith('.md')) {
      console.error(ERROR + 'File \'' + filename + '\' is not a markdown file')
      process.exit(1)
    }

    if (!await exists(filename)) {
      console.error(ERROR + 'File \'' + filename + '\' does not exist')
      process.exit(1)
    }

    unified()
      .use(remarkParse)
      .use(remarkMath)
      .use(remarkGfm)
      .use(remarkDetails)
      .use(remarkTabbed)
      // .use(remarkTabbed)
      .use(remarkTypst, {
        prefix: filename.replace(PREFIX_REGEX, '').replace(/md$/, ''), // 根据路径生成 ID，用作 label
        depth: depth, // 标题 h1 深度
        current: filename, // 带 md 后缀的文件名
        root: join(oiwikiRoot, 'docs'), // docs/ 目录
        nested: false,
        forceLinebreak: false,
        path: filename.replace(/\.md$/, '/'), // 由文件名转换而来的路径
        title: title,
      })
      .process(await read(filename), (err, file) => {
        if (err) {
          throw err
        }
        file.dirname = 'typ'
        file.stem = filename.replace(PREFIX_REGEX, '')
        file.extname = '.typ'
        writeSync(file)
      })
  }

  // 递归处理各个 chapter
  function exportRecursive(object, depth) {
    let result = ''
    depth = Math.min(depth, 6)

    for (const key in object) {
      console.log(INFO + 'Exporting: ' + key)

      if (typeof object[key] === 'string') { // 对应页面
        const convert_promise = convertMarkdown(join(oiwikiRoot, 'docs', object[key]), depth + 1, object[key])
        exportPromises.push(convert_promise)

        const moduleName = escape(getModuleName(object[key]))
        result += '{0} {1} <{2}>\n'.format(
          '='.repeat(depth + 1), 
          escape(key),
          moduleName.slice(0, moduleName.length - 2))

        result += '#include "' + moduleName + '.typ"\n'
      } else { // 对应子目录
        const dirName = getLabel(object[key])

        if (labelHistory.includes(dirName)) {
          result += '{0} {1}\n'.format('='.repeat(depth + 1), escape(key))
        } else {
          labelHistory.push(dirName)
          result += '{0} {1} <{2}>\n'.format('='.repeat(depth + 1), escape(key), dirName)
        }

        for (const id in object[key]) {
          result += exportRecursive(object[key][id], depth + 1)
        }
      }
    }

    return result
  }

  function getLabel(obj) {  
    if (obj instanceof Array) {
      let idx = 0
      let label = ''
      while (true) {
        label = getLabel(obj[idx])
        if (label !== '')
          break

        ++idx
      }
      return label
    }

    if (obj instanceof Object) {
      return getLabel(Object.values(obj)[0])
    }
    
    if (typeof obj === 'string') {
      const idx = obj.lastIndexOf('/')
      return (idx !== -1) ? getModuleName(obj.slice(0, idx)) : ''
    }
    
    /* otherwise */ return ''
  }

  function getModuleName(name) {
    return join(oiwikiRoot, 'docs', name).replace(PREFIX_REGEX, '')
  }
}

main()
