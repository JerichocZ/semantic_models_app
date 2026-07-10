#import "../page_style.typ": body_text_code_size, color_sec

// Params
#let colorsArray = (
  ("Folders", color_sec),
  ("py", rgb("#630029")),
  ("exe", rgb("#8a1303")),
  ("bin", rgb("#8a1303")),
  ("typ", rgb("#73038a")),
  ("gitignore", rgb("#038a8a")),
  ("toml", rgb("#038a8a")),
  ("md", rgb("#03058a")),
  ("yml", rgb("#8a0352")),
  ("sh", rgb("#8a4b03")),
)

// {
// "py", rgb("#358a03")
// }

// This file contains a command definition to print a dirtree object
#let to-str(v) = {
  // If it's not content, normal str() is fine
  if type(v) != content {
    str(v)
  } // Single text node
  else if v.has("text") {
    v.text
  } // Multiple children: flatten them
  else if v.has("children") {
    v.children.map(to-str).join("")
  } // Single child
  else if v.has("child") {
    to-str(v.child)
  } // Body field (common on many elements)
  else if v.has("body") {
    to-str(v.body)
  } // Fallback
  else {
    ""
  }
}

// Is node at index `idx` the last item at its level?
#let is-last(nodes, idx, level: none) = {
  let lvl = if level == none { nodes.at(idx).lvl } else { level }
  for j in range(idx + 1, nodes.len()) {
    let l2 = nodes.at(j).lvl
    if l2 < lvl { return true }
    if l2 == lvl { return false }
  }
  true // we never saw same or lower => last
}

// Find the closes ancenstor at level 'lev' for node at 'idx
#let find-ancestor(nodes, idx, lev) = {
  for j in range(idx, -1, step: -1) {
    if nodes.at(j).lvl == lev { return j }
  }
  idx
}

#let color-names(txt) = {
  // Here, text are strings related to files or folders.
  // If ends with a /, it is a folder
  // If it is a file, it must have <name>.<extension>
  let t = txt.trim()

  if t.ends-with("/") {
    // Folder
    let folder-color = colorsArray.find(c => c.at(0) == "Folders")
    return text(fill: folder-color.at(1))[#txt]
  } else {
    if t.contains(".") {
      let extension = t.split(".").last() // Split divide the string into an array [name, extension]

      let found = colorsArray.find(c => c.at(0) == extension)
      if found != none {
        return text(fill: found.at(1))[#txt]
      }
    }
  }
  txt
}

#let dirtree(..items) = [
  #set text(font: "JetBrains Mono", size: body_text_code_size)
  #set par(first-line-indent: 0pt, spacing: 4pt)

  // First stage: map all nodes into the nodes variable with (lvl: int, tex: string) format
  #let nodes = (
    items
      .pos()
      .map(it => {
        let elems = it.children.filter(e => e.has("number"))

        if elems.len() == 0 {
          // text(fill: red)[Invalid input. Item skipped]
          none
        } else {
          let elem = elems.at(0)
          let lvl = elem.number

          if type(lvl) != int {
            // text(fill: red)[Non-integer as level. Item skipped]
            none
          } else {
            let tex = to-str(elem.body).trim()
            (lvl: lvl, tex: tex)
          }
        }
      })
  ).filter(node => node != none)

  // Render stage
  #for i in range(0, nodes.len()) [
    #let node = nodes.at(i)
    #let lvl = node.lvl
    #let tex = node.tex

    // Root level: just print the name
    #if lvl == 1 [
      #color-names(tex)
      #linebreak()
    ] else [
      #let prefix = {
        let pref = ""
        if lvl >= 2 {
          for level in range(2, lvl) {
            let anc = find-ancestor(nodes, i, level)
            pref += if is-last(nodes, anc) { "  " } else { "│ " }
          }
        }
        pref + if is-last(nodes, i) { "└─" } else { "├─" }
      }
      // Here, prefix are all characters that indent the directories and tex are the files and folders names.
      #prefix#color-names(tex)
    ]
  ]
]
