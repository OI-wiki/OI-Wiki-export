const visit = require('unist-util-visit')

module.exports = createPlugin

// To do next major: Remove `chtml` and `browser` flags once all the options use
// the same format.
function createPlugin(displayName, createRenderer, chtml, browser) {
  attacher.displayName = displayName

  return attacher

  function attacher(options) {
    if (chtml && (!options || !options.fontURL)) {
      throw new Error(
        'rehype-mathjax: missing `fontURL` in options, which must be set to a URL to reach MathJaX fonts'
      )
    }

    const inputOptions = browser ? options : (options || {}).tex
    let outputOptions = options || {}
    if ('tex' in outputOptions) {
      outputOptions = Object.assign({}, outputOptions)
      delete outputOptions.tex
    }

    transform.displayName = displayName + 'Transform'

    return transform

    function transform(tree) {
      const renderer = createRenderer(inputOptions, outputOptions)

      // let context = tree
      // let found = false

      visit(tree, 'math', (node) => {
        renderer.render(node, {display: true})

        return visit.SKIP
      })

      visit(tree, 'inlineMath', (node) => {
        renderer.render(node, {display: false})

        return visit.SKIP
      })

      // if (found && renderer.styleSheet) {
      //   context.children.push(renderer.styleSheet())
      // }

      // function onelement(node) {
      //   const classes = node.properties.className || []
      //   const inline = classes.includes('math-inline')
      //   const display = classes.includes('math-display')

      //   if (node.tagName === 'head') {
      //     context = node
      //   }

      //   if (!inline && !display) {
      //     return
      //   }

      //   found = true
      //   renderer.render(node, {display: display})

      //   return visit.SKIP
      // }
    }
  }
}
