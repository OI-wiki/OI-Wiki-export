// BEGIN libs
#import "tablex.typ": tablex, hlinex
// END libs

// BEGIN macros
#let antiflash-white = cmyk(0%, 0%, 0%, 10%)
#let horizontalrule = line(start: (25%, 0%), end: (75%, 0%))
#let blockquote(content) = block(width: 100%, fill: antiflash-white, inset: (top: 1em, right: 4em, bottom: 1em, left: 4em), content)
// END macros

= Heading 1
<heading-1>
== Heading 2
<heading-2>
=== Heading 3
<heading-3>
==== Heading 4
<heading-4>
===== Heading 5
<heading-5>
====== Heading 6
<heading-6>
== Emphasis, strong emphasis, and very strong emphasis
<emphasis-strong-emphasis-and-very-strong-emphasis>
An #emph[emphasis]. A #strong[strong emphasis]. A #strong[#emph[very
strong emphasis]].

More #emph[emphasis] test. Even more #strong[strong emphasis] test. Even
more #strong[#emph[very strong emphasis]] test.

Or try #strong[#emph[mixed style very strong emphasis]]. This is an
#emph[#strong[alternative]]. This is another
#emph[#strong[alternative]]. This is one more
#strong[#emph[alternative]].

== Crossed-out texts
<crossed-out-texts>
This text is #strike[crossed out].

== Escape characters, ordered and unordered lists
<escape-characters-ordered-and-unordered-lists>
These are all 10 escape characters reserved by LaTeX:

- \_
- &
- \\
- ~
- ^
- \#
- %
- {
- }
- \$

This is an ordered lists containing the same items:

+ \_
+ &
+ \\
+ ~
+ ^
+ \#
+ %
+ {
+ }
+ \$

With starting numbering other than 1:

#block[
#set enum(numbering: "1.", start: 6)
+ \_
+ &
+ \\
+ ~
]

This is another test: A paragraph containing HTML escape entity and
LaTeX\_escape\_characters: AT&T; © \< 3 & 5 \= 10 \\ ~

== Inline code and code blocks
<inline-code-and-code-blocks>
This is an `inline code`, printed with typewriter typeset.

This is a `code block` written in C++:

```cpp
#include <iostream>
using namespace std;

int main() {
    int var_with_underscore = 0;
    ++var_with_underscore;
    cout << var_with_underscore << endl;
    return 0;
}
```

This is a `plain text` printed in typewriter style:

```
1 2 3
4 5 6
#include <iostream>
int note_that_the_int_before_should_not_highlight;
```

Or simply omit the `text` format indicator:

```
This is another plain text block
1 2 3
4 5 6
#include <iostream>
int note_that_the_int_before_should_not_highlight;
this line is soooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo long that it just cannnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn't be fitted in a single line, even a single word cannot either
```

== Separators
<separators>
Below is a horizontal line, half width of the whole page:

#horizontalrule

And you can write something after this.

== Blockquotes
<blockquotes>
A nested blockquote is as follows:

#blockquote[
This is a blockquote.

#blockquote[
An nested blockquote.

Continue the nested blockquote.
]

The nested blockquote exits.
]

== Line Breaks and footnotes
<line-breaks-and-footnotes>
This is a line, \
after a line break,#super[1] \
to the third line.#super[2]

Note that the paragraph above contains two note marks pointing to the
same endnote.

This is a new paragraph.

== Links
<links>
#link("https://example.com")[alpha]

#link("https://example.com")

#link("https://example.com/a_very_very_very_looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong_link")[https://example.com/a\_very\_very\_very\_looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong\_link]

Here we define and use a link reference:
#link("https://example.com")[alpha]

== Images
<images>
gif:

#image("exampleg.gif")

svg:

#image("examples.svg")

png:

#figure([#image("examplep.png")],
  caption: [
    png
  ]
)

jpg:

#figure([#image("examplej.jpg")],
  caption: [
    jpg
  ]
)

== Tables
<tables>
Normal table:

#tablex(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: (col, row) => (center,left,right,center,).at(col),
  inset: 6pt,
  auto-lines: false,

  hlinex(),
  [h1], [h2], [h3], [h4],
  hlinex(stroke: .5pt),
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [8],
  hlinex(),
)

Table with different items contained in rows:

#tablex(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: (col, row) => (center,left,right,center,).at(col),
  inset: 6pt,
  auto-lines: false,

  hlinex(),
  [h1], [h2], [h3], [h4],
  hlinex(stroke: .5pt),
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [],
  hlinex(),
)

Table with no alignment specified and one line containing too many
cells:

#tablex(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: (col, row) => (center,center,center,center,).at(col),
  inset: 6pt,
  auto-lines: false,

  hlinex(),
  [h1], [h2], [h3], [h4],
  hlinex(stroke: .5pt),
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [8],
  hlinex(),
)

== Math
<math>
This is a math test: $1 plus 1 eq 2$.

This is a display math:

$ sum_(n eq 1)^(plus oo) 1 / n^2 eq pi^2 / 6 $

== Endnotes
<endnotes>
