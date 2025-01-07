'use strict'

import toTypst from './lib/compiler.js'

export default remarkTypst

function remarkTypst(options) {
  const self = this

  self.Compiler = compiler

  function compiler(doc) {
    return toTypst(doc, {
      ...self.data('settings'),
      ...options,
      extensions: self.data('toTypstExtensions') || [],
    })
  }
}
