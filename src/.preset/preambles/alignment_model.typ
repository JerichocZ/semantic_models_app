#let field(item, key, default: none) = {
  if item != none and item.keys().contains(key) {
    item.at(key)
  } else {
    default
  }
}

#let diagnostic(severity, code, message, link: none) = (
  severity: severity,
  code: code,
  link: link,
  message: message,
)

#let title_of(item, fallback) = {
  field(item, "title", default: field(item, "name", default: fallback))
}

#let positive_integer(value) = {
  type(value) == int and value > 0
}

#let content_to_str(value) = {
  if value == none {
    return ""
  }

  if type(value) != content {
    return str(value)
  }

  if value.has("text") {
    return value.text
  }

  if value.has("child") {
    return content_to_str(value.child)
  }

  if value.has("body") {
    return content_to_str(value.body)
  }

  if value.has("children") {
    let out = ""
    for child in value.children {
      out += content_to_str(child)
    }
    return out
  }

  ""
}

#let row_id(row, fallback: none) = {
  let id = field(row, "id", default: field(row, "key", default: none))

  if id != none {
    return content_to_str(id)
  }

  let name = field(row, "name", default: none)
  if name != none {
    return content_to_str(name)
  }

  fallback
}

#let inline_link_specs(linked) = {
  if type(linked) == array and linked.len() > 0 and type(linked.first()) == array {
    linked
  } else {
    (linked,)
  }
}

#let collect_inline_links(blocks) = {
  let links = ()
  let diagnostics = ()

  for block_index in range(0, blocks.len()) {
    let block_data = blocks.at(block_index)
    let block_id = field(block_data, "id", default: "block-" + str(block_index + 1))
    let source_constellation = field(block_data, "constellation", default: none)
    let columns = field(block_data, "columns", default: ())

    for column_index in range(0, columns.len()) {
      let column = columns.at(column_index)
      let linked = field(column, "linked", default: none)

      if linked != none {
        let source_row_id = row_id(column, fallback: "row-" + str(column_index + 1))
        let specs = inline_link_specs(linked)

        for spec_index in range(0, specs.len()) {
          let spec = specs.at(spec_index)
          let link_id = "inline-" + block_id + "-" + source_row_id + "-" + str(spec_index + 1)
          let valid_spec = type(spec) == array and (spec.len() == 3 or spec.len() == 4)

          if not valid_spec {
            diagnostics.push(diagnostic(
              "warning",
              "invalid-inline-link",
              [Inline link #link_id must be `(constellation, block, row)` or `(constellation, block, row, mode)`.],
              link: link_id,
            ))
          } else {
            let target_constellation = content_to_str(spec.at(0))
            let target_block = content_to_str(spec.at(1))
            let target_row = content_to_str(spec.at(2))
            let mode = if spec.len() == 4 { content_to_str(spec.at(3)) } else { "auto" }

            links.push((
              id: link_id,
              source: (
                constellation: source_constellation,
                block: block_id,
                row: source_row_id,
              ),
              target: (
                constellation: target_constellation,
                block: target_block,
                row: target_row,
              ),
              mode: mode,
              declaration: "inline",
            ))
          }
        }
      }
    }
  }

  (links: links, diagnostics: diagnostics)
}

#let canonical_anchor_side(side) = {
  if side == "source" or side == "source-side" {
    "left"
  } else if side == "target" or side == "target-side" {
    "right"
  } else if side == "left" or side == "right" or side == "right-outer" or side == "center" {
    side
  } else {
    "center"
  }
}

#let block_identity(constellation_id, block_id) = {
  let constellation = if constellation_id == none { "unresolved" } else { constellation_id }
  constellation + "." + block_id
}

#let row_anchor(constellation_id, block_id, row_id, side) = {
  block_identity(constellation_id, block_id) + "." + row_id + "." + canonical_anchor_side(side)
}

#let row_anchor_set(constellation_id, block_id, row_id) = (
  left: row_anchor(constellation_id, block_id, row_id, "left"),
  right: row_anchor(constellation_id, block_id, row_id, "right"),
  right_outer: row_anchor(constellation_id, block_id, row_id, "right-outer"),
  center: row_anchor(constellation_id, block_id, row_id, "center"),
  source: row_anchor(constellation_id, block_id, row_id, "source"),
  target: row_anchor(constellation_id, block_id, row_id, "target"),
)

#let endpoint_anchor(endpoint, role, constellation: none) = {
  let block_id = field(endpoint, "block", default: none)
  let row_id = field(endpoint, "row", default: none)
  let constellation_id = if constellation == none {
    field(endpoint, "constellation", default: none)
  } else {
    constellation
  }
  let requested_side = field(endpoint, "side", default: role)
  let side = canonical_anchor_side(requested_side)

  (
    requested_side: requested_side,
    side: side,
    id: if block_id == none or row_id == none {
      none
    } else {
      row_anchor(constellation_id, block_id, row_id, side)
    },
  )
}

#let normalize_rows(block_data, constellation_id, block_id) = {
  let rows = ()
  let columns = field(block_data, "columns", default: ())

  for index in range(0, columns.len()) {
    let column = columns.at(index)
    let id = row_id(column, fallback: "row-" + str(index + 1))

    if id != none {
      rows.push((
        id: id,
        section: "columns",
        order: field(column, "order", default: index + 1),
        source_index: index + 1,
        anchors: row_anchor_set(constellation_id, block_id, id),
        raw: column,
      ))
    }
  }

  rows
}

#let collect_row_anchors(blocks) = {
  let anchors = ()

  for block_data in blocks {
    for row in block_data.rows {
      for side in ("left", "right", "right-outer", "center") {
        anchors.push((
          id: row_anchor(block_data.constellation, block_data.id, row.id, side),
          block: block_data.id,
          row: row.id,
          side: side,
          constellation: block_data.constellation,
          constellation_level: block_data.constellation_level,
          block_level: block_data.block_level,
          order: (
            constellation: block_data.constellation_order,
            block_level: block_data.block_level,
            block: block_data.block_order,
            row: row.order,
          ),
        ))
      }
    }
  }

  anchors
}

#import "color_schemes.typ": resolve_color_schema, color_theme_for

#let normalize_constellations(constellations, color_schema) = {
  let normalized = ()

  for index in range(0, constellations.len()) {
    let constellation = constellations.at(index)
    let id = field(constellation, "id", default: "constellation-" + str(index + 1))
    let level = field(constellation, "level", default: 1)
    let order = field(constellation, "order", default: index + 1)
    let colors = color_theme_for(color_schema, index + 1)

    normalized.push((
      id: id,
      title: title_of(constellation, id),
      level: level,
      order: order,
      source_index: index + 1,
      layout: (
        column: level,
        stack_order: order,
      ),
      colors: colors,
      raw: constellation,
    ))
  }

  normalized.sorted(key: constellation => constellation.level * 10000 + constellation.order)
}

#let constellation_by_id(constellations, id) = {
  constellations.find(constellation => constellation.id == id)
}

#let row_by_id(block_data, id) = {
  if block_data == none {
    none
  } else {
    block_data.rows.find(row => row.id == id)
  }
}

#let endpoint_id_candidates(blocks, endpoint) = {
  let block_id = field(endpoint, "block", default: none)
  blocks.filter(block_data => block_data.id == block_id)
}

#let endpoint_block_candidates(blocks, endpoint) = {
  let candidates = endpoint_id_candidates(blocks, endpoint)
  let constellation_hint = field(endpoint, "constellation", default: none)
  let row = field(endpoint, "row", default: none)

  if constellation_hint != none {
    candidates = candidates.filter(block_data => block_data.constellation == constellation_hint)
  }

  let row_matches = candidates.filter(block_data => row_by_id(block_data, row) != none)
  if row_matches.len() > 0 {
    row_matches
  } else {
    candidates
  }
}

#let narrow_endpoint_candidates(candidates, counterpart_candidates) = {
  if candidates.len() <= 1 or counterpart_candidates.len() != 1 {
    return candidates
  }

  let counterpart_constellation = counterpart_candidates.first().constellation
  let same_constellation = candidates.filter(block_data => block_data.constellation == counterpart_constellation)

  if same_constellation.len() == 1 {
    same_constellation
  } else {
    candidates
  }
}

#let normalize_blocks(blocks, constellations) = {
  let normalized = ()
  let diagnostics = ()

  for index in range(0, blocks.len()) {
    let block_data = blocks.at(index)
    let id = field(block_data, "id", default: "block-" + str(index + 1))
    let constellation_id = field(block_data, "constellation", default: none)
    let constellation = constellation_by_id(constellations, constellation_id)
    let constellation_source_index = blocks
      .slice(0, index)
      .filter(candidate => field(candidate, "constellation", default: none) == constellation_id)
      .len() + 1
    let requested_block_level = field(block_data, "level", default: 1)
    let requested_block_order = field(block_data, "order", default: constellation_source_index)
    let block_level = if positive_integer(requested_block_level) { requested_block_level } else { 1 }
    let block_order = if positive_integer(requested_block_order) { requested_block_order } else { constellation_source_index }
    let constellation_level = if constellation == none { none } else { constellation.level }
    let constellation_order = if constellation == none { none } else { constellation.order }

    if constellation == none {
      diagnostics.push(diagnostic(
        "warning",
        "block-constellation-not-found",
        [Block #id references unknown constellation #constellation_id.],
      ))
    }

    if not positive_integer(requested_block_level) {
      diagnostics.push(diagnostic(
        "warning",
        "invalid-block-level",
        [Block #id uses invalid level #requested_block_level. Block level 1 was used.],
      ))
    }

    if not positive_integer(requested_block_order) {
      diagnostics.push(diagnostic(
        "warning",
        "invalid-block-order",
        [Block #id uses invalid order #requested_block_order. Source order #constellation_source_index was used.],
      ))
    }

    let duplicate = normalized.find(candidate => candidate.constellation == constellation_id and candidate.block_level == block_level and candidate.block_order == block_order)

    if duplicate != none {
      diagnostics.push(diagnostic(
        "warning",
        "duplicate-block-position",
        [Blocks #duplicate.id and #id share constellation #constellation_id, block level #block_level, and order #block_order; source order will break the tie.],
      ))
    }

    let rows = normalize_rows(block_data, constellation_id, id)

    normalized.push((
      id: id,
      title: title_of(block_data, id),
      constellation: constellation_id,
      constellation_found: constellation != none,
      constellation_level: constellation_level,
      constellation_order: constellation_order,
      block_level: block_level,
      block_order: block_order,
      level: block_level,
      order: block_order,
      source_index: index + 1,
      constellation_source_index: constellation_source_index,
      rows: rows,
      anchors: collect_row_anchors(((
        id: id,
        constellation: constellation_id,
        constellation_level: constellation_level,
        constellation_order: constellation_order,
        block_level: block_level,
        block_order: block_order,
        rows: rows,
      ),)),
      layout: (
        constellation_column: constellation_level,
        constellation_stack_order: constellation_order,
        column: block_level,
        block_stack_order: block_order,
      ),
      raw: block_data,
    ))
  }

  let sorted = normalized.sorted(key: block_data => {
    let constellation_level = if block_data.constellation_level == none { 9999 } else { block_data.constellation_level }
    let constellation_order = if block_data.constellation_order == none { 9999 } else { block_data.constellation_order }
    constellation_level * 1000000000 + constellation_order * 1000000 + block_data.block_level * 10000 + block_data.block_order * 100 + block_data.source_index
  })

  (blocks: sorted, diagnostics: diagnostics)
}

#let link_relation(source_constellation, target_constellation, source_level, target_level) = {
  if source_constellation == none or target_constellation == none or source_level == none or target_level == none {
    return "invalid"
  }

  if source_constellation == target_constellation {
    return "internal"
  }

  if source_level == target_level {
    return "same-level"
  }

  let distance = if source_level > target_level {
    source_level - target_level
  } else {
    target_level - source_level
  }

  if distance == 1 {
    "adjacent-level"
  } else {
    "skip-level"
  }
}

#let block_link_relation(source_block_id, target_block_id, source_level, target_level) = {
  if source_block_id == none or target_block_id == none or source_level == none or target_level == none {
    return "invalid"
  }

  if source_block_id == target_block_id {
    return "same-block"
  }

  if source_level == target_level {
    return "same-level"
  }

  let distance = calc.abs(source_level - target_level)
  if distance == 1 {
    "adjacent-level"
  } else {
    "skip-level"
  }
}

#let link_routing_scope(source_block_id, target_block_id, source_constellation, target_constellation) = {
  if source_block_id == none or target_block_id == none or source_constellation == none or target_constellation == none {
    "invalid"
  } else if source_block_id == target_block_id {
    "same-block"
  } else if source_constellation == target_constellation {
    "internal"
  } else {
    "cross-constellation"
  }
}

#let resolve_scoped_link_mode(requested_mode, routing_scope, constellation_relation, block_relation) = {
  let supported_modes = ("auto", "direct", "link-block")

  if not supported_modes.contains(requested_mode) or routing_scope == "invalid" or constellation_relation == "invalid" or block_relation == "invalid" {
    return "invalid"
  }

  if requested_mode != "auto" {
    return requested_mode
  }

  if routing_scope == "cross-constellation" {
    if constellation_relation == "adjacent-level" { "direct" } else { "link-block" }
  } else if routing_scope == "internal" {
    if block_relation == "adjacent-level" { "direct" } else { "link-block" }
  } else {
    "link-block"
  }
}

#let direct_route_supported(mode, routing_scope, constellation_relation, block_relation) = {
  mode != "direct" or (routing_scope == "cross-constellation" and constellation_relation == "adjacent-level") or (routing_scope == "internal" and block_relation == "adjacent-level")
}

#let normalize_links(links, blocks, constellations) = {
  let normalized = ()
  let diagnostics = ()
  let supported_modes = ("auto", "direct", "link-block")

  for index in range(0, links.len()) {
    let link = links.at(index)
    let id = field(link, "id", default: "link-" + str(index + 1))
    let requested_mode = field(link, "mode", default: "auto")
    let source = field(link, "source", default: (:))
    let target = field(link, "target", default: (:))
    let source_block_id = field(source, "block", default: none)
    let source_row_id = field(source, "row", default: none)
    let source_constellation_hint = field(source, "constellation", default: none)
    let target_block_id = field(target, "block", default: none)
    let target_row_id = field(target, "row", default: none)
    let target_constellation_hint = field(target, "constellation", default: none)
    let source_id_candidates = endpoint_id_candidates(blocks, source)
    let target_id_candidates = endpoint_id_candidates(blocks, target)
    let initial_source_candidates = endpoint_block_candidates(blocks, source)
    let initial_target_candidates = endpoint_block_candidates(blocks, target)
    let source_candidates = narrow_endpoint_candidates(initial_source_candidates, initial_target_candidates)
    let target_candidates = narrow_endpoint_candidates(initial_target_candidates, source_candidates)
    let final_source_candidates = narrow_endpoint_candidates(source_candidates, target_candidates)
    let source_block = if final_source_candidates.len() == 1 { final_source_candidates.first() } else { none }
    let target_block = if target_candidates.len() == 1 { target_candidates.first() } else { none }
    let source_row = row_by_id(source_block, source_row_id)
    let target_row = row_by_id(target_block, target_row_id)
    let source_anchor = endpoint_anchor(
      source,
      "source",
      constellation: if source_block == none { source_constellation_hint } else { source_block.constellation },
    )
    let target_anchor = endpoint_anchor(
      target,
      "target",
      constellation: if target_block == none { target_constellation_hint } else { target_block.constellation },
    )

    if not supported_modes.contains(requested_mode) {
      diagnostics.push(diagnostic(
        "warning",
        "invalid-link-mode",
        [Link #id uses unsupported mode #requested_mode.],
        link: id,
      ))
    }

    if source_block == none {
      if source_id_candidates.len() == 0 or initial_source_candidates.len() == 0 {
        diagnostics.push(diagnostic(
          "warning",
          "source-block-not-found",
          if source_constellation_hint == none {
            [Link #id source block #source_block_id was not found.]
          } else {
            [Link #id source block #source_block_id was not found in constellation #source_constellation_hint.]
          },
          link: id,
        ))
      } else {
        diagnostics.push(diagnostic(
          "warning",
          "source-block-ambiguous",
          [Link #id source block #source_block_id matches more than one constellation; add a `constellation` field to the endpoint.],
          link: id,
        ))
      }
    }

    if target_block == none {
      if target_id_candidates.len() == 0 or initial_target_candidates.len() == 0 {
        diagnostics.push(diagnostic(
          "warning",
          "target-block-not-found",
          if target_constellation_hint == none {
            [Link #id target block #target_block_id was not found.]
          } else {
            [Link #id target block #target_block_id was not found in constellation #target_constellation_hint.]
          },
          link: id,
        ))
      } else {
        diagnostics.push(diagnostic(
          "warning",
          "target-block-ambiguous",
          [Link #id target block #target_block_id matches more than one constellation; add a `constellation` field to the endpoint.],
          link: id,
        ))
      }
    }

    if source_block != none and source_row == none {
      diagnostics.push(diagnostic(
        "warning",
        "source-row-not-found",
        [Link #id source row #source_row_id was not found in block #source_block_id.],
        link: id,
      ))
    }

    if target_block != none and target_row == none {
      diagnostics.push(diagnostic(
        "warning",
        "target-row-not-found",
        [Link #id target row #target_row_id was not found in block #target_block_id.],
        link: id,
      ))
    }

    let source_constellation = if source_block == none { none } else { source_block.constellation }
    let target_constellation = if target_block == none { none } else { target_block.constellation }
    let source_constellation_level = if source_block == none { none } else { source_block.constellation_level }
    let target_constellation_level = if target_block == none { none } else { target_block.constellation_level }
    let source_block_level = if source_block == none { none } else { source_block.block_level }
    let target_block_level = if target_block == none { none } else { target_block.block_level }
    let endpoints_valid = source_block != none and target_block != none and source_row != none and target_row != none
    let constellation_relation = if endpoints_valid {
      link_relation(source_constellation, target_constellation, source_constellation_level, target_constellation_level)
    } else {
      "invalid"
    }
    let block_relation = if endpoints_valid and source_constellation == target_constellation {
      block_link_relation(source_block_id, target_block_id, source_block_level, target_block_level)
    } else if endpoints_valid {
      "cross-constellation"
    } else {
      "invalid"
    }
    let routing_scope = if endpoints_valid {
      link_routing_scope(source_block_id, target_block_id, source_constellation, target_constellation)
    } else {
      "invalid"
    }
    let routing_relation = if routing_scope == "cross-constellation" { constellation_relation } else { block_relation }
    let final_mode = resolve_scoped_link_mode(requested_mode, routing_scope, constellation_relation, block_relation)
    let route_supported = direct_route_supported(final_mode, routing_scope, constellation_relation, block_relation)
    let render_mode = if final_mode == "direct" and not route_supported { "link-block" } else { final_mode }

    if final_mode == "direct" and not route_supported {
      diagnostics.push(diagnostic(
        "warning",
        "direct-route-fallback",
        [Link #id requested a direct #routing_scope/#routing_relation route that Stage 8 cannot draw safely; it renders as a link-block fallback.],
        link: id,
      ))
    }

    normalized.push((
      id: id,
      source: (
        block: source_block_id,
        row: source_row_id,
        constellation: source_constellation,
        declared_constellation: source_constellation_hint,
        constellation_level: source_constellation_level,
        block_level: source_block_level,
        level: source_constellation_level,
        anchor: source_anchor,
      ),
      target: (
        block: target_block_id,
        row: target_row_id,
        constellation: target_constellation,
        declared_constellation: target_constellation_hint,
        constellation_level: target_constellation_level,
        block_level: target_block_level,
        level: target_constellation_level,
        anchor: target_anchor,
      ),
      requested_mode: requested_mode,
      constellation_relation: constellation_relation,
      block_relation: block_relation,
      routing_scope: routing_scope,
      routing_relation: routing_relation,
      relation: routing_relation,
      mode: final_mode,
      render_mode: render_mode,
      route_supported: route_supported,
      valid: endpoints_valid and routing_scope != "invalid" and supported_modes.contains(requested_mode),
      source_index: index + 1,
      declaration: field(link, "declaration", default: "links-file"),
      raw: link,
    ))
  }

  (links: normalized, diagnostics: diagnostics)
}

#let resolved_levels(constellations) = {
  let levels = ()

  for constellation in constellations {
    if not levels.contains(constellation.level) {
      levels.push(constellation.level)
    }
  }

  levels.sorted()
}

#let resolved_block_levels(constellations, blocks) = {
  let result = ()

  for constellation in constellations {
    let levels = ()
    for block_data in blocks.filter(block_data => block_data.constellation == constellation.id) {
      if not levels.contains(block_data.block_level) {
        levels.push(block_data.block_level)
      }
    }
    result.push((constellation: constellation.id, levels: levels.sorted()))
  }

  result
}

#let normalize_recipe(recipe, custom_color_schemas: ()) = {
  let metadata = field(recipe, "metadata", default: (:))
  let raw_blocks = field(recipe, "blocks", default: ())
  let color_schema = resolve_color_schema(metadata, custom_schemas: custom_color_schemas)
  let constellations = normalize_constellations(field(recipe, "constellations", default: ()), color_schema)
  let block_result = normalize_blocks(raw_blocks, constellations)
  let inline_link_result = collect_inline_links(raw_blocks)
  let combined_links = field(recipe, "links", default: ()) + inline_link_result.links
  let link_result = normalize_links(combined_links, block_result.blocks, constellations)
  let anchors = collect_row_anchors(block_result.blocks)
  let diagnostics = ()

  for item in block_result.diagnostics {
    diagnostics.push(item)
  }

  for item in inline_link_result.diagnostics {
    diagnostics.push(item)
  }

  for item in link_result.diagnostics {
    diagnostics.push(item)
  }

  (
    metadata: metadata,
    color_schema: color_schema,
    constellations: constellations,
    blocks: block_result.blocks,
    links: link_result.links,
    anchors: anchors,
    diagnostics: diagnostics,
    layout: (
      levels: resolved_levels(constellations),
      block_levels: resolved_block_levels(constellations, block_result.blocks),
      direction: "parents-left-children-right",
    ),
  )
}
