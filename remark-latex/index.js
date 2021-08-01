'use strict'

const compiler = require('./lib/compiler')

module.exports = latex

function latex (options) {
  this.Compiler = compiler(options || {})
}
