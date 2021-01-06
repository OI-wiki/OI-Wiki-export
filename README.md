# OI-Wiki-export

将 OI-Wiki 导出为印刷质量的 pdf 的工具。

## 导出

我们建议在 Linux 环境下进行导出操作。

首先请安装好以下软件包：

- TeXLive
- NodeJS
- imagemagick
- libwebp
- librsvg
- pygments

所需字体：

- Fandol 系列中文字体（包括 FandolSong, FandolHei, FandolKai）
- Roboto Mono
- Computer Modern Unicode 系列字体（包括 CMU Serif 和 CMU Sans Serif）

然后安装所需依赖：

```
cd oi-wiki-export
npm install
```
然后运行导出脚本，将 OI-Wiki 源文件转换为 LaTeX 格式：

```
node index.js path/to/OI-wiki/repo
```

然后使用 latexmk 编译导出后得到的 tex 文档

```
latexmk -shell-escape -xelatex oi-wiki-export.tex
```

最终得到的 oi-wiki-export.pdf 即为结果。

## 故障排除

- 在导出过程中可能会存在部分图片导出不成功的问题，目前尚未解决

## 注意

在使用导出得到的 pdf 时，应当注意 OI-wiki 的 LICENSE。
