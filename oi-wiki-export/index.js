'use strict'

const unified = require('unified')
const parse = require('remark-parse')
const math = require('remark-math')
const details = require('remark-details')
const footnotes = require('remark-footnotes')
const typst = require('../remark-typst/index')
const fs = require('fs').promises
const vfile = require('to-vfile')
const path = require('path')
const yaml = require('js-yaml')
const escape = require('../remark-typst/escape-typst/src/index')
const child_process = require('child_process')
const snippet = require('./snippet')

const prefixRegEx = /[^a-zA-Z0-9]/ig
const history = new Array()

async function exists (file) {
  try {
    await fs.access(file)
  } catch (e) {
    return false
  }
  return true
}

async function main () {
  if (process.argv.length !== 3) {
    console.log('Usage: node ' + __filename.split('/').pop() + ' <oi-wiki-root>')
    process.exit()
  }

  const oiwikiRoot = process.argv[2] // OI Wiki 根目录
  const yamlFile = path.join(oiwikiRoot, 'mkdocs.yml') // YAML 配置文件

  console.log('[INFO] Processing snippets')

  await snippet.snippet(oiwikiRoot)

  console.log('[INFO] Checking for typ/ directory')

  try {
    await fs.mkdir('typ')
    await fs.mkdir('images')
  } catch (e) {

  }
  console.log('[INFO] Exporting OI Wiki from directory: ' + oiwikiRoot)

  if (!await exists(yamlFile)) {
    console.error('[ERROR] Error: config file \'mkdocs.yml\' does not exist')
    process.exit()
  }

  console.log('[INFO] Config file: ' + yamlFile)

  const yamlFileContent = await fs.readFile(yamlFile, 'utf8');

  // fix YAMLException: unknown tag
  const types = yamlFileContent
    .match(/!!python\/name:.*/g)
    .map(s => new yaml.Type(s.replace('!!', 'tag:yaml.org,2002:'), {
      kind: 'mapping',
      construct: function (data) {
        return data
      }
    }))
  const CONFIG_SCHEMA = yaml.Schema.create(types)

  const config = yaml.load(yamlFileContent, { schema: CONFIG_SCHEMA })
  const catalog = config.nav // 文档目录

  let includes = ''
  for (const id in catalog) {
    const texModule = path.join('typ', id.toString())
    await fs.writeFile(texModule + '.typ', await exportRecursive(catalog[id], 0))
    includes += '#include "' + texModule + '.typ"\n' // 输出 includes.typ 章节目录文件
  }

  await fs.writeFile('includes.typ', includes)
  console.log('[INFO] Export successful.')

  async function convertMarkdown (filename, depth, title) {
    if (!filename.endsWith('.md')) {
      console.error('Error: File \'' + filename + '\' is not a markdown file')
      process.exit()
    }

    if (!await exists(filename)) {
      console.error('Error: File \'' + filename + '\' does not exist')
      process.exit()
    }

    unified()
      .use(parse)
      .use(math)
      .use(details)
      .use(footnotes)
      .use(typst, {
        prefix: filename.replace(prefixRegEx, '').replace(/md$/, ''), // 根据路径生成 ID，用作 label
        depth: depth, // 标题 h1 深度
        current: filename, // 带 md 后缀的文件名
        root: path.join(oiwikiRoot, 'docs'), // docs/ 目录
        nested: false,
        forceLinebreak: false,
        path: filename.replace(/\.md$/, '/'), // 由文件名转换而来的路径
        title: title,
      })
      .process(await vfile.read(filename), function (err, file) {
        if (err) {
          throw err
        }
        file.dirname = 'typ'
        file.stem = filename.replace(prefixRegEx, '')
        file.extname = '.typ'
        vfile.writeSync(file)
      })
  }

  // 递归处理各个 chapter
  async function exportRecursive (object, depth) {
    let result = ''

    depth = Math.min(depth, 6)
    
    if (depth === 0) {
      result += '#pagebreak(to: "odd")\n'
    }
    if (depth === 1) {
      result += '#counter(footnote).update(0)\n'
    }
    
    for (const key in object) {
      console.log('[INFO] Exporting: ' + key)
      if (typeof object[key] === 'string') { // 对应页面
        await convertMarkdown(path.join(oiwikiRoot, 'docs', object[key]), depth + 1, object[key])

        const moduleName = escape(getTypstModuleName(object[key]))

        result += '{0} {1} <{2}>\n'.format(
          '='.repeat(depth + 1), 
          escape(key),
          moduleName.slice(0, moduleName.length - 2))

        result += '#include "' + moduleName + '.typ"\n'
      } else { // 对应子目录
        const dirName = getInnermostHeading(object[key], depth)

        if (depth === 0) {
          history.length = 0
          history.push(dirName)
          result += '= {0} <{1}>\n'.format(escape(key), dirName)
        } else if (history.includes(dirName)) {
          result += '{0} {1}\n'.format('='.repeat(depth + 1), escape(key))
        } else {
          history.push(dirName)
          result += '{0} {1} <{2}>\n'.format('='.repeat(depth + 1), escape(key), dirName)
        }

        for (const id in object[key]) {
          result += await exportRecursive(object[key][id], depth + 1)
        }
      }
    }

    return result
  }

  function getInnermostHeading (obj, depth) {  
    // console.log(obj)
    // console.log(depth)

    if (obj instanceof Array) {
      return getInnermostHeading(obj[0], depth)
    } 
    if (obj instanceof Object) {
      return getInnermostHeading(Object.values(obj)[0], depth - 1)
    }
    if (typeof obj === 'string') {
      let idx = obj.lastIndexOf('/')
      return getTypstModuleName(obj.slice(0, (idx === -1) ? obj.length : idx))
    }
    return ''
  }

  function getTypstModuleName (name) {
    return path.join(oiwikiRoot, 'docs', name).replace(prefixRegEx, '')
  }
}

main()
