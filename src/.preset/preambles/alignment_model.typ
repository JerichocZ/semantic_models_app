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

#let row_anchor(block_id, row_id, side) = {
  block_id + "." + row_id + "." + canonical_anchor_side(side)
}

#let row_anchor_set(block_id, row_id) = (
  left: row_anchor(block_id, row_id, "left"),
  right: row_anchor(block_id, row_id, "right"),
  right_outer: row_anchor(block_id, row_id, "right-outer"),
  center: row_anchor(block_id, row_id, "center"),
  source: row_anchor(block_id, row_id, "source"),
  target: row_anchor(block_id, row_id, "target"),
)

#let endpoint_anchor(endpoint, role) = {
  let block_id = field(endpoint, "block", default: none)
  let row_id = field(endpoint, "row", default: none)
  let requested_side = field(endpoint, "side", default: role)
  let side = canonical_anchor_side(requested_side)

  (
    requested_side: requested_side,
    side: side,
    id: if block_id == none or row_id == none {
      none
    } else {
      row_anchor(block_id, row_id, side)
    },
  )
}

#let normalize_rows(block_data, block_id) = {
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
        anchors: row_anchor_set(block_id, id),
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
          id: row_anchor(block_data.id, row.id, side),
          block: block_data.id,
          row: row.id,
          side: side,
          constellation: block_data.constellation,
          level: block_data.constellation_level,
          order: (
            constellation: block_data.constellation_order,
            block: block_data.order,
            row: row.order,
          ),
        ))
      }
    }
  }

  anchors
}

#let normalize_constellations(constellations) = {
  let normalized = ()

  for index in range(0, constellations.len()) {
    let constellation = constellations.at(index)
    let id = field(constellation, "id", default: "constellation-" + str(index + 1))
    let level = field(constellation, "level", default: 1)
    let order = field(constellation, "order", default: index + 1)

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
      raw: constellation,
    ))
  }

  normalized.sorted(key: constellation => constellation.level * 10000 + constellation.order)
}

#let constellation_by_id(constellations, id) = {
  constellations.find(constellation => constellation.id == id)
}

#let block_by_id(blocks, id) = {
  blocks.find(block_data => block_data.id == id)
}

#let row_by_id(block_data, id) = {
  if block_data == none {
    none
  } else {
    block_data.rows.find(row => row.id == id)
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
    let block_order = field(block_data, "order", default: index + 1)
    let level = if constellation == none { none } else { constellation.level }
    let constellation_order = if constellation == none { none } else { constellation.order }

    if constellation == none {
      diagnostics.push(diagnostic(
        "warning",
        "block-constellation-not-found",
        [Block #id references unknown constellation #constellation_id.],
      ))
    }

    let rows = normalize_rows(block_data, id)

    normalized.push((
      id: id,
      title: title_of(block_data, id),
      constellation: constellation_id,
      constellation_found: constellation != none,
      constellation_level: level,
      constellation_order: constellation_order,
      order: block_order,
      source_index: index + 1,
      rows: rows,
      anchors: collect_row_anchors(((id: id, constellation: constellation_id, constellation_level: level, constellation_order: constellation_order, order: block_order, rows: rows),)),
      layout: (
        column: level,
        constellation_stack_order: constellation_order,
        block_stack_order: block_order,
      ),
      raw: block_data,
    ))
  }

  let sorted = normalized.sorted(key: block_data => {
    let level = if block_data.constellation_level == none { 9999 } else { block_data.constellation_level }
    let constellation_order = if block_data.constellation_order == none { 9999 } else { block_data.constellation_order }
    level * 1000000 + constellation_order * 1000 + block_data.order
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

#let resolve_link_mode(requested_mode, relation) = {
  let supported_modes = ("auto", "direct", "link-block")

  if not supported_modes.contains(requested_mode) or relation == "invalid" {
    return "invalid"
  }

  if requested_mode != "auto" {
    return requested_mode
  }

  if relation == "internal" or relation == "adjacent-level" {
    "direct"
  } else {
    "link-block"
  }
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
    let target_block_id = field(target, "block", default: none)
    let target_row_id = field(target, "row", default: none)
    let source_block = block_by_id(blocks, source_block_id)
    let target_block = block_by_id(blocks, target_block_id)
    let source_row = row_by_id(source_block, source_row_id)
    let target_row = row_by_id(target_block, target_row_id)
    let source_anchor = endpoint_anchor(source, "source")
    let target_anchor = endpoint_anchor(target, "target")

    if not supported_modes.contains(requested_mode) {
      diagnostics.push(diagnostic(
        "warning",
        "invalid-link-mode",
        [Link #id uses unsupported mode #requested_mode.],
        link: id,
      ))
    }

    if source_block == none {
      diagnostics.push(diagnostic(
        "warning",
        "source-block-not-found",
        [Link #id source block #source_block_id was not found.],
        link: id,
      ))
    }

    if target_block == none {
      diagnostics.push(diagnostic(
        "warning",
        "target-block-not-found",
        [Link #id target block #target_block_id was not found.],
        link: id,
      ))
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
    let source_level = if source_block == none { none } else { source_block.constellation_level }
    let target_level = if target_block == none { none } else { target_block.constellation_level }
    let relation = link_relation(source_constellation, target_constellation, source_level, target_level)
    let final_mode = resolve_link_mode(requested_mode, relation)

    normalized.push((
      id: id,
      source: (
        block: source_block_id,
        row: source_row_id,
        constellation: source_constellation,
        level: source_level,
        anchor: source_anchor,
      ),
      target: (
        block: target_block_id,
        row: target_row_id,
        constellation: target_constellation,
        level: target_level,
        anchor: target_anchor,
      ),
      requested_mode: requested_mode,
      relation: relation,
      mode: final_mode,
      valid: relation != "invalid" and supported_modes.contains(requested_mode),
      source_index: index + 1,
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

#let normalize_recipe(recipe) = {
  let constellations = normalize_constellations(field(recipe, "constellations", default: ()))
  let block_result = normalize_blocks(field(recipe, "blocks", default: ()), constellations)
  let link_result = normalize_links(field(recipe, "links", default: ()), block_result.blocks, constellations)
  let anchors = collect_row_anchors(block_result.blocks)
  let diagnostics = ()

  for item in block_result.diagnostics {
    diagnostics.push(item)
  }

  for item in link_result.diagnostics {
    diagnostics.push(item)
  }

  (
    metadata: field(recipe, "metadata", default: (:)),
    constellations: constellations,
    blocks: block_result.blocks,
    links: link_result.links,
    anchors: anchors,
    diagnostics: diagnostics,
    layout: (
      levels: resolved_levels(constellations),
      direction: "parents-left-children-right",
    ),
  )
}
