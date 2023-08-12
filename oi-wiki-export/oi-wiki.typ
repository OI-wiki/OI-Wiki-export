// Functions for OI-Wiki remark-typst

/* BEGIN constants */
#let ROOT_EM = 10.5pt
#let MAX_IMAGE_WIDTH = 21cm - 1in - ROOT_EM * 2 * 2
#let MAX_IMAGE_HEIGHT = (29.7cm - 1.5in) / 2
#let BLOCKQUOTE_CONTENT_WIDTH = 21cm - 1in - ROOT_EM
/* END constants */

#let antiflash-white = cmyk(0%, 0%, 0%, 5%)

#let warning-orange = (bright: cmyk(0%, 10%, 20%, 0%), dark: cmyk(0%, 20%, 50%, 0%))

#let info-blue = (bright: cmyk(15%, 10%, 0%, 0%), dark: cmyk(30%, 20%, 0%, 0%))

// There ARE thematic (section) breaks in paperprints!
// Although they are usually represented by three asterisks (a dinkus).
#let horizontalrule = block[
  #h(1fr)
  #sym.ast.op
  #h(1em)
  #sym.ast.op
  #h(1em)
  #sym.ast.op
  #h(1fr)
]

#let blockquote(content) = {
  let cont_block = block.with(width: 100%, fill: antiflash-white, inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), radius: (right: .5em,))

  grid(
    columns: (1em, auto),

    // TODO: parametrically (not hard-coded) auto-sized left decoration bar
    // issue: https://github.com/typst/typst/issues/113
    layout(size => style(styles => {
      let h_cont = measure(cont_block(width: BLOCKQUOTE_CONTENT_WIDTH)[#content], styles).height

      rect(height: h_cont, fill: cmyk(0%, 0%, 0%, 50%), radius: (left: .5em))
    })),
    cont_block[#content]
  )
}
// #let blockquote(content) = block(width: 100%, fill: antiflash-white, inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), radius: .5em, stroke: (left: 1em + cmyk(0%, 0%, 0%, 75%)))[#content]

#let details(color: (bright: cmyk, dark: cmyk), ..items) = {
  let items = items.pos()
  if items.len() != 2 {
    panic("#details function needs exactly two content blocks")
  }

  // TODO: transparentize codeblocks inside details
  // let inner_codeblock = locate(loc => query(
  //   codeblock,
  //   loc,
  // ))
  // let cont = if inner_codeblock == () {
  //   block(
  //     width: 100%, 
  //     fill: color.bright, 
  //     above: 0em, 
  //     inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), 
  //     radius: (bottom: 0.5em)
  //   )[
  //     #items.at(1)
  //   ]
  // } else {
  //   items.at(1)
  // }

  block[
    #block(
      width: 100%, 
      fill: color.dark, 
      below: 0em, 
      inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), 
      radius: (top: 0.5em)
    )[
      #strong[#items.at(0)]
    ]
    #block(
      width: 100%, 
      fill: color.bright, 
      above: 0em, 
      inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), 
      radius: (bottom: 0.5em),
    )[
      #items.at(1)
    ]
  ]
}

#let authors(authors) = blockquote[#strong[Authors: ]#authors]

#let codeblock(code: str, lang: str) = {
  // if s.display() == true {
  //   block[#raw(code, lang: lang)]
  // } else {
    block(
      width: 100%, 
      fill: antiflash-white, 
      inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), 
      radius: 0.5em
    )[
      // #s.display()
      #raw(code, lang: lang)
    ]
  // }
}

// Auto-sized figure based on measurement.
#let figauto(src: str, alt: str) = style(styles => {
  let img = image(src, fit: "contain")
  // Current measurement are merely based on pixel width, and not actual size (px / dpi)
  // issue: https://github.com/typst/typst/issues/436
  let (width, height) = measure(img, styles)
  set image(
    width: calc.min(width / 2, MAX_IMAGE_WIDTH), 
    height: calc.min(height / 2, MAX_IMAGE_HEIGHT),
  )

  figure(img, caption: alt)
})

#let dispmath(svg: str) = style(styles => {
  let img = image.decode(svg)
  let (width, height) = measure(img, styles)
  set image(width: width / 1.27, height: height / 1.27)

  align(center)[#img]
})

#let inlinemath(svg: str) = box(
  // TODO: fix the height of inline mathematics
  // height: 1em,
  baseline: 20%,

  style(styles => {
    let img = image.decode(svg)
    let (width, height) = measure(img, styles)
    set image(width: width / 1.27, height: height / 1.27)

    img
  })
)
