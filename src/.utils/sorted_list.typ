#import "../page_style.typ": *

#let extract-key(node) = {
  // Ignore empty sequeces
  if node == [ ] {
    return none
  }

  // Case 1: direct text
  if node.has("text") {
    return node.text
  }

  // Case 2: wrapped in child: (styled, etc.)
  if node.has("child") {
    let t = extract-key(node.child)
    if t != none { return t }
  }

  // Case 3: Wrapped in childred: sequences(...)
  if node.has("children") {
    for ch in node.children {
      let t = extract-key(ch)
      if t != none { return t }
    }
  }

  // Case 4: Wrapped in body: link(...)
  if node.has("body") {
    let t = extract-key(node.body)
    if t != none { return t }
  }

  none
}

#let sorted-indexer(items) = {
  let keys = ()
  for index in range(0, items.pos().len()) {
    for child in items.pos().at(index).children {
      if child != [ ] {
        keys.push((child, index))
        break
      }
    }
  }

  let sorted_keys = keys.sorted(key: ky => {
    let node = ky.at(0)
    let k = extract-key(node)
    if k == none { "" } else { k }
  })

  let sorted_indexes = sorted_keys.map(key => {
    return key.at(1)
  })
  return sorted_indexes
}

#let sortedList(..items) = {
  let sorted_indexes = sorted-indexer(items)

  let outputs = sorted_indexes.map(index => {
    return items.at(index)
  })
  for output in outputs [
    - #output
  ]
}
