'use strict'

const compiler = require('./lib/compiler')

module.exports = typst

function typst (options) {
  this.Compiler = compiler(options || {})
}
