#import "settings.typ": *

//  Document =====================================================
#let Document(columns_count: 1, body) = [
  // Global text ===============================================
  #set text(
    font: font_body,
    size: body_text_size,
    spacing: 100%,
    weight: 300,
  )

  // Page==========================================
  #set page(
    paper: presentation_paper,
    margin: (top: 0cm, outside: 0cm, inside: 0cm, bottom: 0cm),
    columns: columns_count,
  )

  // Columns ==========================================
  #set columns(gutter: 0.7em)

  // Sets the sections titles ============================
  #set heading(numbering: "1.")
  // #show heading.where(level: 1): set align(center)
  // #show heading.where(level: 2): set align(center)
  #show heading: set text(fill: black)

  #show heading: it => block(below: 5pt, above: 10pt)[
    #set par(first-line-indent: 0em, justify: false)
    #text(size: body_headers_Mtwo_counter_size, fill: color_main)[#counter(heading).display(it.numbering)]
    #h(0.4em, weak: true)
    #text(size: body_text_size, fill: color_main)[#it.body]
  ]

  #show heading.where(level: 1): it => [
    #text(size: 14pt, fill: color_main, weight: "semibold")[#upper(it.body)]

  ]
  #show heading.where(level: 2): it => block(below: 10pt, above: 15pt)[
    #text(size: 12pt, fill: color_main, [#counter(heading).display(it.numbering)])
    #text(size: 13pt, fill: color_main)[#it.body]
  ]
  #show heading.where(level: 3): it => block(below: 10pt, above: 15pt)[
    #text(size: body_text_size, fill: color_main)[#counter(heading).display((it.numbering))]
    #text(size: body_text_size, fill: color_main)[#it.body]
  ]

  // Paragraph setup ==========================================
  #set par(
    // first-line-indent: (amount: 10pt, all: true),
    spacing: 1em,
    justify: true,
    leading: 0.5em,
  )
  // Enumerate setup ==========================================
  #set enum(
    spacing: 1em,
    indent: 0.0em,
    body-indent: 0.2em,
    numbering: n => text(size: body_text_size, fill: black)[#n.],
  )

  // Tables setup ==========================================
  #set table(stroke: 0.3pt)

  // Figures setup ==========================================
  #show figure.where(kind: table): set figure(
    numbering: "1",
    supplement: [Tabla],
  )

  #show figure.where(kind: image): set figure(
    numbering: "1",
    supplement: [Imagen],
  )

  // Raw (code) setup==========================================
  #set raw(tab-size: 1, block: true)

  #show raw.where(block: true): it => block[
    #text(font: "JetBrains Mono", size: body_text_code_size)[#it]
  ]

  // Equations setup ========================================
  #show math.equation: it => {
    set text(size: equation_text_size)
    it
  }

  // Referencing setup ====================================
  #set ref()

  #show ref: it => {
    let targt = str(it.target)
    let label_parts = str(it.target).split(":")
    // return targt
    if label_parts.at(0) == "sec" or label_parts.at(0) == "cook" {
      return link(it.target)[#text(fill: color_sec)[#underline(it.element.body, offset: 1pt)]]
    }
    it
  }

  #body
]

