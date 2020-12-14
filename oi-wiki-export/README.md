# oi-wiki-export

OI Wiki 的 LaTeX PDF 自动化导出工具。

依赖 remark-latex。LaTeX 依赖包请参见 `oi-wiki-export.tex`。

## 使用方法

本工具（包括 remark-latex）暂未 release，目前需通过 node 命令行方式手动调用：

```bash
$ cd <oi-wiki-export 目录>
$ node index.js <OI Wiki 根目录>
```

执行完毕后，当前目录下会出现两个目录 `tex` 和 `images`，其中 `images` 保存所有图片，`tex` 保存所有 LaTeX 文件（每个 Markdown 源文件对应一个 TeX 文件，另外 OI Wiki 的每部分对应一个数字编号的 TeX 文件）。当前目录下会产生一个 `includes.tex` 文件，其中包含了 `tex` 中的所有文件。

即，文件树格式如下：

```plain
<当前路径>
	-> includes.tex
	-> images
		-> 所有图片
	-> tex
		-> 数字.tex
		-> 每个 Markdown 源文件对应的 TeX 文件
```

而这些 TeX 文件之间的包含关系如下：

```plain
includes.tex
	-> 数字.tex
		-> 该章/部分下的每一个 TeX 文件
```

## 模板文件 `oi-wiki-export.tex`

`oi-wiki-export.tex` 是调用了上面产生的这些 LaTeX 文档的 TeX 文件，编译它即可得到 OI Wiki 的 PDF。由于 OI Wiki 的内容包含中文、英文，以及少量的日文、俄文等，文字构成复杂，建议使用 XeLaTeX 编译。依赖包可直接查看 `oi-wiki-export.tex`。若使用最新版本的 TeX Live，应当不会出现依赖问题。

提供的 `oi-wiki-export.tex` 分别使用 STIX Two 系列字体及思源宋体作为西文（含数学公式）和 CJK 的字体。另外，由于 STIX Two Math 数学字体没有 Bold 字重，我们用 XITS Math 取代。STIX 和 XITS 字体应为 TeX Live 自带，思源宋体需要自己安装。

如有需要，也可以改为使用其他字体，但由于文字种类较多，建议使用 Unicode 支持比较完整（区域覆盖比较完全）的字体，否则可能出现俄文不显示、日文乱码等问题。这部分问题主要容易在《2.2.1 OI 赛事与赛制》一节中出现，可以重点检查。

## `index.js`

解析 OI Wiki 的 YAML 配置文件，找到 Markdown 文档，交由 remark-latex 解析。
