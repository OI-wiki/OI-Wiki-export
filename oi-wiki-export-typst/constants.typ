/* Constants of oi-wiki-export-typst */

// Text size of document body.
#let ROOT_EM = 10pt

// Default text size of raw block is 0.8rem
// So we scale it back a little (equivalent to 9pt)
// issue: https://github.com/typst/typst/issues/1331
#let RAW_EM = 1.125em

// Page dimensions minus margin
#let VISIBLE_WIDTH = 21cm - 1in
#let VISIBLE_HEIGHT = 29.7cm - 1.5in
