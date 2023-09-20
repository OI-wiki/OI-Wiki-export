// Base template for oi-wiki-export

/* BEGIN plugins */
#let typst-qrcode-wasm = plugin("./typst_qrcode_wasm.wasm")
/* END plugins */

/* BEGIN constants */
#let ROOT_EM = 10.5pt
#let antiflash-white = (bright: cmyk(0%, 0%, 0%, 5%), dark: cmyk(0%, 0%, 0%, 10%))
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

#v(1fr)

#show math.equation: set text(font: ("New Computer Modern Math", "LXGW Wenkai"))

#text(
  size: 36pt,
  font: ("New Computer Modern", "Noto Serif CJK SC"),
  weight: 700,
)[OI Wiki (Beta)]

#text(
  size: 18pt,
  font: ("New Computer Modern", "Noto Serif CJK SC"),
)[
  OI Wiki 项目组

  #datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日")
]

#v(1fr)

#pagebreak(to: "odd")
/* END front cover */

/* BEGIN article formatting */
#set text(
  lang: "zh",
  size: ROOT_EM,
  font: ("New Computer Modern", "Noto Serif CJK SC"),
)

// NOTE: CJK-style first line indent is still in progress
// issues: https://github.com/typst/typst/issues/311
//         https://github.com/typst/typst/issues/1410
#set par(
  leading: .8em,
  first-line-indent: 2em,
)
// #show par: set block(
//   outset: (left: 2em, right: -2em),
// )

#set block(spacing: .8em)

#set strong(delta: 0)
#show strong: set text(
  font: ("Public Sans", "Noto Sans CJK SC"),
  // Public Sans:     400 500  |->600 700
  // Noto Sans CJK:   400 500<-|      700
  // Source Code Pro: 400 500  |->600 700
  //                          551
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(above: 1.6em, below: .8em)
#show heading: set text(
  font: ("New Computer Modern", "Noto Serif CJK SC"),
  weight: 700,
)
#show heading.where(level: 2): set text(size: 22pt)
#show heading.where(level: 3): set text(size: 18pt)
#show heading.where(level: 4): set text(size: 16pt)
#show heading.where(level: 5): set text(size: 14pt)
#show heading.where(level: 6): set text(size: 12pt)

#show emph: set text(
  font: ("New Computer Modern", "LXGW Wenkai")
)

#show raw: set text(
  // Current text size of raw block is set to 0.8rem
  // So we scale it back a little
  // issue: https://github.com/typst/typst/issues/1331
  size: 1.125em,
  font: ("Source Code Pro", "LXGW Wenkai"),
)
#show raw.where(block: false): it => highlight(
  fill: antiflash-white.bright,
  it
)
/* END article formatting */

/* BEGIN outline */
#counter(page).update(0)

#set page(
  fill: none,
  header: [
    #set text(9pt)
    #counter(page).display("i")
    #h(1fr)
  ]
)

#show heading.where(level: 1): set text(size: 36pt)

#outline(indent: 2em)
/* END outline */

/* BEGIN main */
#counter(page).update(0)

#set page(
  header: locate(loc => {
    if calc.odd(loc.page()) {
      // NOTE: not able to programatically hide headings on new chapters for now
      // issue: https://github.com/typst/typst/issues/1613
      // let chapters = query(selector(heading.where(level: 1)).before(loc), loc)
      // let curr_heading = counter(heading).at(loc).at(0)

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

// #show heading: it => {
//   it
//   par(text(size: .5em, ""))
// }

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

// NOTE: aligned enum indices & list bullets?
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

#set list(indent: 1em)
#show list: set block(spacing: .8em)
#set enum(indent: 1em)
#show enum: set block(spacing: .8em)

// #set footnote(numbering: "1")
// #show footnote: set text(fill: cmyk(0%, 100%, 0%, 0%))
// #show footnote.entry: it => {
//   let loc = it.note.location()
//   numbering("1. ", ..counter(footnote).at(loc))
//   it.note.body
// }

#show footnote.entry: it => {
  show parbreak: []
  it
}

#show ref: set text(fill: cmyk(0%, 100%, 100%, 0%))
#set ref(supplement: el => {
  [#el.body→小节]
})

#include "includes.typ"
/* END main */

/* BEGIN back cover */
// #pagebreak(to: "odd")
// 
// #set page(
//   
// )
/* END back cover */
