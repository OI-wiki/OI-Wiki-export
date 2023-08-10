/* BEGIN states */
/* END states */

/* BEGIN meta formatting */
#set page(
  paper: "a4",
  margin: (top: .7in, inside: .4in, bottom: .8in, outside: .6in),
)

#set text(
  lang: "zh",
)
/* END meta formatting */

/* BEGIN cover */
#v(2fr)

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
  size: 10.5pt,
  font: ("Linux Libertine", "FZShuSong-Z01S"),
)

#set par(
  leading: 0.75em,
  first-line-indent: 2em,
  // TODO: CJK-style first line indent
  // hanging-indent: -2em,
)
// #show par: set block(
//   outset: (left: 2em, right: -2em),
// )

#set block(spacing: 0.75em)

#set strong(delta: 0)
#show strong: set text(
  font: ("Linux Biolinum", "FZHei-B01S"),
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(spacing: 1.25em)
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
  font: ("DejaVu Sans Mono", "FZHei-B01S")
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
    counter(footnote).update(0)

    locate(loc => {
      // TODO: not display on pages including first-level headings
      let new_chapter = query(
        selector(<break>),
        loc
      )

      if new_chapter == () {
        if calc.odd(loc.page()) {
          let elems = query(
            selector(heading.where(level: 2)).before(loc),
            loc,
          )

          if elems == () {
            [PLACEHOLDER]
          } else {
            [
              #set text(size: 9pt, number-type: "old-style", number-width: "tabular")
              // TODO: correct number format of section
              #emph[#counter(heading).display()#h(1em)#smallcaps(elems.last().body)]
              #h(1fr)
              #counter(page).display("1")
            ]
          }
        } else {
          let elems = query(
            selector(heading.where(level: 1)).before(loc),
            loc,
          )

          [
            #set text(9pt)
            #counter(page).display("1")
            #h(1fr)
            第~#counter(heading.where(level: 1)).display("1")~章#h(1em)#elems.last().body
          ]
        }
      }
    })
  }
)

#show heading.where(level: 1): it => [
  #pagebreak(to: "odd")
  #block(
    above: 0em,
    below: 0em,
  )[
    #set text(
      size: 36pt,
      font: ("Linux Biolinum", "FZHei-B01S"),
      weight: 551,
    )
    #set par(
      first-line-indent: 0em,
    )

    #v(4em)
    第~#counter(heading).display()~章
    #v(1em)
    #it.body
    #v(4em)
  ]
]

#set enum(indent: 2em, body-indent)
#show enum: set block(spacing: 1.25em)

// TODO: full-width bullet
#set list(indent: 2em, body-indent: 0em)
#show list: set block(spacing: 1.25em)

#set footnote(numbering: "[1]")
#show footnote: set text(fill: cmyk(0%, 100%, 0%, 0%))
#show footnote.entry: it => {
  let loc = it.note.location()
  numbering("1. ", ..counter(footnote).at(loc))
  it.note.body
}

#include "includes.typ"
/* END main */
