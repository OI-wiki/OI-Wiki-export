// Base template for oi-wiki-export

/* BEGIN plugins */
#let typst-qrcode-wasm = plugin("./typst_qrcode_wasm.wasm")
/* END plugins */

/* BEGIN constants */
#let ROOT_EM = 10.5pt
#let antiflash-white = (bright: cmyk(0%, 0%, 0%, 5%), dark: cmyk(0%, 0%, 0%, 20%))
/* END constants */

/* BEGIN functions */
#let qrcode(arg) = image.decode(
  str(typst-qrcode-wasm.generate(bytes(arg))),
  width: .5in,
)
/* END functions */

/* BEGIN meta formatting */
#set text(
  lang: "zh",
  region: "cn",
)
/* END meta formatting */

/* BEGIN front cover */
#set page(
  paper: "a4",
  margin: (top: .8in, inside: .4in, bottom: .7in, outside: .6in),
  header-ascent: .3in,
  fill: antiflash-white.bright,
)

#align(center + horizon)[
  // OI-Wiki logo
  #image.decode("<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M12 3 1 9l11 6 9-4.91V17h2V9M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82Z\"></path></svg>", height: 5cm)

  #text(
    size: 36pt,
    font: ("New Computer Modern", "Noto Serif CJK SC"),
    weight: 700,
  )[OI Wiki (Beta)]
  
  #v(5cm)

  #text(
    size: 18pt,
    font: ("New Computer Modern", "Noto Serif CJK SC"),
  )[
    OI Wiki 项目组

    #datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日")
  ]
]

#pagebreak(to: "odd")

#set page(
  fill: none,
)
/* END front cover */

/* BEGIN article formatting */
#set text(
  lang: "zh",
  size: ROOT_EM,
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
  //                              551
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(spacing: 0em)
#show heading: set text(
  font: ("New Computer Modern", "Noto Serif CJK SC"),
  weight: 700,
)
#show heading.where(level: 1): set text(size: 25pt)
#show heading.where(level: 2): set text(size: 20pt)
#show heading.where(level: 3): set text(size: 17pt)
#show heading.where(level: 4): set text(size: 14pt)
#show heading.where(level: 5): set text(size: 12pt)
#show heading.where(level: 6): set text(size: 10pt)
#show heading: it => [
  // #v(1fr, weak: true)
  #v(1.8em)
  #it
  #v(.2em)
]

#show emph: set text(
  font: ("New Computer Modern", "LXGW Wenkai")
)

#show math.equation: set text(
  font: ("New Computer Modern Math", "LXGW Wenkai")
)

#show raw: set text(
  // NOTE: Default text size of raw block is 0.8rem
  // So we scale it back a little (to ~9pt in body)
  // issue: https://github.com/typst/typst/issues/1331
  size: 1.071em,
  font: ("DejaVu Sans Mono", "LXGW Wenkai"),
)
#show raw.where(block: false): it => highlight(
  fill: antiflash-white.bright,
  it
)
/* END article formatting */

/* BEGIN outline */
#counter(page).update(0)

#set page(
  header: [
    #set text(9pt)
    #counter(page).display("i")
    #h(1fr)
  ]
)

#outline(indent: 2em)
/* END outline */

/* BEGIN main */
#counter(page).update(0)

#set page(
  header: locate(loc => {
    if calc.odd(loc.page()) {
      // NOTE: not able to programatically hide headings on new chapters for now
      // issue: https://github.com/typst/typst/issues/1613

      let curr_section = query(
        selector(heading.where(level: 2)).before(loc), 
        loc
      )
      if curr_section == () {
        return []
      }

      let sect_number(..headings) = {
        let levels = headings.pos()
      
        if levels.len() > 1 {
          [#levels.at(0).#levels.at(1)]
        } else {
          []
        }
      }

      [
        #set text(size: 9pt, number-width: "tabular")

        #emph[
          #counter(heading).display(sect_number)
          #h(1em)
          #smallcaps(curr_section.last().body)
        ]
        #h(1fr)
        #counter(page).display("1")
      ]
    } else {
      let elems = query(
        selector(heading.where(level: 1)).before(loc),
        loc,
      )

      [
        #set text(9pt, number-width: "tabular")

        #counter(page).display("1")
        #h(1fr)
        第#counter(heading.where(level: 1)).display("一")章#h(1em)#elems.last().body
      ]
    }
  })
)

#show heading.where(level: 1): it => {
  pagebreak(to: "odd")

  set page(
    header: none,
    fill: antiflash-white.bright,
  )
  set text(
    size: 36pt,
    font: ("New Computer Modern", "Noto Serif CJK SC"),
    weight: 700,
  )
  set par(
    first-line-indent: 0em,
  )

  [
    #v(1fr)
    第#counter(heading).display("一")章

    #it.body
    #v(1fr)
  ]
}

#show heading.where(level: 2): it => {
  counter(footnote).update(0)
  it
}

// TODO: aligned enum indices & list bullets
// #let fullwidth_bullet = block(
//   width: 1em, 
//   height: 1em,

//   move(
//     dx: (10.5pt - 10.5pt / 3) / 2, 
//     dy: (10.5pt - 10.5pt / 3) / 2,

//     circle(
//       radius: 10.5pt / 2 / 3, 
//       fill: black,
//       stroke: none,
//       inset: 0pt,
//     )
//   )
// )
// #set list(marker: fullwidth_bullet, indent: 2em, body-indent: 0pt)
#set list(
  indent: 1em,
  // body-indent: 0pt,
  // marker: box(width: 1em)[•],
)
#show list: set block(width: 100%, spacing: .8em)
#set enum(
  indent: 1em,
  // body-indent: 0pt,
  // numbering: n => box(width: 1em)[#n.],
)
#show enum: set block(width: 100%, spacing: .8em)

#show footnote.entry: it => {
  set text(9pt)
  show parbreak: []
  it
}

#show ref: set text(fill: cmyk(0%, 100%, 100%, 0%))
#set ref(supplement: el => {
  // Width of New Computer Modern's whitespace is 333 units / em
  [#el.body→#h(-.333em)]
})

#include "includes.typ"
/* END main */

/* BEGIN back cover */
#pagebreak(to: "odd")

#set page(
  header: [],
  fill: antiflash-white.bright,
)

#v(3fr)

#align(
  center,
  text(size: 18pt)[https://oi-wiki.org]
)

#v(1fr)
/* END back cover */
