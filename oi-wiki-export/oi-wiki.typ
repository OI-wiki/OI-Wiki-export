// Functions for OI-Wiki remark-typst

// TODO: transparentize codeblocks inside details
// #let s = state("in_details", false)

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

#let blockquote(content) = grid(
  columns: (1em, auto),

  // TODO: auto-sized left decoration bar
  // layout(size => style(styles => 
    rect(height: auto, fill: cmyk(0%, 0%, 0%, 50%), radius: (left: .5em)),
  // )),
  block(width: 100%, fill: antiflash-white, inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), radius: (right: .5em,))[#content]
)
// #let blockquote(content) = block(width: 100%, fill: antiflash-white, inset: (top: .5em, right: 1em, bottom: .5em, left: 1em), radius: .5em, stroke: (left: 1em + cmyk(0%, 0%, 0%, 75%)))[#content]

#let details(color: (bright: cmyk, dark: cmyk), ..items) = {
  let items = items.pos()
  if items.len() != 2 {
    panic("#details function needs exactly two content blocks")
  }

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

// Auto-sized figure based on #measure function.
#let figauto(src: str, alt: str) = style(styles => {
  let img = image(src)
  // Current measurement is merely based on pixel width, and not actual size (px / dpi)
  let measured_width = measure(img, styles).width
  set image(width: calc.min(measured_width / 2, 21cm - 1in - 10.5pt * 2 * 2))

  figure(img, caption: alt)
})
