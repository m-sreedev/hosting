#import "@preview/ilm:2.1.1": *


#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#let note = note.with(text-style: (font: "Libertinus Serif"))

#show: marginalia.setup.with(
  inner: ( far: 5mm, width: 15mm, sep: 5mm ),
  outer: ( far: 10mm, width: 35mm, sep: 15mm ),
  top: 2.5cm,
  bottom: 2.5cm,
  book: false,
  clearance: 12pt,
)


#set text(lang: "en")

#show: ilm.with(
  title: [Cell Differentiation Task],
  authors: "Sreedev M ",
  abstract: [

  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

= Setup
