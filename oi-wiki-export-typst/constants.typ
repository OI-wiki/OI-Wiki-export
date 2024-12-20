/* Constants of oi-wiki-export-typst */

// Text size of document body.
#let ROOT_EM = 10pt

// Default text size of raw block is 0.8rem
// So we scale it back a little (equivalent to 9pt)
// issue: https://github.com/typst/typst/issues/1331
#let RAW_EM = 1.125em

// Page dimensions minus margin
#let serif-font = (
  "New Computer Modern",
  "Noto Serif CJK SC",
  "Source Han Serif SC",
)
#let sans-font = (
  "New Computer Modern",
  "Noto Sans CJK SC",
  "Source Han Sans SC",
)
#let emph-font = ("New Computer Modern", "LXGW Wenkai")
