#import "settings.typ": *

#let DiagramDocument(body) = [
  #set text(
    font: font_body,
    size: body_text_size,
    fill: color_text,
    weight: 300,
  )

  #set page(
    width: diagram_page_width,
    height: diagram_page_height,
    margin: diagram_margin,
    fill: color_page,
  )

  #set par(
    first-line-indent: 0pt,
    justify: false,
    leading: 0.45em,
    spacing: 0.55em,
  )

  #set table(stroke: 0.4pt)

  #body
]
