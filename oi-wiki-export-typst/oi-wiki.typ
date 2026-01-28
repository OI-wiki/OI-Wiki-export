/* Functions of oi-wiki-export-typst */

/* BEGIN imports */
#import "constants.typ": *
#import "pymdownx-details.typ": details

#import "@preview/tablex:0.0.9": tablex
#import "@preview/tiaoma:0.3.0"
#import "@preview/mitex:0.2.5": mi, mitex
#let sourcecode(body, highlight_color: rgb("#fffd11a1").lighten(70%)) = {
  let rlines = ()
  show raw.where(block: true): it => {
    set par(justify: false)
    block(
      fill: luma(245),
      stroke: 1pt + luma(245),
      inset: (top: 4pt, bottom: 4pt),
      radius: 4pt,
      width: 100%,
      stack(
        ..it.lines.map(raw_line => block(
          inset: 3pt,
          width: 100%,
          stroke: none,
          fill: if calc.rem(raw_line.number, 2) == 0 {
            luma(100%)
          } else {
            none
          },
          grid(
            columns: (1em + 4pt, 1fr),
            align: (right + horizon, left),
            column-gutter: 0.7em,
            row-gutter: 0.6em,
            if rlines.contains(raw_line.number) {
              text(highlight_color.darken(89%), [#raw_line.number])
            } else {
              text(gray, [#raw_line.number])
            },
            raw_line,
          ),
        )),
      ),
    )
  }
  body
}


/* END imports */

#let page-header = context {
  let loc = here()
  if calc.odd(loc.page()) {
    // NOTE: not able to programatically hide headings on new chapters for now
    // issue: https://github.com/typst/typst/issues/1613
    let section = query(selector(heading.where(level: 2)).before(loc))
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
    let chapters = query(selector(heading.where(level: 1)).before(loc))
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

#let horizontalrule = align(
  center,
  block(sym.ast.op + h(1em) + sym.ast.op + h(1em) + sym.ast.op),
)

#let blockquote(content) = {
  set text(fill: luma(20%))

  block(
    stroke: (left: (thickness: 3pt, paint: luma(80%), cap: "square")),
    inset: (left: 1em),
    spacing: 1.5em,
    content,
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
    raw(string),
  )

  h(.5em) + key + h(.5em)
}

#let img-auto(src, alt: str) = {
  image(src, alt: alt)
}

#let svg-math(svg, display: false) = style(styles => {
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

  // 每行只放一条参考：三列 -> [链接文本 | 二维码1 | 二维码2]
  grid(
    columns: (1fr, 1cm, 1cm),
    align: (left + horizon, center + horizon, center + horizon),
    column-gutter: .2cm,
    row-gutter: .2cm,
    ..content,
  )
}

#let links-cell(content) = content

#let qrcode(arg) = tiaoma.qrcode(arg, width: .9cm)

#let tablex-custom(columns: (), aligns: (), ..cells) = {
  set text(9pt)

  align(
    center,
    block(
      radius: .2em,
      stroke: 1pt + luma(75%),
      table(
        columns: columns,
        align: (col, row) => aligns.at(col),
        stroke: 1pt + luma(75%),
        ..cells,
      ),
    ),
  )
}

#let tabbed(unwrap: false, ..items) = {
  let items = items.pos()
  if items.len() != 2 {
    panic("#tabbed receives exactly two content blocks")
  }

  let (tab, content) = items

  [
    - #tab
      #content
  ]
}