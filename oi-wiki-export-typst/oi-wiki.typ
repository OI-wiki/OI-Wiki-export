/* Functions of oi-wiki-export-typst */

/* BEGIN imports */
#import "constants.typ": *
#import "pymdownx-details.typ": details

#import "@preview/tablex:0.0.5": tablex
/* END imports */

/* BEGIN plugins */
#let typst-qrcode-wasm = plugin("./typst_qrcode_wasm.wasm")
/* END plugins */

#let horizontalrule = align(center, block(
  sym.ast.op + h(1em) + sym.ast.op + h(1em) + sym.ast.op
))

#let blockquote(content) = {
  set text(fill: luma(50%))

  block(
    stroke: (left: (thickness: 4pt, paint: luma(50%), cap: "square")),
    inset: (left: 2em),
    spacing: 1.6em,

    content
  )
}

#let authors(authors) = blockquote[*Authors:* #authors]

#let kbd(string) = {
  let key = box(
    outset: .2em,
    fill: luma(95%),
    stroke: (
      bottom: (paint: luma(50%), thickness: 2pt, cap: "round"), 
      x: (paint: luma(50%), thickness: 1pt, cap: "round"), 
    ),
    radius: .1em,

    raw(string)
  )

  h(.5em) + key + h(.5em)
}

#let codeblock(
  lang: str,
  unwrapped: false,
  code
) = {
  let radius = if unwrapped {
    (bottom: .1em)
  } else {
    .1em
  }
  let stroke = if unwrapped {
    (
      top: (thickness: 1pt, paint: luma(80%), dash: "dashed"),
      bottom: 1pt + luma(80%),
      x: 1pt + luma(80%)
    )
  } else {
    1pt + luma(80%)
  }

  // Code block with line numbers
  // Issue: https://github.com/typst/typst/issues/344
  // Reference: https://gist.github.com/mpizenberg/c6ed7bc3992ee5dfed55edce508080bb
  let lines = code.replace("\t", "  ").split("\n")
  let digits = str(lines.len()).len()

  // Width of digits in DejaVu Sans Mono is 1233 units
  let digit-width = (1233 / 2048) * 0.8 * RAW_EM
  let number-width = (digits + 2) * digit-width
  let track-width = (digits + 5) * digit-width

  grid(
    columns: 2,
    column-gutter: -100%,
    
    // Background & line numbers
    block(
      width: 100%,
      radius: radius,
      inset: (left: track-width, y: .5em),
      fill: luma(95%),
      stroke: stroke,
      
      {
        set text(
          0.8 * RAW_EM,
          font: ("DejaVu Sans Mono", "LXGW WenKai"),
          fill: luma(80%)
        )
        
        for (i, line) in lines.enumerate() {
          box(
            width: 0pt,
            inset: (right: track-width - number-width),
            align(right, str(i + 1))
          )
          hide(line)
          linebreak()
        }
      }
    ),
    // The code itself
    block(
      width: 100%,
      inset: (left: track-width, y: .5em),

      raw(block: true, lang: lang, code)
    )
  )
}

// Auto-sized figure.
// NOTE: optimized image size is in progress
// issue: https://github.com/typst/typst/issues/436
#let figauto(
  src: str, 
  alt: str, 
) = style(styles => {
  let img = image(src)
  let (width, height) = measure(img, styles)

  let max-image-width = VISIBLE_WIDTH - ROOT_EM * 8
  let max-image-height = VISIBLE_HEIGHT / 2 - ROOT_EM * 8

  if width / height > max-image-width / max-image-height {
    set image(width: calc.min(width, max-image-width))
    
    v(.8em)
    align(center, img)
    v(.8em)
  } else {
    set image(height: calc.min(height, max-image-height))
    
    v(.8em)
    align(center, img)
    v(.8em)
  }

  // BEGIN trigonometric solution
  // let hori = VISIBLE_WIDTH.pt()
  // let radius = hori / 2
  // let ratio = width / height
  // let vert = hori / ratio
  // let diag = calc.sqrt(radius * radius + vert * vert)
  // let factor = diag / radius
  // set image(width: calc.min(width, VISIBLE_WIDTH / factor))
  // figure(img, caption: alt)
  // END trigonometric solution

  // BEGIN another trigonometric solution
  // let endpoint = MAX_IMAGE_HEIGHT - MAX_IMAGE_WIDTH / 2
  // let max-ratio = MAX_IMAGE_WIDTH / endpoint
  // if width / height > max-ratio {
  //   set image(width: calc.min(width / 2, max-image-width))
  //   figure(img, caption: alt)
  // } else {
  //   let r   = max-ratio / 2
  //   let v   = max-ratio / (width / height)
  //   let b1  = calc.sqrt((v - 1) * (v - 1) + r * r)
  //   let c1  = calc.sqrt(v * v + r * r)
  //   let a   = 1
  //   let b   = r
  //   let B   = calc.acos((a * a + c1 * c1 - b1 * b1) / (2 * a * c1))
  //   let A   = calc.asin(a * calc.sin(B) / b)
  //   let C   = 180deg - A - B
  //   let c   = (a * calc.sin(C) / calc.sin(A))
  //   let f   = c1 / c
  //   set image(width: calc.min(width / 2, max-image-width / f))
  //   figure(img, caption: alt)
  // }
  // END another trigonometric solution
})

#let dispmath(svg: str) = style(styles => {
  let img = image.decode(svg)
  let (width, height) = measure(img, styles)
  set image(width: width * (12 / 16), height: height * (12 / 16))

  align(center, img)
})
#let inlinemath(svg: str) = box(
  style(styles => {
    let img = image.decode(svg)
    let (width, height) = measure(img, styles)
    set image(width: width * (12 / 16), height: height * (12 / 16))

  img
}))

#let links-grid(..content) = {
  set text(9pt)
  set par(leading: .5em)

  grid(
    columns: (1fr, .75in, 1fr, .5in),
    rows: .5in,

    ..content
  )
}
#let links-cell(content) = block(
  width: 100%, 
  height: 100%,

  align(horizon, content)
)
#let qrcode(arg) = image.decode(
  str(typst-qrcode-wasm.generate(bytes(arg))),
  width: .5in,
)

#let tablex-custom(
  columns: (),
  aligns: (),

  ..cells
) = {
  set text(9pt)

  align(center, block(
    radius: .1em,
    inset: (x: .5em),
    stroke: 1pt + luma(80%),
  
    tablex(
      columns: columns,
      column-gutter: 1fr,
      // NOTE: repeat-header has no effect when the table is in a container
      // it is also a little buggy right now, so we are not enabling it at this moment
      // issue: https://github.com/PgBiel/typst-tablex/issues/43
      repeat-header: false,
      align: (col, row) => aligns.at(col),
      stroke: 1pt + luma(80%),
      auto-vlines: false,
  
      ..cells
    ) 
  ))
}
