// Functions for OI-Wiki remark-typst

/* BEGIN packages */
#import "@preview/codelst:1.0.0": code-frame, sourcecode
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
#let warning-orange = (bright: cmyk(0%, 10%, 20%, 0%), dark: cmyk(0%, 20%, 40%, 0%))
#let tip-green = (bright: cmyk(20%, 0%, 10%, 0%), dark: cmyk(40%, 0%, 20%, 0%))
#let note-blue = (bright: cmyk(20%, 10%, 0%, 0%), dark: cmyk(40%, 20%, 0%, 0%))
#let warning-icon = image.decode("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M13 14h-2V9h2m0 9h-2v-2h2M1 21h22L12 2 1 21Z\"/></svg>")
#let tip-icon = image.decode("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M17.66 11.2c-.23-.3-.51-.56-.77-.82-.67-.6-1.43-1.03-2.07-1.66C13.33 7.26 13 4.85 13.95 3c-.95.23-1.78.75-2.49 1.32-2.59 2.08-3.61 5.75-2.39 8.9.04.1.08.2.08.33 0 .22-.15.42-.35.5-.23.1-.47.04-.66-.12a.58.58 0 0 1-.14-.17c-1.13-1.43-1.31-3.48-.55-5.12C5.78 10 4.87 12.3 5 14.47c.06.5.12 1 .29 1.5.14.6.41 1.2.71 1.73 1.08 1.73 2.95 2.97 4.96 3.22 2.14.27 4.43-.12 6.07-1.6 1.83-1.66 2.47-4.32 1.53-6.6l-.13-.26c-.21-.46-.77-1.26-.77-1.26m-3.16 6.3c-.28.24-.74.5-1.1.6-1.12.4-2.24-.16-2.9-.82 1.19-.28 1.9-1.16 2.11-2.05.17-.8-.15-1.46-.28-2.23-.12-.74-.1-1.37.17-2.06.19.38.39.76.63 1.06.77 1 1.98 1.44 2.24 2.8.04.14.06.28.06.43.03.82-.33 1.72-.93 2.27Z\"/></svg>")
#let note-icon = image.decode("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2m3.1 5.07c.14 0 .28.05.4.16l1.27 1.27c.23.22.23.57 0 .78l-1 1-2.05-2.05 1-1c.1-.11.24-.16.38-.16m-1.97 1.74 2.06 2.06-6.06 6.06H7.07v-2.06l6.06-6.06Z\"/></svg>")

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

#let details(unwrap: false, type: str, ..items) = {
  let items = items.pos()
  if items.len() != 2 {
    panic("#details receives exactly two content blocks")
  }

  let (color, icon) = if type == "warning" {
    (warning-orange, warning-icon)
  } else if type == "tip" {
    (tip-green, tip-icon)
  } else {
    (note-blue, note-icon)
  }

  block[
    #block(
      width: 100%,
      fill: color.bright,
      stroke: (top: 1pt + color.dark, x: 1pt + color.dark),
      below: 0em,
      inset: (x: 1em, y: .5em),
      radius: (top: .5em),
    )[
      #show parbreak: {}

      #box(height: 1.25em, baseline: .25em, icon)
      #h(.5em)
      #strong(items.at(0))
    ]

    #if not unwrap {
      block(
        width: 100%,
        stroke: (bottom: 1pt + color.dark, x: 1pt + color.dark),
        above: 0em,
        inset: (x: 1em, y: .5em),
        radius: (bottom: .5em),

        items.at(1)
      )
    } else {
      items.at(1)
    }
  ]
}

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
