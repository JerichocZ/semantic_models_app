#import "settings.typ": *
#import "common_functions.typ": field
#import "alignment_model.typ": normalize_recipe
#import "elements.typ": constellation_container, constellation_dynamic_width, legend_panel, author_panel, comments_panel, anchor_debug_panel, direct_links_panel, link_blocks_panel, direct_links_for_scope, direct_pipe_between_levels, direct_pipe_slot, direct_pipe_total_width, direct_arrows_overlay, direct_arrow_origin_label

#let page_title(metadata, width: diagram_content_width) = [
  #block(width: width)[
    #grid(
      columns: (1fr, auto),
      gutter: 12pt,
      align: (left + horizon, right + horizon),
      [
        #text(size: diagram_title_size, fill: color_main, weight: 700)[#metadata.title]
        #v(3pt)
        #text(size: diagram_subtitle_size, fill: color_muted)[#metadata.subtitle]
      ],
      [
        #text(size: diagram_label_size, fill: color_muted, weight: 700)[TYPE]
        #h(5pt)
        #text(size: small_text_size, fill: color_sec, weight: 600)[#metadata.diagram_type]
      ],
    )
  ]
]

#let diagnostics_panel(diagnostics) = {
  if diagnostics.len() == 0 {
    return []
  }

  block(
    width: side_panel_width,
    inset: panel_inset,
    radius: block_radius,
    fill: color_panel,
    stroke: (paint: color_panel_stroke, thickness: 0.6pt),
  )[
    #text(size: small_text_size, fill: color_sec, weight: 700)[Diagnostics]
    #v(6pt)
    #for item in diagnostics [
      #text(size: small_text_size, fill: color_muted)[#item.code]
      #v(2pt)
      #text(size: small_text_size)[#item.message]
      #v(6pt)
    ]
  ]
}

#let diagram_empty_state() = [
  #block(
    width: 100%,
    inset: 16pt,
    fill: color_panel,
    stroke: (paint: color_panel_stroke, thickness: 0.6pt),
  )[
    No blocks are defined for this diagram.
  ]
]

#let blocks_for_constellation(resolved, constellation_id) = {
  resolved.blocks
    .filter(block_data => block_data.constellation == constellation_id)
    .sorted(key: block_data => block_data.order)
}

#let level_constellations(resolved, level) = {
  resolved.constellations
    .filter(constellation => constellation.level == level)
    .sorted(key: constellation => constellation.order)
}

#let level_column(
  resolved,
  level,
  width: layout_column_width,
  data_type_abstractions: (),
  links: (),
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
) = [
  #block(width: width)[
    #text(size: diagram_label_size, fill: color_muted, weight: 700)[LEVEL #level]
    #v(6pt)
    #let constellations_at_level = level_constellations(resolved, level)
    #if constellations_at_level.len() == 0 [
      #text(size: small_text_size, fill: color_muted)[No constellations.]
    ] else [
      #for index in range(0, constellations_at_level.len()) [
        #if index > 0 [
          #v(layout_constellation_gap)
        ]

        #let constellation = constellations_at_level.at(index)
        #constellation_container(
          constellation,
          blocks_for_constellation(resolved, constellation.id),
          data_type_abstractions: data_type_abstractions,
          links: links,
          show_anchor_debug: show_anchor_debug,
          visible_block_ids: visible_block_ids,
          link_scope: link_scope,
          width: width,
        )
      ]
    ]
  ]
]

#let level_dynamic_width(resolved, level) = {
  let widths = level_constellations(resolved, level).map(constellation => {
    constellation_dynamic_width(
      blocks_for_constellation(resolved, constellation.id),
      resolved.links,
    )
  })

  if widths.len() == 0 {
    layout_column_width
  } else {
    widths.fold(layout_column_width, calc.max)
  }
}

#let info_column(
  metadata,
  resolved: none,
  legend_terms: (),
  data_type_abstractions: (),
  diagnostics: (),
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
) = [
  #block(width: side_panel_width)[
    #author_panel(metadata)
    #v(10pt)
    #legend_panel(legend_terms, data_type_abstractions: data_type_abstractions)
    #if resolved != none and direct_links_for_scope(resolved, visible_block_ids: visible_block_ids).len() > 0 [
      #v(10pt)
      #direct_links_panel(resolved, visible_block_ids: visible_block_ids)
    ]
    #if resolved != none [
      #v(10pt)
      #link_blocks_panel(resolved)
    ]
    #if show_anchor_debug and resolved != none [
      #v(10pt)
      #anchor_debug_panel(resolved)
    ]
    #v(10pt)
    #comments_panel(metadata)
    #if diagnostics.len() > 0 [
      #v(10pt)
      #diagnostics_panel(diagnostics)
    ]
  ]
]

#let alignment_columns(
  resolved,
  legend_terms: (),
  data_type_abstractions: (),
  show_anchor_debug: layout_show_anchor_debug,
  link_scope: "general",
) = {
  let levels = resolved.layout.levels
  let columns = ()
  let cells = ()
  let visible_block_ids = resolved.blocks.map(block_data => block_data.id)
  let pipe_width = direct_pipe_total_width(resolved, levels, visible_block_ids: visible_block_ids)
  let level_widths = levels.map(level => level_dynamic_width(resolved, level))
  let diagram_width = alignment_content_width(
    levels.len(),
    include_info: false,
    pipe_width: pipe_width,
    level_widths: level_widths,
  )

  for index in range(0, levels.len()) {
    let level = levels.at(index)
    let level_width = level_widths.at(index)
    columns.push(level_width)
    cells.push(level_column(
      resolved,
      level,
      width: level_width,
      data_type_abstractions: data_type_abstractions,
      links: resolved.links,
      show_anchor_debug: show_anchor_debug,
      visible_block_ids: visible_block_ids,
      link_scope: link_scope,
    ))

    if index < levels.len() - 1 {
      let pipe = direct_pipe_between_levels(
        resolved,
        level,
        levels.at(index + 1),
        visible_block_ids: visible_block_ids,
      )

      columns.push(layout_column_gap / 2)
      cells.push([])
      columns.push(pipe.width)
      cells.push(direct_pipe_slot(pipe, link_scope: link_scope))
      columns.push(layout_column_gap / 2)
      cells.push([])
    }
  }

  columns.push(layout_column_gap)
  cells.push([])
  columns.push(side_panel_width)
  cells.push(info_column(
    resolved.metadata,
    resolved: resolved,
    legend_terms: legend_terms,
    data_type_abstractions: data_type_abstractions,
    diagnostics: resolved.diagnostics,
    show_anchor_debug: show_anchor_debug,
    visible_block_ids: visible_block_ids,
  ))

  [
    #place(top + left)[
      #box(width: 0pt, height: 0pt)[]
      #direct_arrow_origin_label(link_scope)
    ]
    #grid(
      columns: columns,
      gutter: 0pt,
      align: (left + top,),
      ..cells,
    )
    #place(top + left)[
      #direct_arrows_overlay(
        resolved,
        visible_block_ids: visible_block_ids,
        link_scope: link_scope,
        width: diagram_width,
      )
    ]
  ]
}

#let diagram_general_page(
  metadata,
  constellations: (),
  blocks: (),
  links: (),
  legend_terms: (),
  data_type_abstractions: (),
  show_anchor_debug: layout_show_anchor_debug,
) = {
  if blocks.len() == 0 {
    return diagram_empty_state()
  }

  let resolved = normalize_recipe((
    metadata: metadata,
    constellations: constellations,
    blocks: blocks,
    links: links,
  ))
  let pipe_width = direct_pipe_total_width(resolved, resolved.layout.levels)
  let level_widths = resolved.layout.levels.map(level => level_dynamic_width(resolved, level))
  let content_width = alignment_content_width(
    resolved.layout.levels.len(),
    pipe_width: pipe_width,
    level_widths: level_widths,
  )

  [
    #block(width: content_width)[
      #page_title(metadata, width: content_width)
      #v(18pt)
      #alignment_columns(
        resolved,
        legend_terms: legend_terms,
        data_type_abstractions: data_type_abstractions,
        show_anchor_debug: show_anchor_debug,
        link_scope: "general",
      )
    ]
  ]
}

#let diagram_constellation_page(
  metadata,
  constellation_id,
  constellations: (),
  blocks: (),
  links: (),
  legend_terms: (),
  data_type_abstractions: (),
  show_anchor_debug: layout_show_anchor_debug,
) = {
  if blocks.len() == 0 {
    return diagram_empty_state()
  }

  let resolved = normalize_recipe((
    metadata: metadata,
    constellations: constellations,
    blocks: blocks,
    links: links,
  ))
  let constellation = resolved.constellations.find(item => item.id == constellation_id)
  let constellation_width = if constellation == none {
    layout_column_width
  } else {
    constellation_dynamic_width(blocks_for_constellation(resolved, constellation.id), resolved.links)
  }
  let content_width = constellation_width + layout_column_gap + side_panel_width

  if constellation == none {
    return [
      #block(width: content_width)[
        #page_title(metadata, width: content_width)
        #v(18pt)
        #diagnostics_panel((
          (code: "constellation-not-found", message: [Constellation `#constellation_id` was not found.]),
        ))
      ]
    ]
  }
  let visible_blocks = blocks_for_constellation(resolved, constellation.id)
  let visible_block_ids = visible_blocks.map(block_data => block_data.id)

  [
    #block(width: content_width)[
      #page_title(metadata, width: content_width)
      #v(18pt)
      #grid(
        columns: (constellation_width, side_panel_width),
        gutter: layout_column_gap,
        align: (left + top, left + top),
        [
          #text(size: diagram_label_size, fill: color_muted, weight: 700)[CONSTELLATION #constellation.id]
          #v(6pt)
          #constellation_container(
            constellation,
            visible_blocks,
            data_type_abstractions: data_type_abstractions,
            links: resolved.links,
            show_anchor_debug: show_anchor_debug,
            visible_block_ids: visible_block_ids,
            link_scope: "constellation:" + constellation.id,
            width: constellation_width,
          )
        ],
        info_column(
          resolved.metadata,
          resolved: resolved,
          legend_terms: legend_terms,
          data_type_abstractions: data_type_abstractions,
          diagnostics: resolved.diagnostics,
          show_anchor_debug: show_anchor_debug,
          visible_block_ids: visible_block_ids,
        ),
      )
    ]
  ]
}
