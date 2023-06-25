/* BEGIN macros */
#let warning-orange = cmyk(0%, 5%, 10%, 0%)
#let info-blue = cmyk(10%, 5%, 0%, 0%)
/* END macros */

/* BEGIN meta formatting */
#set page(
  paper: "a4",
  margin: (top: 1in, right: .5in, bottom: 1in, left: .5in),
)

#set text(
  lang: "zh",
)
/* END meta formatting */

/* BEGIN cover */
#v(2fr)

#text(
  size: 28pt,
  font: ("Public Sans", "Noto Sans CJK SC"),
  weight: 551,
)[OI Wiki (Beta)]

#text(
  size: 14pt,
  font: ("Source Serif 4 SmText", "Noto Serif CJK SC"),
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
  font: ("Source Serif 4 SmText", "Noto Serif CJK SC"),
)

#set par(
  leading: 1em,
  first-line-indent: 2em,
)

#set block(
  spacing: 1em,
)

#set strong(delta: 0)
#show strong: set text(
  font: ("Public Sans", "Noto Sans CJK SC"),
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set block(spacing: 1.25em)
#show heading: set text(
  font: ("Public Sans", "Noto Sans CJK SC"),
  weight: 551,
)
#show heading.where(level: 1): set text(size: 21pt)
#show heading.where(level: 2): set text(size: 18pt)
#show heading.where(level: 3): set text(size: 16pt)
#show heading.where(level: 4): set text(size: 15pt)
#show heading.where(level: 5): set text(size: 14pt)
#show heading.where(level: 6): set text(size: 12pt)

#show emph: set text(
  font: ("Source Serif 4 SmText", "KaiTi")
)

#show raw: set text(
  font: ("Spline Sans Mono", "Noto Sans CJK SC"),
  size: 9pt,
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
  header: [
    #set text(9pt)
    #counter(page).display("1")
    #h(1fr)
  ]
)

#show heading.where(level: 1): it => block(
  above: 0em,
  below: 0em,
)[
  #set text(
    size: 21pt,
    font: ("Public Sans", "Noto Sans CJK SC"),
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

#include "example.typ"
/* END main */
