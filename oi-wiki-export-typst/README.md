# oi-wiki-export-typst

OI Wiki 的 Typst PDF 自动化导出工具。

## 依赖

Typst 版本不低于 0.8.0。

Markdown 源文档到 Typst 的转换通过 [remark-typst](https://github.com/OI-wiki/remark-typst) 完成。

TeX 公式到 Typst 的转换通过 [mitex](https://github.com/orangex4/mitex)完成。

二维码的生成通过 [typst-qrcode-wasm](https://github.com/megakite/typst-qrcode-wasm) 插件完成；插件的二进制文件已包含在根目录当中。

## 使用方法

本工具（包括 remark-typst）暂未 release，目前需通过 node 命令行方式手动调用：

```bash
node index.js <OI Wiki 根目录>
```

执行完毕后，当前目录下会产生两个目录：`typ` 和 `images`，其中 `images` 保存所有图片，`typ` 保存所有 Typst 文件（每个 Markdown 源文件对应一个 Typst 文件，另外 OI Wiki 的每个章节对应一个数字编号的 Typst 文件）。

当前目录下还会产生一个 `includes.typ` 文件，其中包含了 `typ` 中的所有文件。

即，文件树格式如下：

```plain
.
├── images
│   └── <图片>
├── typ
│   ├── <章节的数字编号>.typ
│   └── <对应的 Markdown 源文件>.typ
├── includes.typ
└── ...
```

各文件之间的包含关系如下：

```plain
includes.typ
    -> <章节的数字编号>.typ
        -> <该章节下对应的 Markdown 源文件>.typ
            -> <正文中的图片>
```

## 各 Typst 文件简介

### [oi-wiki-export.typ](./oi-wiki-export.typ)

模板文件。它调用了上面产生的这些 Typst 文档，编译它即可得到 OI Wiki 的 PDF。

### [oi-wiki.typ](./oi-wiki.typ)

包含了为 OI Wiki 内容编写的定制元素和工具函数。

### [pymdownx-details.typ](./pymdownx-details.typ)

提供了类似主站风格的 Details 块支持。

## 已知问题

- 尚未支持 Tabbed 环境。
- Details 块下的标题和正文直接可能会出现换页。
- SVG 中出现的 CJK 字符无法 fallback 到正确的字体。
