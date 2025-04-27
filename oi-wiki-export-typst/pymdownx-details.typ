#import "@preview/gentle-clues:1.2.0": *
#import "constants.typ": *
/* BEGIN constants */
#let note-color = (bright: cmyk(10%, 5%, 0%, 0%), dark: cmyk(40%, 20%, 0%, 0%))
#let abstract-color = (
  bright: cmyk(10%, 0%, 0%, 0%),
  dark: cmyk(40%, 0%, 0%, 0%),
)
#let info-color = (bright: cmyk(10%, 0%, 5%, 0%), dark: cmyk(40%, 0%, 20%, 0%))
#let tip-color = (bright: cmyk(10%, 0%, 10%, 0%), dark: cmyk(40%, 0%, 40%, 0%))
#let success-color = (
  bright: cmyk(5%, 0%, 10%, 0%),
  dark: cmyk(20%, 0%, 40%, 0%),
)
#let question-color = (
  bright: cmyk(0%, 0%, 10%, 0%),
  dark: cmyk(0%, 0%, 40%, 0%),
)
#let warning-color = (
  bright: cmyk(0%, 5%, 10%, 0%),
  dark: cmyk(0%, 20%, 40%, 0%),
)
#let failure-color = (
  bright: cmyk(0%, 10%, 10%, 0%),
  dark: cmyk(0%, 40%, 40%, 0%),
)
#let danger-color = (
  bright: cmyk(0%, 10%, 5%, 0%),
  dark: cmyk(0%, 40%, 20%, 0%),
)
#let bug-color = (bright: cmyk(0%, 10%, 0%, 0%), dark: cmyk(0%, 40%, 0%, 0%))
#let example-color = (
  bright: cmyk(5%, 10%, 0%, 0%),
  dark: cmyk(20%, 40%, 0%, 0%),
)
#let quote-color = (
  bright: cmyk(10%, 10%, 0%, 0%),
  dark: cmyk(40%, 40%, 0%, 0%),
)

#let note-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2m3.1 5.07c.14 0 .28.05.4.16l1.27 1.27c.23.22.23.57 0 .78l-1 1-2.05-2.05 1-1c.1-.11.24-.16.38-.16m-1.97 1.74 2.06 2.06-6.06 6.06H7.07v-2.06l6.06-6.06Z\"/></svg>"))
#let abstract-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M17 9H7V7h10m0 6H7v-2h10m-3 6H7v-2h7M12 3a1 1 0 0 1 1 1 1 1 0 0 1-1 1 1 1 0 0 1-1-1 1 1 0 0 1 1-1m7 0h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2Z\"/></svg>"))
#let info-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M13 9h-2V7h2m0 10h-2v-6h2m-1-9A10 10 0 0 0 2 12a10 10 0 0 0 10 10 10 10 0 0 0 10-10A10 10 0 0 0 12 2Z\"/></svg>"))
#let tip-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M17.66 11.2c-.23-.3-.51-.56-.77-.82-.67-.6-1.43-1.03-2.07-1.66C13.33 7.26 13 4.85 13.95 3c-.95.23-1.78.75-2.49 1.32-2.59 2.08-3.61 5.75-2.39 8.9.04.1.08.2.08.33 0 .22-.15.42-.35.5-.23.1-.47.04-.66-.12a.58.58 0 0 1-.14-.17c-1.13-1.43-1.31-3.48-.55-5.12C5.78 10 4.87 12.3 5 14.47c.06.5.12 1 .29 1.5.14.6.41 1.2.71 1.73 1.08 1.73 2.95 2.97 4.96 3.22 2.14.27 4.43-.12 6.07-1.6 1.83-1.66 2.47-4.32 1.53-6.6l-.13-.26c-.21-.46-.77-1.26-.77-1.26m-3.16 6.3c-.28.24-.74.5-1.1.6-1.12.4-2.24-.16-2.9-.82 1.19-.28 1.9-1.16 2.11-2.05.17-.8-.15-1.46-.28-2.23-.12-.74-.1-1.37.17-2.06.19.38.39.76.63 1.06.77 1 1.98 1.44 2.24 2.8.04.14.06.28.06.43.03.82-.33 1.72-.93 2.27Z\"/></svg>"))
#let success-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M21 7 9 19l-5.5-5.5 1.41-1.41L9 16.17 19.59 5.59 21 7Z\"/></svg>"))
#let question-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"m15.07 11.25-.9.92C13.45 12.89 13 13.5 13 15h-2v-.5c0-1.11.45-2.11 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41a2 2 0 0 0-2-2 2 2 0 0 0-2 2H8a4 4 0 0 1 4-4 4 4 0 0 1 4 4 3.2 3.2 0 0 1-.93 2.25M13 19h-2v-2h2M12 2A10 10 0 0 0 2 12a10 10 0 0 0 10 10 10 10 0 0 0 10-10c0-5.53-4.5-10-10-10Z\"/></svg>"))
#let warning-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M13 14h-2V9h2m0 9h-2v-2h2M1 21h22L12 2 1 21Z\"/></svg>"))
#let failure-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M19 6.41 17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41Z\"/></svg>"))
#let danger-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"m11.5 20 4.86-9.73H13V4l-5 9.73h3.5V20M12 2c2.75 0 5.1 1 7.05 2.95C21 6.9 22 9.25 22 12s-1 5.1-2.95 7.05C17.1 21 14.75 22 12 22s-5.1-1-7.05-2.95C3 17.1 2 14.75 2 12s1-5.1 2.95-7.05C6.9 3 9.25 2 12 2Z\"/></svg>"))
#let bug-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M11 13h2v1h-2v-1m10-8v6c0 5.5-3.8 10.7-9 12-5.2-1.3-9-6.5-9-12V5l9-4 9 4m-4 5h-2.2c-.2-.6-.6-1.1-1.1-1.5l1.2-1.2-.7-.7L12.8 8H12c-.2 0-.5 0-.7.1L9.9 6.6l-.8.8 1.2 1.2c-.5.3-.9.8-1.1 1.4H7v1h2v1H7v1h2v1H7v1h2.2c.4 1.2 1.5 2 2.8 2s2.4-.8 2.8-2H17v-1h-2v-1h2v-1h-2v-1h2v-1m-6 2h2v-1h-2v1Z\"/></svg>"))
#let example-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M7 2v2h1v14a4 4 0 0 0 4 4 4 4 0 0 0 4-4V4h1V2H7m4 14c-.6 0-1-.4-1-1s.4-1 1-1 1 .4 1 1-.4 1-1 1m2-4c-.6 0-1-.4-1-1s.4-1 1-1 1 .4 1 1-.4 1-1 1m1-5h-4V4h4v3Z\"/></svg>"))
#let quote-icon = image(bytes("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path d=\"M14 17h3l2-4V7h-6v6h3M6 17h3l2-4V7H5v6h3l-2 4Z\"/></svg>"))
/* END constants */

#let details(type: str, unwrap: false, ..items) = {
  let items = items.pos()
  if items.len() != 2 {
    panic("#details receives exactly two content blocks")
  }
  let (title, content) = items
  let (color, icon) = if type == "abstract" {
    (abstract-color, abstract-icon)
  } else if type == "info" {
    (info-color, info-icon)
  } else if type == "tip" {
    (tip-color, tip-icon)
  } else if type == "success" {
    (success-color, success-icon)
  } else if type == "question" {
    (question-color, question-icon)
  } else if type == "warning" {
    (warning-color, warning-icon)
  } else if type == "failure" {
    (failure-color, failure-icon)
  } else if type == "danger" {
    (danger-color, danger-icon)
  } else if type == "bug" {
    (bug-color, bug-icon)
  } else if type == "example" {
    (example-color, example-icon)
  } else if type == "quote" {
    (quote-color, quote-icon)
  } else {
    (note-color, note-icon)
  }
  clue(
    title: title,
    icon: icon,
    accent-color: color.dark,
    title-font: sans-font,
    breakable: true,
    content,
  )
}
