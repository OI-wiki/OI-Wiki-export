# remark-snippet

将 **OI Wiki** 的 md 格式源文件中的 snippet 行转换为相应的代码行。

## 预期行为

仅实现了 [原网页](https://facelessuser.github.io/pymdown-extensions/extensions/snippets/) 的如下功能：

-   插入整个文件，如 `--8<-- a.cpp`；
-   插入某行至某行的文件，如 `--8<-- a.cpp:3:4`；
    -   支持首尾行号为空，不支持零或负数行号、多段行号等扩展；
-   插入文件中的指定段，如 `--8<-- a.cpp:section-name`；
    -   要求相应代码文件中，段首和段尾分别用含有 `--8<-- [start:section-name]` 和 `--8<-- [end:section-name]` 字样的注释行标记；
    -   如果第一次读到的是段首，就插入段首至第一个段尾；若段尾缺失，就插入至文章结尾；
    -   如果第一次读到的是段尾，就不插入任何内容；
    -   插入代码文件时，移除所有含有 `--8<-- ` 字段的行。

## 依赖

仅依赖 `tiny-grob` 包。

## 使用方法

按照如下方法调用，可以将 `root` 目录下的 `.md` 文件中的 snippet 行全部替换为相应的代码文件。

```js
import snippet from '../remark-snippet/index.js'

snippet(root)
```

## 异常信息

如果 snippet 字段不合法，会抛出 `SyntaxError` 异常。

## 维护信息

有两个文件：

-   `parser.js`: 具体的解析逻辑，用于替换单个 `.md` 文件中的 snippet 行；
-   `index.js`: 用于替换整个目录下所有 `.md` 文件中的 snippet 行。

`test` 目录下有两个测试文件：

-   `line-parsing.test.js`: 测试形如 `a.cpp:2:3` 的字符串的解析；
-   `injection.test.js`: 测试将代码文件插入文档的效果。
