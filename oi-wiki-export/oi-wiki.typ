// Functions for OI-Wiki remark-typst

/* BEGIN packages */
#import "@preview/codelst:1.0.0": code-frame, sourcecode
#import "pymdownx-details.typ": *
/* END plugins */

/* BEGIN packages */
#let typst-qrcode-wasm = plugin("./typst_qrcode_wasm.wasm")
/* END plugins */

/* BEGIN constants */
#let ROOT_EM = 10.5pt
#let VISIBLE_WIDTH = 21cm - 1in
#let VISIBLE_HEIGHT = 29.7cm - 1.5in
#let BLOCKQUOTE_CONTENT_WIDTH = VISIBLE_WIDTH - ROOT_EM * 2
#let MAX_IMAGE_WIDTH = VISIBLE_WIDTH - ROOT_EM * 8
#let MAX_IMAGE_HEIGHT = VISIBLE_HEIGHT / 2 - ROOT_EM * 4
// #let ENDPOINT = MAX_IMAGE_HEIGHT - MAX_IMAGE_WIDTH / 2
// #let MAX_RATIO = MAX_IMAGE_WIDTH / ENDPOINT
/* END constants */

#let antiflash-white = (bright: cmyk(0%, 0%, 0%, 5%), dark: cmyk(0%, 0%, 0%, 10%))

// There ARE thematic (section) breaks in paperprints!
// Although they are usually represented by three asterisks (a dinkus).
#let horizontalrule = block(
  h(1fr) + sym.ast.op + h(1em) + sym.ast.op + h(1em) + sym.ast.op + h(1fr)
)

#let blockquote(content) = {
  let cmyk-gray = cmyk(0%, 0%, 0%, 70%)

  let cont_block = block.with(
    width: 100%,
    inset: (left: 1.75em, y: .25em),
  )

  [
    #v(.375em)
    #grid(
      columns: (.25em, auto),
      // NOTE: parametrically (not hard-coded) size measurement is in progess
      // issue: https://github.com/typst/typst/issues/113
      layout(size => style(styles => {
        let h_cont = measure(
          cont_block(width: BLOCKQUOTE_CONTENT_WIDTH)[#content],
          styles
        ).height
        rect(
          height: h_cont,
          fill: cmyk-gray,
          radius: .25em
        )
      })),
      cont_block[
        #set text(fill: cmyk-gray)
        #content
      ]
    )
    #v(.375em)
  ]
}

#let kbd(string) = box(
  inset: (x: .25em, top: .2em, bottom: .3em),
  fill: antiflash-white.bright,
  stroke: (
    bottom: (paint: cmyk(0%, 0%, 0%, 50%), thickness: 2pt, cap: "round", join: "round"), 
    x: (paint: cmyk(0%, 0%, 0%, 50%), thickness: 1pt, cap: "round", join: "round"), 
  ),
  radius: .25em,
  baseline: .2em,

  raw(string)
)

#let authors(authors) = blockquote[Authors: #authors]

#let codeblock(lang: str, unwrapped: false, code) = {
  block(
    width: 100%,
    radius: if not unwrapped {
      .5em
    } else {
      (bottom: .5em)
    },
    inset: (x: 1em, y: .5em),
    fill: antiflash-white.bright,
    stroke: if not unwrapped {
      1pt + antiflash-white.dark
    } else {
      (
        bottom: 1pt + antiflash-white.dark,
        x: 1pt + antiflash-white.dark
      )
    },

    raw(block: true, lang: lang, code)
  )
}

// FIXME: weird line numbers
// #let codeblock(lang: str, unwrapped: false, code) = {
//   let frame = code-frame.with(
//     fill: antiflash-white,
//    stroke: if not unwrapped {
//      (bottom: 1pt + color.dark, left: 1pt + color.dark, right: 1pt + color.dark, )
//    } else {
//      none
//    },
//    inset: (x: 1em, y: .5em),
//    radius: if not unwrapped {
//      .5em
//     } else {
//       (bottom: .5em)
//     }
//   )
// 
//   sourcecode(
//     frame: frame,
//     raw(lang: lang, code)
//   )
// }

// Auto-sized figure.
// NOTE: optimized image size is in progress
// issue: https://github.com/typst/typst/issues/436
#let figauto(src: str, alt: str) = style(styles => {
  let img = image(src)
  let (width, height) = measure(img, styles)

  // NOTE: basic scaling
  if width / height > MAX_IMAGE_WIDTH / MAX_IMAGE_HEIGHT {
    // let normalized_width = calc.sqrt(MAX_IMAGE_WIDTH.pt() * width.pt()) / MAX_IMAGE_WIDTH.pt()
    // set image(width: calc.min(normalized_width, 1) * MAX_IMAGE_WIDTH)
    set image(width: calc.min(width / 2, MAX_IMAGE_WIDTH))
    [
      #v(.8em)
      #align(center, img)
      #v(.8em)
    ]
    // figure(img, caption: alt)
  } else {
    // let normalized_height = calc.sqrt(MAX_IMAGE_HEIGHT.pt() * height.pt()) / MAX_IMAGE_HEIGHT.pt()
    // set image(width: calc.min(normalized_height, 1) * MAX_IMAGE_HEIGHT)
    set image(height: calc.min(height / 2, MAX_IMAGE_HEIGHT))
    [
      #v(.8em)
      #align(center, img)
      #v(.8em)
    ]
    // figure(img, caption: alt)
  }

  // NOTE: trigonometric solution
  // let hori = VISIBLE_WIDTH.pt()
  // let radius = hori / 2
  // let ratio = width / height
  // let vert = hori / ratio
  // let diag = calc.sqrt(radius * radius + vert * vert)
  // let factor = diag / radius

  // set image(width: calc.min(width, VISIBLE_WIDTH / factor))
  // figure(img, caption: alt)

  // NOTE: another trigonometric solution
  // if width / height > MAX_RATIO {
  //   set image(width: calc.min(width / 2, MAX_IMAGE_WIDTH))
  //   figure(img, caption: alt)
  // } else {
  //   let r   = MAX_RATIO / 2
  //   let v   = MAX_RATIO / (width / height)
  //   let b1  = calc.sqrt((v - 1) * (v - 1) + r * r)
  //   let c1  = calc.sqrt(v * v + r * r)
  //   let a   = 1
  //   let b   = r
  //   let B   = calc.acos((a * a + c1 * c1 - b1 * b1) / (2 * a * c1))
  //   let A   = calc.asin(a * calc.sin(B) / b)
  //   let C   = 180deg - A - B
  //   let c   = (a * calc.sin(C) / calc.sin(A))
  //   let f   = c1 / c
  //   set image(width: calc.min(width / 2, MAX_IMAGE_WIDTH / f))
  //   figure(img, caption: alt)
  // }
})

// FIXME: correct size of SVG equations
#let dispmath(svg: str) = style(styles => {
  let img = image.decode(svg)
  let (width, height) = measure(img, styles)
  set image(width: width, height: height)

  align(center)[#img]
})

#let inlinemath(svg: str) = box(
  style(styles => {
    let img = image.decode(svg)
    let (width, height) = measure(img, styles)
    set image(width: width, height: height)

    img
  })
)

#let qrcode(arg) = image.decode(
  str(typst-qrcode-wasm.generate(bytes(arg))),
  width: .5in,
)

#let links-grid(..content) = {
  set text(9pt)

  grid(
    columns: (1fr, 1in, 1fr, .5in),
    rows: .5in,

    ..content
  )
}
#let links-cell(content) = block(
  width: 100%, 
  height: 100%,

  align(horizon, content)
)
