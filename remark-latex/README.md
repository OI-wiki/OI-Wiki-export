# OI Wiki: Export to PDF

为 OI Wiki 的 LaTeX PDF 自动化导出工具开发的 Markdown 到 LaTeX 编译器。

## 使用方法

```js
const unified = require('unified')
const parse = require('remark-parse')
const latex = require('remark-latex')
const vfile = require('to-vfile')

unified()
	.use(parse) // 调用 remark 解析引擎
	.use(latex, { // 编译到 LaTeX
		prefix: filename.replace(prefixRegEx, "").replace(/md$/, ""), // 文件名（不含 md 后缀）
		depth: depth, // 指定 <h1> 对应标题深度（0, 1, 2 分别表示 \chapter, \section, \subsection），用于全书的结构组织
		current: filename, // 文件名（含 md 后缀）
		root: path.join(oiwikiRoot, 'docs'), // OI Wiki 的 docs 目录位置
		path: filename.replace(/\.md$/, "/") // 去掉 md 后的路径
	})
	.process(vfile.readSync(filename), function (err, file) {
		if (err) {
			throw err
		}
		file.dirname = 'tex'
		file.stem = filename.replace(prefixRegEx, "")
		file.extname = '.tex'
		vfile.writeSync(file)
	}) // 保存到文件（md 后缀换成 tex）
```

## 依赖

参见 `package.json`。

## 维护

编译器核心代码位于 `remark-latex/lib/compiler.js` 中，其中用到的某些函数位于 `remark-latex/lib/util.js`。remark 的所有种类 AST 结点都通过 `parse` 这一个函数处理。
