#import "settings.typ": *

#let display_value(value) = {
  if value == none {
    [--]
  } else if type(value) == content {
    value
  } else {
    str(value)
  }
}

#let code_value(value) = {
  text(font: font_mono, size: block_code_text_size)[#display_value(value)]
}

#let header_cell(body) = {
  table.cell(
    fill: color_block_section,
    inset: (x: 5pt, y: 4pt),
  )[
    #text(size: diagram_label_size, fill: color_muted, weight: 700)[#body]
  ]
}

#let normal_cell(body) = {
  table.cell(inset: (x: 5pt, y: 4pt))[
    #text(size: small_text_size)[#body]
  ]
}

#let report_section(title, body) = [
  #block(width: 100%, below: 10pt)[
    #text(size: 12pt, fill: color_main, weight: 700)[#title]
    #v(5pt)
    #body
  ]
]

#let summary_cell(body) = {
  block(
    width: 100%,
    inset: (x: 8pt, y: 6pt),
    fill: color_panel,
    stroke: (paint: color_panel_stroke, thickness: 0.5pt),
  )[
    #text(size: small_text_size)[#body]
  ]
}

#let constellations_table(resolved) = {
  let cells = (
    header_cell([ID]),
    header_cell([Title]),
    header_cell([Level]),
    header_cell([Order]),
    header_cell([Column]),
    header_cell([Stack]),
  )

  for constellation in resolved.constellations {
    cells.push(normal_cell(code_value(constellation.id)))
    cells.push(normal_cell(display_value(constellation.title)))
    cells.push(normal_cell(code_value(constellation.level)))
    cells.push(normal_cell(code_value(constellation.order)))
    cells.push(normal_cell(code_value(constellation.layout.column)))
    cells.push(normal_cell(code_value(constellation.layout.stack_order)))
  }

  table(
    columns: (70pt, 110pt, 42pt, 42pt, 48pt, 48pt),
    stroke: (paint: color_block_grid, thickness: 0.35pt),
    ..cells,
  )
}

#let blocks_table(resolved) = {
  let cells = (
    header_cell([ID]),
    header_cell([Const.]),
    header_cell([Level]),
    header_cell([Order]),
    header_cell([Rows]),
  )

  for block_data in resolved.blocks {
    cells.push(normal_cell(code_value(block_data.id)))
    cells.push(normal_cell(code_value(block_data.constellation)))
    cells.push(normal_cell(code_value(block_data.constellation_level)))
    cells.push(normal_cell(code_value(block_data.order)))
    cells.push(normal_cell(code_value(block_data.rows.len())))
  }

  table(
    columns: (112pt, 48pt, 42pt, 42pt, 42pt),
    stroke: (paint: color_block_grid, thickness: 0.35pt),
    ..cells,
  )
}

#let links_table(resolved) = {
  let cells = (
    header_cell([ID]),
    header_cell([Source]),
    header_cell([Target]),
    header_cell([Relation]),
    header_cell([Req.]),
    header_cell([Mode]),
  )

  for link in resolved.links {
    cells.push(normal_cell(code_value(link.id)))
    cells.push(normal_cell(code_value(link.source.block + "." + link.source.row)))
    cells.push(normal_cell(code_value(link.target.block + "." + link.target.row)))
    cells.push(normal_cell(code_value(link.relation)))
    cells.push(normal_cell(code_value(link.requested_mode)))
    cells.push(normal_cell(code_value(link.mode)))
  }

  table(
    columns: (122pt, 120pt, 120pt, 72pt, 48pt, 58pt),
    stroke: (paint: color_block_grid, thickness: 0.35pt),
    ..cells,
  )
}

#let diagnostics_table(resolved) = {
  if resolved.diagnostics.len() == 0 {
    return [No diagnostics.]
  }

  let cells = (
    header_cell([Severity]),
    header_cell([Code]),
    header_cell([Link]),
    header_cell([Message]),
  )

  for item in resolved.diagnostics {
    cells.push(normal_cell(code_value(item.severity)))
    cells.push(normal_cell(code_value(item.code)))
    cells.push(normal_cell(code_value(item.link)))
    cells.push(normal_cell(display_value(item.message)))
  }

  table(
    columns: (54pt, 106pt, 112pt, 260pt),
    stroke: (paint: color_block_grid, thickness: 0.35pt),
    ..cells,
  )
}

#let alignment_contract_report(resolved) = [
  #block(width: 560pt)[
    #text(size: diagram_title_size, fill: color_main, weight: 700)[#resolved.metadata.title]
    #v(3pt)
    #text(size: diagram_subtitle_size, fill: color_muted)[#resolved.metadata.subtitle]
    #v(12pt)
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr),
      gutter: 8pt,
      summary_cell([Constellations: #resolved.constellations.len()]),
      summary_cell([Blocks: #resolved.blocks.len()]),
      summary_cell([Links: #resolved.links.len()]),
      summary_cell([Diagnostics: #resolved.diagnostics.len()]),
    )
    #v(14pt)
    #report_section([Resolved constellations], constellations_table(resolved))
    #report_section([Resolved blocks], blocks_table(resolved))
    #report_section([Resolved links], links_table(resolved))
    #report_section([Diagnostics], diagnostics_table(resolved))
  ]
]
