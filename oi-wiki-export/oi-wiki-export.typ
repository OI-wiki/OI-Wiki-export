// Base template for oi-wiki-export

/* BEGIN constants */
#let ROOT_EM = 10.5pt
/* END constants */

/* BEGIN meta formatting */
#set text(
  lang: "zh",
)
/* END meta formatting */

/* BEGIN cover */
#set page(
  paper: "a4",
  margin: (top: .8in, inside: .4in, bottom: .7in, outside: .6in),
  header-ascent: 40%
)

#v(2fr)

#show math.equation: set text(font: ("New Computer Modern Math", "FZKai-Z03S"))

#text(
  size: 36pt,
  font: ("Linux Biolinum", "FZHei-B01S"),
  weight: 551,
)[OI Wiki (Beta)]

#text(
  size: 18pt,
  font: ("Linux Libertine", "FZShuSong-Z01S"),
)[
  OI Wiki 项目组

  #datetime.today().display("[year] 年 [month padding:none] 月 [day padding:none] 日")
]

#v(1fr)

#pagebreak()
/* END cover */

/* BEGIN article formatting */
#set text(
  lang: "zh",
  size: ROOT_EM,
  font: ("Linux Libertine", "FZShuSong-Z01S"),
)

#set par(
  leading: 0.8em,
  first-line-indent: 2em,
  // TODO: CJK-style first line indent
  // issues: https://github.com/typst/typst/issues/311
  //         https://github.com/typst/typst/issues/1410
  // hanging-indent: -2em,
)
// #show par: set block(
//   outset: (left: 2em, right: -2em),
// )

#set block(spacing: 0.8em)

#set strong(delta: 0)
#show strong: set text(
  font: ("Linux Biolinum", "FZHei-B01S"),
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(spacing: 1em)
#show heading: set text(
  font: ("Linux Biolinum", "FZHei-B01S"),
  weight: 551,
)
#show heading.where(level: 1): set text(size: 36pt)
#show heading.where(level: 2): set text(size: 24pt)
#show heading.where(level: 3): set text(size: 18pt)
#show heading.where(level: 4): set text(size: 15pt)
#show heading.where(level: 5): set text(size: 13.75pt)
#show heading.where(level: 6): set text(size: 12pt)

#show emph: set text(
  font: ("Linux Libertine", "FZKai-Z03S")
)

#show raw: set text(
  // FIXME: current text size of raw block is being set to 0.8rem
  // So we scale it back a little
  // issue: https://github.com/typst/typst/issues/1331
  size: 1.1em,
  font: ("DejaVu Sans Mono", "FZKai-Z03S")
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
  header: {
    let sect_number(..headings) = {
      let levels = headings.pos()

      if levels.len() > 1 {
        [#levels.at(0).#levels.at(1)]
      } else {
        []
      }
    }
    
    locate(loc => {
      if calc.odd(loc.page()) {
        // TODO: programatically hide headings on new chapters
        // issue: https://github.com/typst/typst/issues/1613
        // let curr_chapter = query(
        //   selector(heading.where(level: 1)),
        //   loc,
        // )

        let curr_section = query(
          selector(heading.where(level: 2)).before(loc), 
          loc
        )
        if curr_section == () {
          return []
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
          第~#counter(heading.where(level: 1)).display("1")~章#h(1em)#elems.last().body
        ]
      }
    })
  }
)

#show heading.where(level: 1): it => block(
  spacing: 0em,
)[
  #set text(
    size: 36pt,
    font: ("Linux Biolinum", "FZHei-B01S"),
    weight: 551,
  )
  #set par(
    first-line-indent: 0em,
  )

  #v(3em)
  第~#counter(heading).display()~章
  #v(1em)
  #it.body
  #v(3em)
]


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

#set list(indent: 2em)
#show list: set block(spacing: 0.8em)
#set enum(indent: 2em)
#show enum: set block(spacing: 0.8em)

#set footnote(numbering: "[1]")
#show footnote: set text(fill: cmyk(0%, 100%, 0%, 0%))
#show footnote.entry: it => {
  let loc = it.note.location()
  numbering("1. ", ..counter(footnote).at(loc))
  it.note.body
}

#include "includes.typ"
/* END main */
