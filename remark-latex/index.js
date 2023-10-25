'use strict'

import compiler from "./lib/compiler.js"

export function latex (options) {
  this.Compiler = compiler(options || {})
}
