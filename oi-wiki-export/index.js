'use strict'

const unified = require('unified')
const parse = require('remark-parse')
const math = require('remark-math')
const details = require('remark-details')
const footnotes = require('remark-footnotes')
const latex = require('remark-latex')
const fs = require('fs')
const vfile = require('to-vfile')
const path = require('path')
const yaml = require('js-yaml')
const escape = require('escape-latex')
const child_process = require('child_process')

const prefixRegEx = /[^a-zA-Z0-9]/ig

function convertMarkdown(filename, depth) {
	if (!filename.endsWith('.md')) {
		console.log('Error: File \'' + filename + '\' is not a markdown file')
		process.exit()
	}

	if (!fs.existsSync(filename)) {
		console.log('Error: File \'' + filename + '\' does not exist')
		process.exit()
	}

	unified()
		.use(parse)
		.use(math)
		.use(details)
		.use(footnotes)
		.use(latex, {
			prefix: filename.replace(prefixRegEx, "").replace(/md$/, ""), // 根据路径生成 ID，用作 LaTeX label
			depth: depth, // 标题 h1 深度
			current: filename, // 带 md 后缀的文件名
			root: path.join(oiwikiRoot, 'docs'), // docs/ 目录
			nested: false,
			forceEscape: false,
			path: filename.replace(/\.md$/, "/") // 由文件名转换而来的路径
		})
		.process(vfile.readSync(filename), function (err, file) {
			if (err) {
				throw err
			}
			file.dirname = 'tex'
			file.stem = filename.replace(prefixRegEx, "")
			file.extname = '.tex'
			vfile.writeSync(file)
		})
}

if (process.argv.length != 3) {
	console.log('Usage: node ' + __filename.split('/').pop() + ' <oi-wiki-root>')
	process.exit()
}

const oiwikiRoot = process.argv[2] // OI Wiki 根目录
const yamlFile = path.join(oiwikiRoot, 'mkdocs.yml') // YAML 配置文件

console.log('Checking for tex/ directory')
child_process.execSync('mkdir -p tex')
child_process.execSync('mkdir -p images')

console.log('Exporting OI Wiki from directory: ' + oiwikiRoot)

if (!fs.existsSync(yamlFile)) {
	console.log('Error: config file \'mkdocs.yml\' does not exist')
	process.exit()
}

console.log('Config file: ' + yamlFile)

// 处理 OI Wiki 目前使用的两种特殊 YAML type
const ConfigYamlType1 = new yaml.Type('tag:yaml.org,2002:python/name:pymdownx.emoji.to_svg', {
	kind: 'mapping',
	construct: function (data) {
		return data
	}
})
const ConfigYamlType2 = new yaml.Type('tag:yaml.org,2002:python/name:pymdownx.arithmatex.fence_mathjax_format', {
	kind: 'mapping',
	construct: function (data) {
		return data
	}
})
const CONFIG_SCHEMA = yaml.Schema.create([ConfigYamlType1, ConfigYamlType2])

const config = yaml.load(fs.readFileSync(yamlFile, 'utf8'), { schema: CONFIG_SCHEMA })
const catalog = config.nav // 文档目录

let includes = ''
for (const id in catalog) {
	const texModule = path.join('tex', id.toString())
	fs.writeFileSync(texModule + '.tex', exportRecursive(catalog[id], 0))
	includes += '\\input{' + texModule + '}\n' // 输出 includes.tex 章节目录文件
}

fs.writeFileSync('includes.tex', includes)
console.log('Complete')

// 递归处理各个 chapter
function exportRecursive(object, depth) {
	const block = ['chapter', 'section', 'subsection', 'subsubsection', 'paragraph', 'subparagraph'] // 各层次对应的 TeX 命令
	let result = ''
	depth = Math.min(depth, block.length)
	for (const key in object) {
		console.log('Exporting: ' + key)
		result += '\\' + block[depth] + '{' + escape(key) + '}\n'
		if (typeof object[key] == "string") { // 对应页面
			convertMarkdown(path.join(oiwikiRoot, 'docs', object[key]), depth + 1)
			result += '\\input{' + escape(getTexModuleName(object[key])) + '}\n'
		} else { // 对应子目录
			for (const id in object[key]) {
				result += exportRecursive(object[key][id], depth + 1)
			}
		}
	}
	return result
}

function getTexModuleName(name) {
	return path.join('tex', path.join(oiwikiRoot, 'docs', name).replace(prefixRegEx, ""))
}
