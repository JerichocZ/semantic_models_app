#let field(item, key, default: none) = {
  if item.keys().contains(key) {
    item.at(key)
  } else {
    default
  }
}

#let constellation_by_id(constellations, id) = {
  constellations.find(constellation => constellation.id == id)
}

#let blocks_for_constellation(blocks, constellation_id) = {
  blocks.filter(block_data => block_data.constellation == constellation_id)
}

#let links_for_block(links, block_id) = {
  links.filter(link_data => {
    let source_block = field(link_data, "source_block", default: none)
    let target_block = field(link_data, "target_block", default: none)
    source_block == block_id or target_block == block_id
  })
}

#let attr_text(attrs) = {
  if attrs.len() == 0 {
    []
  } else {
    attrs.join(" ")
  }
}

#let data_type_text(data_type, data_type_abstractions) = {
  if data_type == none {
    return ""
  }

  let found = data_type_abstractions.find(abstraction => abstraction.source == data_type.source)
  let key = if found == none { data_type.source } else { found.key }

  if data_type.keys().contains("size") {
    key + " " + str(data_type.size)
  } else {
    key
  }
}
