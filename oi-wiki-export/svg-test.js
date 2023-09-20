'use strict'

import { renderSvg } from '../remark-typst/remark-mathjax/svg.js'

let node = { value: 'e^{i\\pi}+1=0' }
renderSvg({}, { scale: .25, fontCache: 'global' }).render(node, {})

console.log(node.value)
