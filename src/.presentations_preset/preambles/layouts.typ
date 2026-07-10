#import "settings.typ": *
#import "elements.typ": slide_frame

#let slide_heading(title) = {
  if title == none {
    return []
  }

  block(width: 100%, below: 18pt)[
    #text(size: slide_title_size, fill: color_main, weight: 600)[#title]
  ]
}

#let slide_note_list(items) = [
  #set par(justify: false)
  #for item in items [
    #block(width: 100%, below: 8pt)[
      #grid(
        columns: (12pt, 1fr),
        gutter: 8pt,
        align: (center + top, left + horizon),
        text(fill: color_main, weight: 700)[-], item,
      )
    ]
  ]
]

#let slide_card(title, body, accent: color_main) = {
  block(
    width: 100%,
    inset: 12pt,
    radius: 4pt,
    fill: color_panel,
    stroke: (paint: color_panel_stroke, thickness: 0.6pt),
  )[
    #text(size: slide_card_title_size, fill: accent, weight: 600)[#title]
    #v(6pt)
    #body
  ]
}

#let slide_metric_card(value, label, detail) = {
  block(
    width: 100%,
    inset: 13pt,
    radius: 4pt,
    fill: color_panel,
    stroke: (paint: color_main, thickness: 0.8pt),
  )[
    #text(size: slide_metric_value_size, fill: color_main, weight: 700)[#value]
    #v(2pt)
    #text(size: slide_card_title_size, weight: 600)[#label]
    #if detail != none [
      #v(4pt)
      #text(size: slide_small_text_size, fill: color_sec)[#detail]
    ]
  ]
}

#let slide_main_title(
  title,
  subtitle: none,
  kicker: none,
  footer_title: none,
) = {
  slide_frame(footer_title: footer_title)[
    #v(1fr)
    #if kicker != none [
      #text(size: 10pt, fill: color_sec, weight: 600)[#upper(kicker)]
      #v(8pt)
    ]
    #text(size: slide_main_title_size, fill: color_main, weight: 700)[#title]
    #if subtitle != none [
      #v(12pt)
      #text(size: slide_subtitle_size, weight: 300)[#subtitle]
    ]
    #v(1.2fr)
  ]
}

#let slide_section(
  title,
  subtitle: none,
  kicker: none,
  footer_title: none,
) = {
  slide_frame(footer_title: footer_title)[
    #v(1fr)
    #if kicker != none [
      #text(size: 10pt, fill: color_sec, weight: 600)[#upper(kicker)]
      #v(8pt)
    ]
    #text(size: slide_section_title_size, fill: color_main, weight: 700)[#title]
    #if subtitle != none [
      #v(10pt)
      #text(size: slide_subtitle_size, weight: 300)[#subtitle]
    ]
    #v(1fr)
  ]
}

#let slide_bullets(
  title,
  items: (),
  lead: none,
  footer_title: none,
) = {
  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #if lead != none [
      #block(width: 100%, below: 12pt)[#lead]
    ]
    #slide_note_list(items)
  ]
}

#let slide_two_cols(
  title,
  left: [],
  right: [],
  columns: (1fr, 1fr),
  gutter: slide_column_gutter,
  footer_title: none,
) = {
  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #grid(
      columns: columns,
      gutter: gutter,
      block(width: 100%)[#left],
      block(width: 100%)[#right],
    )
  ]
}

#let slide_figure_text(
  title,
  figure: [],
  notes: (),
  figure_side: "left",
  figure_height: 244pt,
  footer_title: none,
) = {
  let figure_block = block(
    width: 100%,
    height: figure_height,
    inset: 14pt,
    fill: color_panel,
    stroke: (paint: color_panel_stroke, thickness: 0.6pt),
  )[
    #align(center + horizon)[#figure]
  ]

  let notes_block = block(width: 100%)[#slide_note_list(notes)]

  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #if figure_side == "right" {
      grid(
        columns: (1.05fr, 0.95fr),
        gutter: slide_column_gutter,
        notes_block, figure_block,
      )
    } else {
      grid(
        columns: (0.95fr, 1.05fr),
        gutter: slide_column_gutter,
        figure_block, notes_block,
      )
    }
  ]
}

#let slide_big_figure(
  title,
  figure: [],
  caption: none,
  figure_height: 258pt,
  footer_title: none,
) = {
  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #grid(
      columns: (1fr,),
      rows: (figure_height, auto),
      gutter: 8pt,
      block(width: 100%, height: figure_height)[
        #align(center + horizon)[#figure]
      ],
      if caption == none {
        []
      } else {
        align(center)[
          #text(size: slide_caption_size, fill: color_sec)[#caption]
        ]
      },
    )
  ]
}

#let slide_cards(
  title,
  cards: (),
  columns: (1fr, 1fr, 1fr),
  gutter: 14pt,
  footer_title: none,
) = {
  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #grid(
      columns: columns,
      gutter: gutter,
      ..cards.map(card => slide_card(card.at(0), card.at(1))),
    )
  ]
}

#let slide_metrics(
  title,
  metrics: (),
  columns: (1fr, 1fr, 1fr),
  gutter: 14pt,
  footer_title: none,
) = {
  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #grid(
      columns: columns,
      gutter: gutter,
      ..metrics.map(metric => slide_metric_card(metric.at(0), metric.at(1), metric.at(2))),
    )
  ]
}

#let slide_compare(
  title,
  left_title,
  left,
  right_title,
  right,
  verdict: none,
  footer_title: none,
) = {
  slide_frame(title: title, footer_title: footer_title)[
    #slide_heading(title)
    #grid(
      columns: (1fr, 1fr),
      gutter: slide_column_gutter,
      slide_card(left_title, left), slide_card(right_title, right),
    )
    #if verdict != none [
      #v(10pt)
      #block(
        width: 100%,
        inset: 10pt,
        radius: 4pt,
        fill: luma(252),
        stroke: (paint: color_main, thickness: 0.7pt),
      )[
        #text(size: slide_small_text_size, fill: color_sec, weight: 600)[CONCLUSION]
        #h(8pt)
        #verdict
      ]
    ]
  ]
}

// Compatibility alias while experimenting with older examples.
#let slide_title_two_cols() = slide_two_cols(
  [Two columns],
  left: [Left column],
  right: [Right column],
)
