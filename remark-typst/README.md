# OI Wiki: Export to PDF (WIP)

为 OI Wiki 的 Typst PDF 自动化导出工具开发的 Markdown 到 Typst 编译器。

**注意：本项目正在开发当中，请勿用于生产环境。**

## 使用方法

请使用下面的命令克隆本仓库：

```sh
git clone --recurse-submodules --remote-submodules https://github.com/OI-wiki/remark-typst.git
```

按如下方法使用：

```js
import { unified } from 'unified'
import remarkParse from 'remark-parse'
import remarkTypst from 'remark-typst'
import vfile from 'to-vfile'

unified()
	.use(remarkParse) // 调用 remark 解析引擎
	.use(remarkTypst, { // 编译到 Typst
		prefix: filename.replace(prefixRegEx, "").replace(/md$/, ""), // 文件名（不含 md 后缀）
		depth: depth, // 指定 <h1> 对应标题深度（0, 1, 2 分别表示一、二、三级标题），用于全书的结构组织
		current: filename, // 文件名（含 md 后缀）
		root: path.join(oiwikiRoot, 'docs'), // OI Wiki 的 docs 目录位置
		path: filename.replace(/\.md$/, "/") // 去掉 md 后的路径
	})
	.process(vfile.readSync(filename), function (err, file) {
		if (err) {
			throw err
		}
		file.dirname = 'typ'
		file.stem = filename.replace(prefixRegEx, "")
		file.extname = '.typ'
		vfile.writeSync(file)
	}) // 保存到文件（md 后缀换成 typ）
```

## 依赖

参见 `package.json`。

## 维护

编译器核心代码位于 `remark-typst/lib/compiler.js` 中，其中用到的某些函数位于 `remark-typst/lib/util.js`。remark 的所有种类 AST 结点都通过 `parse` 这一个函数处理。
