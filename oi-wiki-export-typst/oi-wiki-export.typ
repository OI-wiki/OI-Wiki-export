/* Base template of oi-wiki-export-typst */

/* BEGIN imports */
#import "constants.typ": *
#import "oi-wiki.typ": page-header
/* END imports */

/* BEGIN meta */
#set text(
  lang: "zh",
  region: "cn",
)
/* END meta */

/* BEGIN front cover */
#set page(
  header: none,
  paper: "a4",
  margin: (top: .8in, inside: .4in, bottom: .7in, outside: .6in),
  header-ascent: .3in,
  fill: luma(95%),
)

#align(center + horizon)[
  // OI-Wiki logo
  #image.decode("<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M12 3 1 9l11 6 9-4.91V17h2V9M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82Z\"></path></svg>", height: 4cm)
  #text(
    25pt,
    font: ("New Computer Modern", "Noto Serif CJK SC"),
    weight: 700,
  )[OI Wiki (Beta)]
  #v(4cm)
  #text(
    18pt,
    font: ("New Computer Modern", "Noto Serif CJK SC"),
  )[
    OI Wiki 项目组

    #datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日")
  ]
]

#pagebreak(to: "odd", weak: true)
/* END front cover */

/* BEGIN article formatting */

#set page(
  fill: none,
  // header: text(9pt)[
  //   #counter(page).display("i")
  //   #h(1fr)
  // ]
)
#counter(page).update(1)

#set text(
  ROOT_EM,
  font: ("New Computer Modern", "Noto Serif CJK SC"),
)

#set par(
  leading: .8em,
  // HACK: CJK-style first line indent is still in progress
  // we are currently using JS build tools to solve this
  // issues: https://github.com/typst/typst/issues/311
  //         https://github.com/typst/typst/issues/1410
  // first-line-indent: 2em,
)

#set block(spacing: .8em)

#set strong(delta: 0)
#show strong: set text(
  font: ("New Computer Modern", "Noto Sans CJK SC"),
  // New Computer Modern: 400      |----->700
  // Noto Sans CJK:       400 500<-|      700
  // DejaVu Sans Mono:    400      |----->700
  // font-that-has-600:   400 500  |->600 700
  //                              551
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(spacing: 0em)
#show heading: set text(
  font: ("New Computer Modern", "Noto Sans CJK SC"),
  weight: 551,
)
#show heading.where(level: 1): set text(25pt)
#show heading.where(level: 2): set text(20pt)
#show heading.where(level: 3): set text(17pt)
#show heading.where(level: 4): set text(14pt)
#show heading.where(level: 5): set text(12pt)
#show heading.where(level: 6): set text(10pt)
#show heading: it => {
  // NOTE: dynamic spacing?
  // v(1fr, weak: true)
  v(1.4em)
  it
  v(.2em)
}
#show heading.where(level: 2): it => {
  v(2em)
  align(center)[#it]
  v(2em)
}

#show emph: set text(
  font: ("New Computer Modern", "LXGW Wenkai")
)

#show math.equation: set text(
  font: ("New Computer Modern Math", "LXGW Wenkai")
)

#show raw: set text(
  RAW_EM,
  font: ("DejaVu Sans Mono", "LXGW Wenkai"),
)
#show raw.where(block: false): it => highlight(
  fill: luma(95%),
  it
)
/* END article formatting */

/* BEGIN outline */
#show outline.entry.where(
  level: 1
): it => {
  v(20pt, weak: true)
  text(14pt)[#strong(it)]
}

#outline(indent: auto)
/* END outline */

/* BEGIN main */
#set page(
  header: page-header
)

#counter(page).update(1)

#show heading.where(level: 1): it => {
  set text(
    25pt,
    font: ("New Computer Modern", "Noto Serif CJK SC"),
    weight: 700,
  )
  set par(
    first-line-indent: 0em,
  )

  align(horizon)[
    第#counter(heading).display("一")章

    #it.body
  ]
}

#show heading.where(level: 2): it => {
  counter(footnote).update(0)
  it
}

// Metrics in New Computer Modern
// Width of digits:     500 units
//       of period:     278 units
//       of bullet:     778 units
//       of whitespace: 333 units
#set list(
  indent: 1em,
  body-indent: -.778em + 1em,
)
#show list: set block(width: 100%)
#set enum(
  indent: 1em,
  body-indent: -.5em -.278em + 1em,
)
#show enum: set block(width: 100%)

#set ref(supplement: el => [#el.body→#h(-.333em)])
#show ref: set text(fill: cmyk(0%, 100%, 100%, 0%))

#show footnote.entry: it => {
  set text(9pt)
  show parbreak: none
  it
}

#include "includes.typ"
/* END main */

/* BEGIN back cover */
#pagebreak(to: "odd")

#set page(
  header: none,
  fill: luma(95%),
)

#align(
  center + horizon,
  text(17pt)[https://oi-wiki.org]
)
/* END back cover */
