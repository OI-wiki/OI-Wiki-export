'use strict'

const unified = require('unified')
const parse = require('remark-parse')
const math = require('remark-math')
const details = require('remark-details')
const footnotes = require('remark-footnotes')
const latex = require('./index')
const fs = require('fs')
const vfile = require('to-vfile')
const path = require('path')
const child_process = require('child_process')

const filename = './example.md'
const prefixRegEx = /[^a-zA-Z0-9]/ig

if (!fs.existsSync(filename)) {
  console.log('Error: File \'' + filename + '\' does not exist')
  process.exit()
}

try {
  fs.mkdirSync('images')
} catch (e) {}
unified()
  .use(parse)
  .use(math)
  .use(details)
  .use(footnotes)
  .use(latex, {
    prefix: filename.replace(prefixRegEx, '').replace(/md$/, ''),
    depth: 0,
    current: filename,
    root: path.join('./', 'docs'),
    nested: false,
    forceEscape: false,
    path: filename.replace(/\.md$/, '/').split('/').slice(0, -2).join('/')
  })
  .process(vfile.readSync(filename), function (err, file) {
    if (err) {
      throw err
    }
    file.extname = '.tex'
    vfile.writeSync(file)
  })
