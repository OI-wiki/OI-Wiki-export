# OI-Wiki-export

将 OI-Wiki 导出为印刷质量的 pdf 的工具。

## 下载

可在 [GitHub Release](https://github.com/OI-wiki/OI-Wiki-export/releases) 中下载每周定期自动构建的 pdf 文件.

## 导出

我们建议在 Linux 环境下进行导出操作。

### LaTeX 版本

首先请安装好以下软件包：

- TeXLive
- NodeJS
- imagemagick
- libwebp
- librsvg
- pygments
- inkscape

所需字体：

- Roboto Mono
- Noto 系列字体（包括 Noto Sans, Noto Serif, Noto Sans CJK SC, Noto Serif CJK SC）
- CM Unicode 字体

然后安装所需依赖，因为modules之间存在依赖关系，请严格按照顺序执行命令，否则可能会产生版本冲突：

```
cd remark-snippet
npm install
cd ..
cd remark-latex
npm install
cd ..
cd oi-wiki-export
npm install
```
然后运行导出脚本，将 OI-Wiki 源文件转换为 LaTeX 格式：

```
node index.js path/to/OI-wiki/repo
```

然后使用 latexmk 编译导出后得到的 tex 文档

```
latexmk -shell-escape -8bit -xelatex oi-wiki-export.tex
```

最终得到的 oi-wiki-export.pdf 即为结果。

### Typst 版本

首先请安装好以下软件包：

- Typst (0.8.0+)
- NodeJS (16+)
- imagemagick
- libwebp
- librsvg

所需字体：

- Noto CJK 系列字体（包括 Noto Sans CJK SC 和 Noto Serif CJK SC）
- 霞鹜文楷（[LXGW WenKai](https://github.com/lxgw/LxgwWenKai)）

然后安装所需依赖，因为modules之间存在依赖关系，请严格按照顺序执行命令，否则可能会产生版本冲突：

```sh
cd remark-snippet
npm install
cd ..
cd remark-typst
npm install
cd ..
cd oi-wiki-export-typst
npm install
```

运行导出脚本，将 OI-Wiki 源文件转换为 Typst 格式：

```sh
node index.js path/to/OI-wiki/repo
```

使用 Typst 编译导出后得到的 typ 文档

```sh
typst compile oi-wiki-export.typ
```

最终得到的 oi-wiki-export.pdf 即为结果。

## 故障排除

- 在导出过程中可能会存在部分图片导出不成功的问题，目前尚未解决

## 注意

在使用导出得到的 pdf 时，应当注意 OI-wiki 的 LICENSE。
