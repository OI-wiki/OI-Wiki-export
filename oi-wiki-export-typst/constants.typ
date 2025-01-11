/* Constants of oi-wiki-export-typst */

// Text size of document body.
#let ROOT_EM = 10pt

// Default text size of raw block is 0.8rem
// So we scale it back a little (equivalent to 9pt)
// issue: https://github.com/typst/typst/issues/1331
#let RAW_EM = 1.1em
#let en-font = "Crimson Text"

// Page dimensions minus margin
#let serif-font = (
  en-font,
  "Noto Serif CJK SC",
)
#let sans-font = (
  en-font,
  "Noto Sans CJK SC",
)
#let emph-font = (en-font, "LXGW Wenkai")
#let raw-font = ("DejaVu Sans Mono", "Noto Sans CJK SC")
#let math-font = (
  "New Computer Modern Math",
  "Noto Serif CJK SC",
)
