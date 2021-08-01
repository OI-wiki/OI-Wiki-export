'use strict'

const escape = require('escape-latex')
const path = require('path')

module.exports = {
  // 对 node 的所有子结点执行 map(handler)
  all: function (node, handler) {
    return node.children.map(handler)
  },

  // 去除结尾换行
  trailingLineFeed: function (text) {
    return text[text.length - 1] === '\n' ? text : text + '\n'
  },

  // 不以 \par 开头
  nonParagraphBegin: function (text) {
    if (text.startsWith('\\par')) {
      return text.slice(4)
    }
    return text
  },

  // 粗略计算 text 字符串占用的长度，magic number 可以随便改
  getTextEstimatedLength: function (text) {
    let byteSize = 0
    for (let i = 0; i < text.length; ++i) {
      const charCode = text.charCodeAt(i)
      if (charCode >= 0 && charCode <= 0x7f) {
        byteSize += 1
      } else if (charCode >= 128 && charCode <= 0x7ff) {
        byteSize += 2
      } else {
        byteSize += 3
      }
    }
    return byteSize
  },

  // 处理 MathJax \text 系列命令中的文本转义
  // commands - 要转义的命令 (text, textit, textbf)
  escapeTextCommand: function (commands, text) {
    for (const id in commands) {
      const cmd = commands[id]
      const regex = new RegExp('\\\\' + cmd + '\\s*\\{')
      const ntext = text.replace(regex, '\\' + cmd + '{')
      if (ntext.indexOf('\\' + cmd + '{') === -1) {
        continue
      }
      const pos = ntext.indexOf('\\' + cmd + '{') + cmd.length + 2
      let p2 = pos; let depth = 1
      while (p2 < ntext.length) {
        if (ntext[p2] === '}') {
          --depth
          if (depth === 0) {
            break
          }
        } else if (ntext[p2] === '{') {
          ++depth
        }
        ++p2
      }
      if (p2 === ntext.length) {
        continue
      } else {
        const rep = ntext.slice(pos, p2)
        return ntext.slice(0, pos) + escape(rep) + this.escapeTextCommand(commands, ntext.slice(p2))
      }
    }
    return text
  },

  // 判断内链
  isInternalLink: function (url) {
    return (url.toLowerCase().endsWith('.md') || url.startsWith('/') || url.startsWith('.') || url.search('#') !== -1) && !url.startsWith('http://') && !url.startsWith('https://')
  },

  // 生成前缀（用作 LaTeX label）
  toPrefix: function (text) {
    return text.replace(/[^a-zA-Z0-9]/ig, '').replace(/md$/, '')
  },

  // 在 URL 后面拼接相对路径（去除 ? 和 # 后面的参数）
  joinRelative: function (dir, options) {
    if (dir.indexOf('?') !== -1) {
      dir = dir.slice(0, dir.indexOf('?'))
    }
    if (dir.indexOf('#') !== -1) {
      dir = dir.slice(0, dir.indexOf('#'))
    }
    if (dir.startsWith('/')) {
      return path.join(options.root, dir.slice(1))
    } else if (dir.startsWith('.') && !dir.endsWith('md')) {
      return path.join(options.path, dir.replace(/^\.\//, '../'))
    } else {
      return path.join(options.path.split('/').slice(0, -2).join('/'), dir)
    }
  },

  // 强制 LaTeX 在每个字符后都可换行（方式是在每个非 CJK 字符之间插入零宽间隔字符 Zero-Width Space）
  forceLinebreak: function (text) {
    const zwsp = '\u200b'
    return text.split('').map(char => (this.isCjk(char) ? char : (zwsp + char + zwsp))).join('').replace(zwsp + zwsp, zwsp)
  },

  // 判断所给字符是否是 CJK 统一表意文字（假名、谚文等不算）
  // 码位区段摘自 Unicode 13.0 Specification
  // 多数情况会落在 0x4e00..0x9fff，其他字符极罕见（但万一哪天真就用到了呢；而且这个对性能影响很小）
  isCjk: function (char) {
    const code = char.charCodeAt(0)
    if (code >= 0x4e00 && code <= 0x9fff) { // CJK 统一表意文字 (CJK Unified Ideographs)
      return true
    } else if (code >= 0x3400 && code <= 0x4dbf) { // CJK 统一表意文字扩展 A 区 (Ext A)
      return true
    } else if (code >= 0x20000 && code <= 0x2a6df) { // Ext B
      return true
    } else if (code >= 0x2a700 && code <= 0x2b81f) { // Ext C & D
      return true
    } else if (code >= 0x2b820 && code <= 0x2ebef) { // Ext E & F
      return true
    } else if (code >= 0x30000 && code <= 0x3134f) { // Ext G
      return true
    } else if (code >= 0xf000 && code <= 0xfaff) { // CJK 兼容表意文字 (CJK Compatibility Ideographs)
      return true
    } else if (code >= 0x2f800 && code <= 0x2fa1f) { // CJK 表意文字补充 (Supplement)
      return true
    } else {
      return false
    }
  },

  // 判断网页链接
  isUrl: function (str) {
    return /^https?:\/\//.test(str)
  }
}
