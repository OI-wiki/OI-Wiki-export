/* Functions of oi-wiki-export-typst */

/* BEGIN imports */
#import "constants.typ": *
#import "pymdownx-details.typ": details

#import "@preview/tablex:0.0.5": tablex
#import "@preview/tiaoma:0.1.0"
#import "@preview/mitex:0.1.0" as mmm
/* END imports */

#let mi(..args) = mmm.mi(..args)
#let mitex(eq, numbering: none, supplement: auto) = mmm.mitex(eq)

#let page-header = locate(loc => {
    if calc.odd(loc.page()) {
      // NOTE: not able to programatically hide headings on new chapters for now
      // issue: https://github.com/typst/typst/issues/1613

      let section = query(
        selector(heading.where(level: 2)).before(loc),
        loc
      )
      if section == () {
        return none
      }

      let sect-number(..headings) = {
        let levels = headings.pos()

        if levels.len() > 1 {
          [#levels.at(0).#levels.at(1)]
        } else {
          none
        }
      }

      text(9pt, number-width: "tabular")[
        #emph[
          #counter(heading).display(sect-number)
          #h(1em)
          #smallcaps(section.last().body)
        ]
        #h(1fr)
        #counter(page).display("1")
      ]
    } else {
      let chapters = query(
        selector(heading.where(level: 1)).before(loc),
        loc,
      )
      // HACK: don't add headers in outlines (Chapter 0)
      // This is only a workaround. Detailed mechanism of typst's pagebreaks
      // needs to be further researched.
      let chapter-counter = counter(heading.where(level: 1)).at(loc)
      if chapter-counter == (0,) {
        return none
      }

      text(9pt, number-width: "tabular")[
        #counter(page).display("1")
        #h(1fr)
        第#counter(heading.where(level: 1)).display("一")章
        #h(1em)
        #chapters.last().body
      ]
    }
  }
)

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
    inset: (x: .1em),
    fill: luma(95%),
    stroke: (
      bottom: (paint: luma(50%), thickness: 2pt, cap: "round"),
      x: (paint: luma(50%), thickness: 1pt, cap: "round"),
    ),
    radius: .2em,

    raw(string)
  )

  h(.5em) + key + h(.5em)
}

#let codeblock(
  code,
  lang: str,
  unwrapped: false,
) = {
  let radius = if unwrapped {
    (bottom: .2em)
  } else {
    .2em
  }
  let stroke = if unwrapped {
    (
      top: (thickness: 1pt, paint: luma(75%), dash: "dashed"),
      bottom: 1pt + luma(75%),
      x: 1pt + luma(75%)
    )
  } else {
    1pt + luma(75%)
  }

  // Code block with line numbers
  // Issue: https://github.com/typst/typst/issues/344
  // Reference: https://gist.github.com/mpizenberg/c6ed7bc3992ee5dfed55edce508080bb
  let lines = code.replace("\t", "  ").split("\n")
  let digits = str(lines.len()).len()

  // Width of glyphs in DejaVu Sans Mono is 1233 units
  let glyph-width = (1233 / 2048) * 0.8 * RAW_EM
  let number-width = (digits + 2) * glyph-width
  let track-width = (digits + 5) * glyph-width

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
          fill: luma(75%)
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

// Auto-sized image.
// NOTE: optimized image sizing is in progress
// issue: https://github.com/typst/typst/issues/436
#let img-auto(
  src,
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

#let svg-math(
  svg,
  display: false,
) = style(styles => {
  let img = image.decode(svg)
  let (width, height) = measure(img, styles)
  set image(width: width * (12 / 16), height: height * (12 / 16))

  if display {
    align(center, img)
  } else {
    box(img)
  }
})

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
#let qrcode(arg) = tiaoma.qrcode(arg, width: .4in)

#let tablex-custom(
  columns: (),
  aligns: (),

  ..cells
) = {
  set text(9pt)

  align(center, block(
    radius: .2em,
    inset: (x: .5em),
    stroke: 1pt + luma(75%),

    tablex(
      columns: columns,
      column-gutter: 1fr,
      // NOTE: repeat-header has no effect when the table is in a container
      // it is also a little buggy right now, so we are not enabling it at this moment
      // issue: https://github.com/PgBiel/typst-tablex/issues/43
      repeat-header: false,
      align: (col, row) => aligns.at(col),
      stroke: 1pt + luma(75%),
      auto-vlines: false,

      ..cells
    )
  ))
}

#let tabbed(unwrap: false, ..items) = {
  let items = items.pos()
  if items.len() != 2 {
    panic("#tabbed receives exactly two content blocks")
  }
  
  block[
    #block(
      width: 100%,
      fill: luma(85%),
      stroke: (
        top: 1pt + luma(75%),
        x: 1pt + luma(75%),
      ),
      below: 0em,
      inset: (x: 1em, y: .5em),
      radius: (top: .2em),
    )[
      #show parbreak: none

      #strong(items.at(0))
    ]

    #if not unwrap {
      block(
        width: 100%,
        stroke: (
          top: (thickness: 1pt, paint: luma(75%), dash: "dashed"),
          bottom: 1pt + luma(75%),
          x: 1pt + luma(75%),
        ),
        above: 0em,
        inset: (x: 1em, y: .5em),
        radius: (bottom: .2em),

        items.at(1)
      )
    } else {
      items.at(1)
    }
  ]
}
