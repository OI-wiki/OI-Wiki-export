/* BEGIN meta formatting */
#set page(
  paper: "a4",
  margin: (top: 1in, right: .5in, bottom: .5in, left: .5in),
)

#set text(
  lang: "zh",
)
/* END meta formatting */

/* BEGIN cover */
#v(2fr)

#text(
  size: 36pt,
  font: ("Linux Biolinum O", "FZHei-B01S"),
  weight: 551,
)[OI Wiki (Beta)]

#text(
  size: 18pt,
  font: ("Linux Libertine O", "FZShuSong-Z01S"),
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
  font: ("Linux Libertine O", "FZShuSong-Z01S"),
)

#set par(
  leading: 0.8em,
  first-line-indent: 2em,
)

#set block(
  spacing: 1em,
)

#set strong(delta: 0)
#show strong: set text(
  font: ("Linux Biolinum O", "FZHei-B01S"),
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(spacing: 1.25em)
#show heading: set text(
  font: ("Linux Biolinum O", "FZHei-B01S"),
  weight: 551,
)
#show heading.where(level: 1): set text(size: 36pt)
#show heading.where(level: 2): set text(size: 24pt)
#show heading.where(level: 3): set text(size: 18pt)
#show heading.where(level: 4): set text(size: 15pt)
#show heading.where(level: 5): set text(size: 13.75pt)
#show heading.where(level: 6): set text(size: 12pt)

#show emph: set text(
  font: ("Linux Libertine O", "FZKai-Z03S")
)

#show raw: set text(
  font: ("DejaVu Sans Mono", "FZHei-B01S"),
)
/* END article formatting */

/* BEGIN outline */
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
#set page(
  header: {
    counter(footnote).update(0)

    locate(loc => {
      // TODO: not display on pages including first-level headings
      // let this_heading = query(selector(heading.where(level: 1)).before(loc).and(selector(heading.where(level: 1)).after(loc)), loc)
      // if this_heading == () {
        if calc.odd(loc.page()) {
          let elems = query(
            selector(heading.where(level: 2)).before(loc),
            loc,
          )

          if elems == () {
            [PLACEHOLDER]
          } else {
          [
            #set text(9pt)
            // TODO: correct number format of section
            #emph[#counter(heading.where(level: 2)).display("1.1")#h(1em)#elems.last().body]
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
            第~#counter(heading.where(level: 1)).display("1")~章~#elems.last().body
          ]
        }
      // }
    })
  }
)

#show heading.where(level: 1): it => [
  #pagebreak()
  #block(
    above: 0em,
    below: 0em,
  )[
    #set text(
      size: 36pt,
      font: ("Linux Biolinum O", "FZHei-B01S"),
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

#include "includes.typ"
/* END main */
