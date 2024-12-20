'use strict'

import { join } from 'path'

export function all(node, handler) {
  return node.children.map(handler)
}

export function trailingLineFeed(text) {
  return text[text.length - 1] === '\n' ? text : text + '\n'
}

export function getTextEstimatedLength(text) {
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
}

export function escapeAsString(text) {
  return text.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n')
}

export function isInternalLink(url) {
  return (url.toLowerCase().endsWith('.md')
       || url.startsWith('/')
       || url.startsWith('.')
       || url.search('#') !== -1)
    && !url.startsWith('http://')
    && !url.startsWith('https://')
}

export function toPrefix(text) {
  return text.replace(/[^a-zA-Z0-9]/ig, '').replace(/md$/, '')
}

export function joinRelative(url, options) {
  // Remove suffix
  if (url.indexOf('?') !== -1) {
    url = url.slice(0, url.indexOf('?'))
  }
  if (url.indexOf('#') !== -1) {
    url = url.slice(0, url.indexOf('#'))
  }

  // Join directories
  const isFolder = url.slice(url.lastIndexOf('.')).includes('/')
  if (url.startsWith('/')) {
    return join(options.root, url.slice(1))
  } else if (isFolder) {
    return join(options.path, url)
  } else if (url.startsWith('..') && !url.endsWith('md')) {
    return join(options.path, url.replace(/^\.\.\//, '../../'))
  } else if (url.startsWith('.') && !url.endsWith('md')) {
    return join(options.path, url.replace(/^\.\//, '../'))
  } else {
    return join(options.path.split('/').slice(0, -2).join('/'), url)
  }
}

export function forceLinebreak(text) {
  const zwsp = '\u200b'
  return text.split('').map(char => (this.isCjk(char) ? char : (zwsp + char + zwsp))).join('').replace(zwsp + zwsp, zwsp)
}

export function isCjk(char) {
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
}

export function isUrl(str) {
  return /^https?:\/\//.test(str)
}

export function checkCodeLang(lang) {
  if (!lang) { // 默认当作 text
    return 'txt'
  } else if (lang === 'plain') { // plain 替换为 text（纯文本）
    return 'txt'
  } else if (lang === 'markdown') { // markdown 格式的说明符必须是 md，需要替换
    return 'md'
  } else {
    return lang
  }
}

export function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function unquote(str) {
  if (str.startsWith('\\"') && str.endsWith('\\"')) {
    return str.slice(2, -2)
  } else {
    return str
  }
}
