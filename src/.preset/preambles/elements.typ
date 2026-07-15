#import "@preview/cetz:0.5.2"
#import "settings.typ": *
#import "common_functions.typ": field, attr_text, data_type_text

#let mono(body, fill: color_text, weight: 400) = {
  text(
    font: font_mono,
    size: block_code_text_size,
    fill: fill,
    weight: weight,
  )[#body]
}

#let panel(title, body) = {
  block(
    width: side_panel_width,
    inset: panel_inset,
    radius: block_radius,
    fill: color_panel,
    stroke: (paint: color_panel_stroke, thickness: 0.6pt),
  )[
    #text(size: small_text_size, fill: color_sec, weight: 700)[#title]
    #v(6pt)
    #body
  ]
}

#let legend_entry(key, label) = [
  #grid(
    columns: (42pt, 1fr),
    gutter: 6pt,
    align: (left + horizon, left + horizon),
    mono(key, fill: color_sec, weight: 700),
    text(size: small_text_size)[#label],
  )
  #v(4pt)
]

#let legend_panel(legend_terms, data_type_abstractions: ()) = {
  panel([Legend], [
    #if legend_terms.len() == 0 and data_type_abstractions.len() == 0 [
      #text(size: small_text_size, fill: color_muted)[No legend terms defined.]
    ] else [
      #if legend_terms.len() > 0 [
        #text(size: diagram_label_size, fill: color_muted, weight: 700)[Constraints]
        #v(4pt)
        #for term in legend_terms [
          #legend_entry(term.key, term.label)
        ]
      ]

      #if data_type_abstractions.len() > 0 [
        #if legend_terms.len() > 0 [
          #v(4pt)
        ]
        #text(size: diagram_label_size, fill: color_muted, weight: 700)[Data types]
        #v(4pt)
        #for term in data_type_abstractions [
          #legend_entry(field(term, "legend_key", default: term.key), term.label)
        ]
      ]
    ]
  ])
}

#let author_panel(metadata) = {
  panel([Author], [
    #text(weight: 600)[#metadata.author]
    #v(2pt)
    #text(size: small_text_size, fill: color_muted)[#metadata.company]
    #v(6pt)
    #grid(
      columns: (38pt, 1fr),
      gutter: 6pt,
      text(size: small_text_size, fill: color_muted)[Version],
      text(size: small_text_size)[#metadata.version],
      text(size: small_text_size, fill: color_muted)[Date],
      text(size: small_text_size)[#metadata.date],
    )
  ])
}

#let comments_panel(metadata) = {
  panel([Comments], [
    #text(size: small_text_size)[#metadata.comments]
  ])
}

#let section_cell(label) = {
  table.cell(
    colspan: 3,
    fill: color_block_section,
    inset: (x: 6pt, y: 3.6pt),
  )[
    #text(size: diagram_label_size, fill: color_muted, weight: 700)[#label]
  ]
}

#let visual_cell(body, fill: white, text_fill: color_text, weight: 400) = {
  table.cell(fill: fill, inset: (x: 5pt, y: 3pt))[
    #block(height: layout_row_height)[
      #align(left + horizon)[
        #text(size: block_code_text_size, fill: text_fill, weight: weight, font: font_mono)[#body]
      ]
    ]
  ]
}

#let row_anchor_label(link_scope, anchor_id) = {
  label("anchor:" + link_scope + ":" + anchor_id)
}

#let direct_pipe_label(link_scope, left_level, right_level) = {
  label("direct-pipe:" + link_scope + ":" + str(left_level) + "-" + str(right_level))
}

#let direct_arrow_origin_label(link_scope) = {
  label("direct-arrows:" + link_scope + ":origin")
}

#let inner_direct_pipe_label(link_scope, constellation_id, left_level, right_level) = {
  label("inner-direct-pipe:" + link_scope + ":" + constellation_id + ":" + str(left_level) + "-" + str(right_level))
}

#let inner_direct_arrow_origin_label(link_scope, constellation_id) = {
  label("inner-direct-arrows:" + link_scope + ":" + constellation_id + ":origin")
}

#let anchor_marker(side, anchor_id, visible: layout_show_anchor_debug, link_scope: "general") = {
  if anchor_id == none {
    return []
  }

  let fill = if side == "left" {
    color_anchor_left
  } else if side == "right" {
    color_anchor_right
  } else {
    color_anchor_center
  }

  [
    #box(
      width: layout_anchor_marker_size,
      height: layout_anchor_marker_size,
      fill: if visible { fill } else { none },
      radius: 2pt,
      inset: 0pt,
    )[
      #if visible [
        #align(center + horizon)[
          #let marker = if side == "left" { "L" } else if side == "right" { "R" } else { "C" }
          #text(size: 5.2pt, fill: white, weight: 700)[#marker]
        ]
      ]
    ]
    #row_anchor_label(link_scope, anchor_id)
  ]
}

#let external_row_anchor(side, anchor_id, visible: layout_show_anchor_debug, link_scope: "general") = {
  if anchor_id == none {
    return []
  }

  let fill = if side == "left" { color_anchor_left } else { color_anchor_right }
  let x = if side == "left" {
    layout_link_block_side_width - layout_row_anchor_side_inset
  } else if side == "right-outer" {
    layout_link_block_side_width - layout_row_anchor_side_inset + layout_link_block_outer_port_gap
  } else {
    layout_row_anchor_side_inset
  }
  let y = layout_row_height / 2

  [
    #place(
      left + top,
      dx: x - layout_anchor_marker_size / 2,
      dy: y - layout_anchor_marker_size / 2,
    )[
      #box(
        width: layout_anchor_marker_size,
        height: layout_anchor_marker_size,
        fill: if visible { fill } else { none },
        radius: 2pt,
        inset: 0pt,
      )[
        #if visible [
          #align(center + horizon)[
            #text(size: 5.2pt, fill: white, weight: 700)[#if side == "left" { "L" } else if side == "right-outer" { "R+" } else { "R" }]
          ]
        ]
      ]
    ]
    #place(left + top, dx: x, dy: y)[
      #box(width: 0pt, height: 0pt)[]
      #row_anchor_label(link_scope, anchor_id)
    ]
  ]
}

#let link_block_label(label, role: "source") = {
  let fill = if role == "source" { color_link_block } else { color_panel }
  let stroke_color = if role == "source" { color_link_block_stroke } else { color_panel_stroke }
  let text_color = if role == "source" { color_link_block_text } else { color_muted }

  box(
    width: layout_link_block_width,
    inset: (x: 2.4pt, y: 1.5pt),
    radius: 2pt,
    fill: fill,
    stroke: (paint: stroke_color, thickness: 0.45pt),
  )[
    #text(
      font: font_mono,
      size: layout_link_block_text_size,
      fill: text_color,
      weight: 700,
    )[#label]
  ]
}

#let id_initials(value) = {
  let source = str(value)

  if source.len() <= 3 {
    return source
  }

  let out = ""
  for part in source.split("_") {
    if part.len() > 0 {
      out += part.slice(0, 1)
    }
  }

  if out == "" {
    source
  } else {
    out
  }
}

#let link_block_code(link) = {
  let constellation = if link.target.constellation == none { "" } else { link.target.constellation }
  let block = if link.target.block == none { "" } else { link.target.block }
  let row = if link.target.row == none { "" } else { link.target.row }

  let constellation_code = id_initials(constellation)
  let block_code = if constellation != "" and block.starts-with(constellation + "_") {
    constellation
  } else {
    id_initials(block)
  }

  upper(constellation_code + block_code + id_initials(row))
}

#let row_destination_label(link_scope, block_id, row_id) = {
  label("row:" + link_scope + ":" + block_id + "." + row_id)
}

#let target_is_visible(link_data, visible_block_ids) = {
  visible_block_ids == none or visible_block_ids.contains(link_data.target.block)
}

#let dedupe_link_blocks_by_code(links) = {
  let seen = ()
  let out = ()

  for link in links {
    let code = link_block_code(link)
    if not seen.contains(code) {
      seen.push(code)
      out.push(link)
    }
  }

  out
}

#let link_block_arrow(paint: color_link_arrow) = [
  #box(
    width: layout_link_block_arrow_width,
    height: layout_row_height,
    inset: 0pt,
  )[
    #align(center + horizon)[
      #cetz.canvas(length: 1pt, padding: none, {
        import cetz.draw: *
        line(
          (layout_link_block_arrow_width, 0),
          (0, 0),
          stroke: (paint: paint, thickness: layout_link_block_arrow_stroke),
          mark: (end: "stealth", fill: paint, stroke: paint),
        )
      })
    ]
  ]
]

#let link_block_badge(link_data, role: "source", clickable: false, link_scope: "general") = {
  let code = link_block_code(link_data)
  let fill = if role == "source" { color_link_block } else { color_panel }
  let stroke_color = if role == "source" { color_link_block_stroke } else { color_panel_stroke }
  let text_color = if role == "source" { color_link_block_text } else { color_muted }

  let badge = box(
    width: layout_link_block_badge_width,
    height: layout_link_block_badge_height,
    radius: 2pt,
    fill: fill,
    stroke: (paint: stroke_color, thickness: 0.55pt),
    inset: 0pt,
  )[
    #align(center + horizon)[
      #text(
        font: font_mono,
        size: layout_link_block_code_size,
        fill: text_color,
        weight: 800,
      )[#code]
    ]
  ]

  if role == "source" and clickable {
    link(row_destination_label(link_scope, link_data.target.block, link_data.target.row))[
      #badge
    ]
  } else {
    badge
  }
}

#let link_block_marker(link_data, role: "source", clickable: false, link_scope: "general", arrow_color: color_link_arrow) = {
  let badge = link_block_badge(link_data, role: role, clickable: clickable, link_scope: link_scope)
  let arrow = link_block_arrow(paint: arrow_color)
  let cells = if role == "source" {
    (badge, arrow)
  } else {
    (arrow, badge)
  }
  let columns = if role == "source" {
    (layout_link_block_badge_width, layout_link_block_arrow_width)
  } else {
    (layout_link_block_arrow_width, layout_link_block_badge_width)
  }

  box(
    width: layout_link_block_side_width,
    height: layout_row_height,
    inset: 0pt,
  )[
    #align(center + horizon)[
      #grid(
        columns: columns,
        gutter: layout_link_block_arrow_gap,
        align: (center + horizon, center + horizon),
        ..cells,
      )
    ]
  ]
}

#let link_block_marker_stack(
  links,
  role: "source",
  visible_block_ids: none,
  link_scope: "general",
  arrow_color: color_link_arrow,
) = {
  if links.len() == 0 {
    return []
  }

  stack(
    dir: ttb,
    spacing: 1pt,
    ..links.map(link_data => {
      let clickable = role == "source" and target_is_visible(link_data, visible_block_ids)

      link_block_marker(
        link_data,
        role: role,
        clickable: clickable,
        link_scope: link_scope,
        arrow_color: arrow_color,
      )
    }),
  )
}


#let link_target_label(link) = {
  "-> " + link.target.block + "." + link.target.row
}

#let link_source_label(link) = {
  "<- " + link.source.block + "." + link.source.row
}

#let link_block_stack(links, role: "source") = {
  if links.len() == 0 {
    return []
  }

  stack(
    dir: ttb,
    spacing: 1.4pt,
    ..links.map(link => {
      let label = if role == "source" {
        link_target_label(link)
      } else {
        link_source_label(link)
      }

      link_block_label(label, role: role)
    }),
  )
}

#let link_blocks_for_source(links, block_id, row_id) = {
  links.filter(link => {
    let is_link_block = link.render_mode == "link-block"
    let is_source_block = link.source.block == block_id
    let is_source_row = link.source.row == row_id
    is_link_block and is_source_block and is_source_row
  })
}

#let link_blocks_for_target(links, block_id, row_id) = {
  links.filter(link => {
    let is_link_block = link.render_mode == "link-block"
    let is_target_block = link.target.block == block_id
    let is_target_row = link.target.row == row_id
    is_link_block and is_target_block and is_target_row
  })
}

#let direct_links_for_scope(resolved, visible_block_ids: none) = {
  resolved.links.filter(link_data => {
    let is_direct = link_data.valid and link_data.render_mode == "direct"
    let source_visible = visible_block_ids == none or visible_block_ids.contains(link_data.source.block)
    let target_visible = visible_block_ids == none or visible_block_ids.contains(link_data.target.block)
    is_direct and source_visible and target_visible
  })
}

#let outer_direct_links_for_scope(resolved, visible_block_ids: none) = {
  direct_links_for_scope(resolved, visible_block_ids: visible_block_ids)
    .filter(link_data => link_data.routing_scope == "cross-constellation")
}

#let inner_direct_links_for_constellation(
  resolved,
  constellation_id,
  visible_block_ids: none,
) = {
  direct_links_for_scope(resolved, visible_block_ids: visible_block_ids)
    .filter(link_data => link_data.routing_scope == "internal" and link_data.source.constellation == constellation_id and link_data.target.constellation == constellation_id)
}

#let direct_pipe_links_for_levels(
  resolved,
  left_level,
  right_level,
  visible_block_ids: none,
) = {
  outer_direct_links_for_scope(resolved, visible_block_ids: visible_block_ids).filter(link_data => {
    let source_level = link_data.source.constellation_level
    let target_level = link_data.target.constellation_level

    (source_level != none and target_level != none) and (
      (source_level <= left_level and target_level >= right_level) or
      (target_level <= left_level and source_level >= right_level)
    )
  })
}

#let direct_pipe_width(
  line_count,
  inset: layout_direct_pipe_inset,
  gutter: layout_direct_pipe_gutter,
) = {
  if line_count == 0 {
    0pt
  } else {
    inset * 2 + layout_direct_pipe_line_width * line_count + gutter * (line_count - 1)
  }
}

#let direct_pipe_between_levels(
  resolved,
  left_level,
  right_level,
  visible_block_ids: none,
) = {
  let links = direct_pipe_links_for_levels(
    resolved,
    left_level,
    right_level,
    visible_block_ids: visible_block_ids,
  )

  (
    left_level: left_level,
    right_level: right_level,
    links: links,
    line_count: links.len(),
    width: direct_pipe_width(links.len()),
  )
}

#let direct_pipe_total_width(resolved, levels, visible_block_ids: none) = {
  let width = 0pt

  if levels.len() > 1 {
    for index in range(0, levels.len() - 1) {
      let pipe = direct_pipe_between_levels(
        resolved,
        levels.at(index),
        levels.at(index + 1),
        visible_block_ids: visible_block_ids,
      )
      width += pipe.width
    }
  }

  width
}

#let direct_pipe_slot(pipe, link_scope: "general") = [
  #box(width: pipe.width, height: 0pt)[]
  #direct_pipe_label(link_scope, pipe.left_level, pipe.right_level)
]

#let inner_direct_pipe_links_for_levels(
  resolved,
  constellation_id,
  left_level,
  right_level,
  visible_block_ids: none,
) = {
  inner_direct_links_for_constellation(
    resolved,
    constellation_id,
    visible_block_ids: visible_block_ids,
  ).filter(link_data => {
    let source_level = link_data.source.block_level
    let target_level = link_data.target.block_level
    (source_level == left_level and target_level == right_level) or (target_level == left_level and source_level == right_level)
  })
}

#let inner_direct_pipe_between_levels(
  resolved,
  constellation_id,
  left_level,
  right_level,
  visible_block_ids: none,
) = {
  let links = inner_direct_pipe_links_for_levels(
    resolved,
    constellation_id,
    left_level,
    right_level,
    visible_block_ids: visible_block_ids,
  )

  (
    constellation: constellation_id,
    left_level: left_level,
    right_level: right_level,
    links: links,
    line_count: links.len(),
    width: direct_pipe_width(
      links.len(),
      inset: layout_inner_direct_pipe_inset,
      gutter: layout_inner_direct_pipe_gutter,
    ),
  )
}

#let inner_direct_pipe_total_width(
  resolved,
  constellation_id,
  levels,
  visible_block_ids: none,
) = {
  let width = 0pt

  if levels.len() > 1 {
    for index in range(0, levels.len() - 1) {
      width += inner_direct_pipe_between_levels(
        resolved,
        constellation_id,
        levels.at(index),
        levels.at(index + 1),
        visible_block_ids: visible_block_ids,
      ).width
    }
  }

  width
}

#let inner_direct_pipe_slot(pipe, link_scope: "general") = [
  #box(width: pipe.width, height: 0pt)[]
  #inner_direct_pipe_label(
    link_scope,
    pipe.constellation,
    pipe.left_level,
    pipe.right_level,
  )
]

#let direct_anchor_sides(link_data) = {
  let source_level = link_data.source.constellation_level
  let target_level = link_data.target.constellation_level

  if source_level != none and target_level != none and source_level < target_level {
    (source: "right", target: "left")
  } else if source_level != none and target_level != none and source_level > target_level {
    (source: "left", target: "right")
  } else {
    (source: "left", target: "left")
  }
}

#let target_has_right_link_block(resolved, endpoint) = {
  resolved.links.find(link_data => {
    link_data.render_mode == "link-block" and link_data.target.block == endpoint.block and link_data.target.row == endpoint.row
  }) != none
}

#let direct_anchor_id(resolved, endpoint, side, role: "source") = {
  if endpoint.block == none or endpoint.row == none {
    none
  } else {
    let resolved_side = if role == "target" and side == "right" and target_has_right_link_block(resolved, endpoint) {
      "right-outer"
    } else {
      side
    }
    endpoint.block + "." + endpoint.row + "." + resolved_side
  }
}

#let constellation_accent(resolved, constellation_id) = {
  let constellation = resolved.constellations.find(item => item.id == constellation_id)
  if constellation == none {
    color_direct_arrow
  } else {
    constellation.colors.accent
  }
}

#let direct_pipe_lane_index(links, link_id) = {
  let lane_index = none

  for index in range(0, links.len()) {
    if links.at(index).id == link_id {
      lane_index = index
    }
  }

  lane_index
}

#let direct_arrow_segments(
  resolved,
  direct_links,
  link_scope,
  origin,
  visible_block_ids: none,
) = {
  let segments = ()
  let missing = ()
  let max_y = 0pt

  for link_data in direct_links {
    let source_level = link_data.source.constellation_level
    let target_level = link_data.target.constellation_level

    if source_level == none or target_level == none or source_level == target_level {
      continue
    }

    let left_level = if source_level < target_level { source_level } else { target_level }
    let right_level = if source_level < target_level { target_level } else { source_level }
    let pipe = direct_pipe_between_levels(
      resolved,
      left_level,
      right_level,
      visible_block_ids: visible_block_ids,
    )
    let lane_index = direct_pipe_lane_index(pipe.links, link_data.id)
    let sides = direct_anchor_sides(link_data)
    let source_anchor = direct_anchor_id(resolved, link_data.source, sides.source, role: "source")
    let target_anchor = direct_anchor_id(resolved, link_data.target, sides.target, role: "target")

    if source_anchor == none or target_anchor == none or lane_index == none {
      missing.push(link_data)
    } else {
      let source_hits = query(row_anchor_label(link_scope, source_anchor))
      let target_hits = query(row_anchor_label(link_scope, target_anchor))
      let pipe_hits = query(direct_pipe_label(link_scope, left_level, right_level))

      if source_hits.len() == 0 or target_hits.len() == 0 or pipe_hits.len() == 0 {
        missing.push(link_data)
      } else {
        let source_position = source_hits.first().location().position()
        let target_position = target_hits.first().location().position()
        let pipe_position = pipe_hits.first().location().position()
        let source_x = source_position.x - origin.x
        let source_y = source_position.y - origin.y
        let target_x = target_position.x - origin.x
        let target_y = target_position.y - origin.y
        let lane_x = pipe_position.x - origin.x + layout_direct_pipe_inset + layout_direct_pipe_line_width / 2 + lane_index * (layout_direct_pipe_line_width + layout_direct_pipe_gutter)

        max_y = calc.max(max_y, source_y, target_y)
        segments.push((
          id: link_data.id,
          source_x: source_x,
          source_y: source_y,
          target_x: target_x,
          target_y: target_y,
          lane_x: lane_x,
          paint: constellation_accent(resolved, link_data.source.constellation),
        ))
      }
    }
  }

  (
    segments: segments,
    missing: missing,
    max_y: max_y,
  )
}

#let direct_segments_canvas(segments, width, max_y) = {
  let canvas_height = max_y + layout_direct_arrow_canvas_padding
  cetz.canvas(length: 1pt, padding: none, {
    import cetz.draw: *
    hide(
      rect(
        (0, -canvas_height / 1pt),
        (width / 1pt, 0),
      ),
      bounds: true,
    )

    for segment in segments {
      let source = (segment.source_x / 1pt, -segment.source_y / 1pt)
      let target = (segment.target_x / 1pt, -segment.target_y / 1pt)
      let lane = (segment.lane_x / 1pt, 0)
      let horizontal_start = lane.at(0) - source.at(0)
      let vertical = target.at(1) - source.at(1)
      let horizontal_end = target.at(0) - lane.at(0)
      let abs_horizontal_start = if horizontal_start < 0 { -horizontal_start } else { horizontal_start }
      let abs_vertical = if vertical < 0 { -vertical } else { vertical }
      let abs_horizontal_end = if horizontal_end < 0 { -horizontal_end } else { horizontal_end }
      let radius = calc.min(
        layout_direct_arrow_corner_radius / 1pt,
        abs_horizontal_start / 2,
        abs_vertical / 2,
        abs_horizontal_end / 2,
      )
      let stroke = (paint: segment.paint, thickness: layout_direct_arrow_stroke)
      let mark = (end: "stealth", fill: segment.paint, stroke: segment.paint)

      if radius == 0 {
        line(
          source,
          (lane.at(0), source.at(1)),
          (lane.at(0), target.at(1)),
          target,
          stroke: stroke,
          mark: mark,
        )
      } else {
        let horizontal_start_direction = if horizontal_start < 0 { -1 } else { 1 }
        let vertical_direction = if vertical < 0 { -1 } else { 1 }
        let horizontal_end_direction = if horizontal_end < 0 { -1 } else { 1 }
        let corner_factor = 0.55228475
        let first_corner_start = (lane.at(0) - horizontal_start_direction * radius, source.at(1))
        let first_corner_end = (lane.at(0), source.at(1) + vertical_direction * radius)
        let second_corner_start = (lane.at(0), target.at(1) - vertical_direction * radius)
        let second_corner_end = (lane.at(0) + horizontal_end_direction * radius, target.at(1))

        line(source, first_corner_start, stroke: stroke, mark: none)
        bezier(
          first_corner_start,
          first_corner_end,
          (first_corner_start.at(0) + horizontal_start_direction * corner_factor * radius, first_corner_start.at(1)),
          (first_corner_end.at(0), first_corner_end.at(1) - vertical_direction * corner_factor * radius),
          stroke: stroke,
          mark: none,
        )
        line(first_corner_end, second_corner_start, stroke: stroke, mark: none)
        bezier(
          second_corner_start,
          second_corner_end,
          (second_corner_start.at(0), second_corner_start.at(1) + vertical_direction * corner_factor * radius),
          (second_corner_end.at(0) - horizontal_end_direction * corner_factor * radius, second_corner_end.at(1)),
          stroke: stroke,
          mark: none,
        )
        line(second_corner_end, target, stroke: stroke, mark: mark)
      }
    }
  })
}

#let direct_arrows_overlay(
  resolved,
  visible_block_ids: none,
  link_scope: "general",
  width: 100pt,
) = context {
  let direct_links = outer_direct_links_for_scope(resolved, visible_block_ids: visible_block_ids)
  let origin_hits = query(direct_arrow_origin_label(link_scope))

  if direct_links.len() == 0 or origin_hits.len() == 0 {
    return []
  }

  let origin = origin_hits.first().location().position()
  let result = direct_arrow_segments(
    resolved,
    direct_links,
    link_scope,
    origin,
    visible_block_ids: visible_block_ids,
  )

  if result.segments.len() == 0 {
    return []
  }

  direct_segments_canvas(result.segments, width, result.max_y)
}

#let inner_direct_anchor_sides(link_data) = {
  let source_level = link_data.source.block_level
  let target_level = link_data.target.block_level

  if source_level != none and target_level != none and source_level < target_level {
    (source: "right", target: "left")
  } else if source_level != none and target_level != none and source_level > target_level {
    (source: "left", target: "right")
  } else {
    (source: "left", target: "left")
  }
}

#let inner_direct_arrow_segments(
  resolved,
  constellation_id,
  direct_links,
  link_scope,
  origin,
  visible_block_ids: none,
) = {
  let segments = ()
  let missing = ()
  let max_y = 0pt

  for link_data in direct_links {
    let source_level = link_data.source.block_level
    let target_level = link_data.target.block_level

    if source_level == none or target_level == none or source_level == target_level {
      continue
    }

    let left_level = calc.min(source_level, target_level)
    let right_level = calc.max(source_level, target_level)
    let pipe = inner_direct_pipe_between_levels(
      resolved,
      constellation_id,
      left_level,
      right_level,
      visible_block_ids: visible_block_ids,
    )
    let lane_index = direct_pipe_lane_index(pipe.links, link_data.id)
    let sides = inner_direct_anchor_sides(link_data)
    let source_anchor = direct_anchor_id(resolved, link_data.source, sides.source, role: "source")
    let target_anchor = direct_anchor_id(resolved, link_data.target, sides.target, role: "target")

    if source_anchor == none or target_anchor == none or lane_index == none {
      missing.push(link_data)
    } else {
      let source_hits = query(row_anchor_label(link_scope, source_anchor))
      let target_hits = query(row_anchor_label(link_scope, target_anchor))
      let pipe_hits = query(inner_direct_pipe_label(link_scope, constellation_id, left_level, right_level))

      if source_hits.len() == 0 or target_hits.len() == 0 or pipe_hits.len() == 0 {
        missing.push(link_data)
      } else {
        let source_position = source_hits.first().location().position()
        let target_position = target_hits.first().location().position()
        let pipe_position = pipe_hits.first().location().position()
        let source_x = source_position.x - origin.x
        let source_y = source_position.y - origin.y
        let target_x = target_position.x - origin.x
        let target_y = target_position.y - origin.y
        let lane_x = pipe_position.x - origin.x + layout_inner_direct_pipe_inset + layout_direct_pipe_line_width / 2 + lane_index * (layout_direct_pipe_line_width + layout_inner_direct_pipe_gutter)

        max_y = calc.max(max_y, source_y, target_y)
        segments.push((
          id: link_data.id,
          source_x: source_x,
          source_y: source_y,
          target_x: target_x,
          target_y: target_y,
          lane_x: lane_x,
          paint: constellation_accent(resolved, constellation_id),
        ))
      }
    }
  }

  (
    segments: segments,
    missing: missing,
    max_y: max_y,
  )
}

#let inner_direct_arrows_overlay(
  resolved,
  constellation_id,
  visible_block_ids: none,
  link_scope: "general",
  width: 100pt,
) = context {
  let direct_links = inner_direct_links_for_constellation(
    resolved,
    constellation_id,
    visible_block_ids: visible_block_ids,
  )
  let origin_hits = query(inner_direct_arrow_origin_label(link_scope, constellation_id))

  if direct_links.len() == 0 or origin_hits.len() == 0 {
    return []
  }

  let origin = origin_hits.first().location().position()
  let result = inner_direct_arrow_segments(
    resolved,
    constellation_id,
    direct_links,
    link_scope,
    origin,
    visible_block_ids: visible_block_ids,
  )

  if result.segments.len() == 0 {
    return []
  }

  direct_segments_canvas(result.segments, width, result.max_y)
}

#let compact_grid_cell(
  body,
  fill: white,
  text_fill: color_text,
  weight: 400,
  font: font_mono,
  prefix: [],
  suffix: [],
) = {
  block(
    width: 100%,
    height: layout_row_height,
    inset: (x: 5pt, y: 0pt),
    fill: fill,
    stroke: (paint: color_block_grid, thickness: 0.32pt),
  )[
    #align(left + horizon)[
      #grid(
        columns: (auto, 1fr, auto),
        gutter: 4pt,
        align: (left + horizon, left + horizon, right + horizon),
        prefix,
        text(size: block_code_text_size, fill: text_fill, weight: weight, font: font)[#body],
        suffix,
      )
    ]
  ]
}

#let compact_header_cell(body) = {
  compact_grid_cell(
    body,
    fill: color_block_section,
    text_fill: color_muted,
    weight: 700,
    font: font_body,
  )
}

#let compact_row_grid(
  name,
  data_type,
  attrs,
  fill: white,
) = [
  #grid(
    columns: (1.75fr, 0.65fr, 0.65fr),
    gutter: 0pt,
    align: (left + horizon, left + horizon, left + horizon),
    compact_grid_cell(
      name,
      fill: fill,
    ),
    compact_grid_cell(data_type, fill: fill, text_fill: color_muted),
    compact_grid_cell(
      attrs,
      fill: fill,
      text_fill: color_sec,
      weight: 700,
    ),
  )
]

#let compact_side_cell(
  links,
  role: "source",
  width: layout_link_block_side_width,
  anchor_id: none,
  outer_anchor_id: none,
  anchor_side: "left",
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
  arrow_color: color_link_arrow,
) = {
  let visible_links = if role == "target" {
    dedupe_link_blocks_by_code(links)
  } else {
    links
  }

  [
    #block(
      width: width,
      height: layout_row_height,
      inset: 0pt,
    )[
      #external_row_anchor(
        anchor_side,
        anchor_id,
        visible: show_anchor_debug,
        link_scope: link_scope,
      )
      #if role == "target" and visible_links.len() > 0 [
        #external_row_anchor(
          "right-outer",
          outer_anchor_id,
          visible: show_anchor_debug,
          link_scope: link_scope,
        )
      ]
      #align(center + horizon)[
        #link_block_marker_stack(
          visible_links,
          role: role,
          visible_block_ids: visible_block_ids,
          link_scope: link_scope,
          arrow_color: arrow_color,
        )
      ]
    ]
  ]
}

#let compact_blank_side(width: layout_link_block_side_width, height: layout_row_height) = [
  #block(width: width, height: height)[]
]

#let compact_title_row(title, accent, right_side_width: layout_link_block_side_width) = [
  #grid(
    columns: (layout_link_block_side_width, 1fr, right_side_width),
    gutter: layout_link_block_side_gap,
    align: (center + horizon, left + horizon, center + horizon),
    compact_blank_side(height: layout_row_height),
    block(
      width: 100%,
      height: layout_row_height,
      inset: (x: 7pt, y: 0pt),
      fill: accent,
    )[
      #align(left + horizon)[
        #text(size: block_title_size, fill: white, weight: 700)[#title]
      ]
    ],
    compact_blank_side(width: right_side_width, height: layout_row_height),
  )
]

#let compact_header_row(right_side_width: layout_link_block_side_width) = [
  #grid(
    columns: (layout_link_block_side_width, 1fr, right_side_width),
    gutter: layout_link_block_side_gap,
    align: (center + horizon, left + horizon, center + horizon),
    compact_blank_side(),
    grid(
      columns: (1.75fr, 0.65fr, 0.65fr),
      gutter: 0pt,
      align: (left + horizon, left + horizon, left + horizon),
      compact_header_cell([Name]),
      compact_header_cell([Type]),
      compact_header_cell([Attrs]),
    ),
    compact_blank_side(width: right_side_width),
  )
]

#let compact_data_row(
  block_id,
  row,
  name,
  data_type,
  attrs,
  source_link_blocks,
  target_link_blocks,
  right_side_width: layout_link_block_side_width,
  fill: white,
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
  arrow_color: color_link_arrow,
) = [
  #grid(
    columns: (layout_link_block_side_width, 1fr, right_side_width),
    gutter: layout_link_block_side_gap,
    align: (center + horizon, left + horizon, center + horizon),
    compact_side_cell(
      source_link_blocks,
      role: "source",
      anchor_id: row.anchors.left,
      anchor_side: "left",
      show_anchor_debug: show_anchor_debug,
      visible_block_ids: visible_block_ids,
      link_scope: link_scope,
      arrow_color: arrow_color,
    ),
    compact_row_grid(
      name,
      data_type,
      attrs,
      fill: fill,
    ),
    compact_side_cell(
      target_link_blocks,
      role: "target",
      width: right_side_width,
      anchor_id: row.anchors.right,
      outer_anchor_id: row.anchors.right_outer,
      anchor_side: "right",
      show_anchor_debug: show_anchor_debug,
      visible_block_ids: visible_block_ids,
      link_scope: link_scope,
      arrow_color: arrow_color,
    ),
  )
  #row_destination_label(link_scope, block_id, row.id)
]

#let visual_name_cell(
  body,
  anchor_id,
  source_link_blocks: (),
  fill: white,
  show_anchor_debug: layout_show_anchor_debug,
) = {
  table.cell(fill: fill, inset: (x: 4pt, y: 3pt))[
    #block(height: layout_row_height)[
      #grid(
        columns: (auto, auto, 1fr),
        gutter: 4pt,
        align: (left + horizon, left + horizon, left + horizon),
        link_block_stack(source_link_blocks, role: "source"),
        anchor_marker("left", anchor_id, visible: show_anchor_debug),
        text(size: block_code_text_size, fill: color_text, font: font_mono)[#body],
      )
    ]
  ]
}

#let visual_attrs_cell(body, anchor_id, fill: white, show_anchor_debug: layout_show_anchor_debug) = {
  table.cell(fill: fill, inset: (x: 5pt, y: 3pt))[
    #block(height: layout_row_height)[
      #grid(
        columns: (1fr, auto),
        gutter: 4pt,
        align: (left + horizon, right + horizon),
        text(size: block_code_text_size, fill: color_sec, weight: 700, font: font_mono)[#body],
        anchor_marker("right", anchor_id, visible: show_anchor_debug),
      )
    ]
  ]
}

#let visual_header_cell(body, fill: color_block_section) = {
  table.cell(fill: fill, inset: (x: 5pt, y: 3pt))[
    #block(height: layout_row_height)[
      #align(left + horizon)[
        #text(size: diagram_label_size, fill: color_muted, weight: 700)[#body]
      ]
    ]
  ]
}

#let compact_database_block(
  block_data,
  constellation: none,
  data_type_abstractions: (),
  links: (),
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
) = {
  let accent = if constellation == none {
    color_main
  } else {
    constellation.colors.block_accent
  }

  let body_fill = if constellation == none {
    white
  } else {
    constellation.colors.block_fill
  }

  let rows = block_data.rows.sorted(key: row => row.order)
  let has_outer_target_anchor = rows.any(row => link_blocks_for_target(links, block_data.id, row.id).len() > 0)
  let right_side_width = layout_link_block_side_width + if has_outer_target_anchor {
    layout_link_block_outer_anchor_reserve
  } else {
    0pt
  }
  let rows_content = (
    compact_title_row(block_data.title, accent, right_side_width: right_side_width),
    compact_header_row(right_side_width: right_side_width),
  )

  for row in rows {
    let column = row.raw
    let column_name = field(column, "name", default: field(column, "id", default: [row]))
    let data_type = data_type_text(field(column, "data_type", default: none), data_type_abstractions)
    let attrs = attr_text(field(column, "attrs", default: ()))
    let source_link_blocks = link_blocks_for_source(links, block_data.id, row.id)
    let target_link_blocks = link_blocks_for_target(links, block_data.id, row.id)

    rows_content.push(compact_data_row(
      block_data.id,
      row,
      column_name,
      data_type,
      attrs,
      source_link_blocks,
      target_link_blocks,
      right_side_width: right_side_width,
      fill: body_fill,
      show_anchor_debug: show_anchor_debug,
      visible_block_ids: visible_block_ids,
      link_scope: link_scope,
      arrow_color: accent,
    ))
  }

  block(
    width: 100%,
    radius: layout_block_radius,
    inset: layout_block_padding,
  )[
    #stack(dir: ttb, spacing: 0pt, ..rows_content)
  ]
}

#let block_has_outer_target_anchor(block_data, links) = {
  block_data.rows.any(row => link_blocks_for_target(links, block_data.id, row.id).len() > 0)
}

#let block_levels(blocks) = {
  let levels = ()
  for block_data in blocks {
    if not levels.contains(block_data.block_level) {
      levels.push(block_data.block_level)
    }
  }
  levels.sorted()
}

#let blocks_at_level(blocks, level) = {
  blocks
    .filter(block_data => block_data.block_level == level)
    .sorted(key: block_data => block_data.block_order * 10000 + block_data.source_index)
}

#let block_level_dynamic_width(blocks, level, links) = {
  let level_blocks = blocks_at_level(blocks, level)
  let needs_outer_anchor = level_blocks.any(block_data => block_has_outer_target_anchor(block_data, links))
  layout_block_column_width + if needs_outer_anchor {
    layout_link_block_outer_anchor_reserve
  } else {
    0pt
  }
}

#let constellation_inner_width(resolved, constellation_id, blocks, links) = {
  let levels = block_levels(blocks)
  if levels.len() == 0 {
    return layout_block_column_width
  }

  let level_widths = levels.map(level => block_level_dynamic_width(blocks, level, links))
  let pipe_width = inner_direct_pipe_total_width(
    resolved,
    constellation_id,
    levels,
    visible_block_ids: blocks.map(block_data => block_data.id),
  )
  let gap_width = if levels.len() > 1 {
    layout_block_column_gap * (levels.len() - 1)
  } else {
    0pt
  }

  level_widths.sum() + gap_width + pipe_width
}

#let constellation_dynamic_width(resolved, constellation_id, blocks, links) = {
  constellation_inner_width(resolved, constellation_id, blocks, links) + layout_constellation_padding * 2
}

#let block_level_column(
  constellation,
  blocks,
  level,
  width,
  data_type_abstractions: (),
  links: (),
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
) = [
  #block(width: width)[
    #text(size: 6pt, fill: constellation.colors.accent, weight: 700)[BLOCK LEVEL #level]
    #v(5pt)
    #let level_blocks = blocks_at_level(blocks, level)
    #for index in range(0, level_blocks.len()) [
      #if index > 0 [
        #v(layout_block_gap)
      ]
      #compact_database_block(
        level_blocks.at(index),
        constellation: constellation,
        data_type_abstractions: data_type_abstractions,
        links: links,
        show_anchor_debug: show_anchor_debug,
        visible_block_ids: visible_block_ids,
        link_scope: link_scope,
      )
    ]
  ]
]

#let constellation_block_grid(
  resolved,
  constellation,
  blocks,
  data_type_abstractions: (),
  links: (),
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
) = {
  let levels = block_levels(blocks)
  let columns = ()
  let cells = ()
  let level_widths = levels.map(level => block_level_dynamic_width(blocks, level, links))
  let inner_width = constellation_inner_width(resolved, constellation.id, blocks, links)

  for index in range(0, levels.len()) {
    let level = levels.at(index)
    let level_width = level_widths.at(index)
    columns.push(level_width)
    cells.push(block_level_column(
      constellation,
      blocks,
      level,
      level_width,
      data_type_abstractions: data_type_abstractions,
      links: links,
      show_anchor_debug: show_anchor_debug,
      visible_block_ids: visible_block_ids,
      link_scope: link_scope,
    ))

    if index < levels.len() - 1 {
      let pipe = inner_direct_pipe_between_levels(
        resolved,
        constellation.id,
        level,
        levels.at(index + 1),
        visible_block_ids: visible_block_ids,
      )
      columns.push(layout_block_column_gap / 2)
      cells.push([])
      columns.push(pipe.width)
      cells.push(inner_direct_pipe_slot(pipe, link_scope: link_scope))
      columns.push(layout_block_column_gap / 2)
      cells.push([])
    }
  }

  [
    #block(width: inner_width)[
      #place(top + left)[
        #box(width: 0pt, height: 0pt)[]
        #inner_direct_arrow_origin_label(link_scope, constellation.id)
      ]
      #grid(
        columns: columns,
        gutter: 0pt,
        align: (left + top,),
        ..cells,
      )
      #place(top + left)[
        #inner_direct_arrows_overlay(
          resolved,
          constellation.id,
          visible_block_ids: visible_block_ids,
          link_scope: link_scope,
          width: inner_width,
        )
      ]
    ]
  ]
}

#let constellation_container(
  constellation,
  blocks,
  resolved: none,
  data_type_abstractions: (),
  links: (),
  show_anchor_debug: layout_show_anchor_debug,
  visible_block_ids: none,
  link_scope: "general",
  width: none,
) = {
  let accent = constellation.colors.accent
  let fill = constellation.colors.fill

  let container_width = if width == none {
    constellation_dynamic_width(resolved, constellation.id, blocks, links)
  } else {
    width
  }

  block(
    width: container_width,
    radius: layout_constellation_radius,
    fill: fill,
    stroke: (paint: accent, thickness: 1pt),
    inset: layout_constellation_padding,
  )[
    #grid(
      columns: (1fr, auto),
      gutter: 8pt,
      align: (left + horizon, right + horizon),
      text(size: 12pt, fill: accent, weight: 700)[#constellation.title],
      text(size: diagram_label_size, fill: accent, weight: 700)[L#constellation.level / O#constellation.order],
    )
    #let description = field(constellation.raw, "description", default: none)
    #if description != none [
      #v(2pt)
      #text(size: small_text_size, fill: color_muted)[#description]
    ]
    #v(8pt)
    #if blocks.len() == 0 [
      #text(size: small_text_size, fill: color_muted)[No blocks in this constellation.]
    ] else [
      #constellation_block_grid(
        resolved,
        constellation,
        blocks,
        data_type_abstractions: data_type_abstractions,
        links: links,
        show_anchor_debug: show_anchor_debug,
        visible_block_ids: visible_block_ids,
        link_scope: link_scope,
      )
    ]
  ]
}

#let anchor_debug_panel(resolved) = {
  if not layout_show_anchor_debug {
    return []
  }

  panel([Row anchors], [
    #text(size: small_text_size, fill: color_muted)[Visible row markers use left and right side anchors.]
    #v(6pt)
    #text(size: diagram_label_size, fill: color_muted, weight: 700)[Anchor count]
    #v(3pt)
    #text(size: small_text_size)[#resolved.anchors.len() stable anchors]
    #v(8pt)
    #text(size: diagram_label_size, fill: color_muted, weight: 700)[Link examples]
    #v(4pt)
    #for link in resolved.links [
      #if link.valid [
        #text(font: font_mono, size: 5.8pt, fill: color_anchor_left)[#link.source.anchor.id]
        #v(1pt)
        #text(size: 5.8pt, fill: color_muted)[to]
        #v(1pt)
        #text(font: font_mono, size: 5.8pt, fill: color_anchor_right)[#link.target.anchor.id]
        #v(5pt)
      ]
    ]
  ])
}

#let direct_links_panel(resolved, visible_block_ids: none) = {
  let direct_links = direct_links_for_scope(resolved, visible_block_ids: visible_block_ids)

  if direct_links.len() == 0 {
    return []
  }

  panel([Direct arrows], [
    #text(size: small_text_size, fill: color_muted)[Cross-constellation links use outer pipes; adjacent internal block levels use constellation-scoped inner pipes.]
    #v(6pt)
    #for link_data in direct_links [
      #text(font: font_mono, size: 5.8pt, fill: color_sec)[#link_data.id]
      #v(1pt)
      #text(size: 5.8pt)[#link_data.routing_scope / #link_data.routing_relation #h(3pt) #link_data.requested_mode -> #link_data.render_mode]
      #v(1pt)
      #let endpoint = link_data.source.block + "." + link_data.source.row + " -> " + link_data.target.block + "." + link_data.target.row
      #text(font: font_mono, size: 5.8pt, fill: color_muted)[#endpoint]
      #v(5pt)
    ]
  ])
}

#let link_blocks_panel(resolved) = {
  let link_blocks = resolved.links.filter(link => link.render_mode == "link-block")

  if link_blocks.len() == 0 {
    return []
  }

  panel([Link-blocks], [
    #text(size: small_text_size, fill: color_muted)[Rows show compact badges with local arrows. Source badges jump to their target row when that row is on the current page.]
    #v(6pt)
    #for link in link_blocks [
      #text(font: font_mono, size: 5.8pt, fill: color_link_block_text)[#link.id]
      #v(1pt)
      #text(size: 5.8pt)[#link.routing_scope / #link.routing_relation #h(3pt) #link.requested_mode -> #link.render_mode]
      #v(1pt)
      #let endpoint = link.source.block + "." + link.source.row + " -> " + link.target.block + "." + link.target.row
      #text(font: font_mono, size: 5.8pt, fill: color_muted)[#endpoint]
      #v(5pt)
    ]
  ])
}

#let database_block(block_data, constellation: none, data_type_abstractions: ()) = {
  let accent = if constellation == none {
    color_main
  } else {
    constellation.colors.block_accent
  }

  let body_fill = if constellation == none {
    white
  } else {
    constellation.colors.block_fill
  }

  let cells = ()

  cells.push(table.cell(
    colspan: 3,
    fill: accent,
    inset: (x: 8pt, y: 6pt),
  )[
    #text(size: block_title_size, fill: white, weight: 700)[#block_data.title]
  ])

  cells.push(section_cell([Columns]))

  cells.push(table.cell(fill: body_fill)[#text(size: diagram_label_size, fill: color_muted, weight: 700)[Name]])
  cells.push(table.cell(fill: body_fill)[#text(size: diagram_label_size, fill: color_muted, weight: 700)[Type]])
  cells.push(table.cell(fill: body_fill)[#text(size: diagram_label_size, fill: color_muted, weight: 700)[Attrs]])

  for column in block_data.columns {
    cells.push(table.cell(fill: body_fill)[#mono(column.name)])
    cells.push(table.cell(fill: body_fill)[#mono(data_type_text(column.data_type, data_type_abstractions), fill: color_muted)])
    cells.push(table.cell(fill: body_fill)[#mono(attr_text(column.attrs), fill: color_sec, weight: 700)])
  }

  cells.push(section_cell([Constraints]))

  cells.push(table.cell(fill: body_fill)[#text(size: diagram_label_size, fill: color_muted, weight: 700)[Name]])
  cells.push(table.cell(fill: body_fill)[#text(size: diagram_label_size, fill: color_muted, weight: 700)[Type]])
  cells.push(table.cell(fill: body_fill)[#text(size: diagram_label_size, fill: color_muted, weight: 700)[Detail]])

  let constraints = field(block_data, "constraints", default: ())

  for constraint in constraints {
    cells.push(table.cell(fill: body_fill)[#mono(constraint.name)])
    cells.push(table.cell(fill: body_fill)[#mono(constraint.constraint_type, fill: color_sec, weight: 700)])
    cells.push(table.cell(fill: body_fill)[#mono(constraint.detail, fill: color_muted)])
  }

  block(
    width: block_width,
    radius: block_radius,
    stroke: (paint: accent, thickness: 0.9pt),
  )[
    #table(
      columns: (1.35fr, 0.7fr, 1.25fr),
      align: (left + horizon, left + horizon, left + horizon),
      inset: block_cell_inset,
      stroke: (paint: color_block_grid, thickness: 0.35pt),
      ..cells,
    )
  ]
}
