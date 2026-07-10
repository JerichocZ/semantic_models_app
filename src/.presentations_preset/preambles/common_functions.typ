#import "settings.typ": body_text_code_size, color_main, color_sec, font_mono
// PLAIN TEXT  ===============================================
#let textColored(tex) = [
  #text(fill: color_main, weight: "bold")[#tex]]

// CODE ===============================================
#let codeColored(code) = {
  show raw.where(block: false): it => {
    text(
      font: font_mono,
      fill: color_sec,
      size: body_text_code_size,
      weight: 700,
      spacing: 60%,
    )[#it]
  }
  raw(code, block: false)
}

#let codeSimple(code) = {
  show raw.where(block: false): it => {
    text(
      font: font_mono,
      size: body_text_code_size,
      weight: 700,
      spacing: 60%,
    )[#it]
  }
  raw(code, block: false)
}

// INDEX ===============================================
#let indexed(body, labl: "", self_labl: false) = {
  if labl != "" and self_labl {
    let labl_parts = str(labl).split(":")
    return [
      #link(labl)[#underline(offset: 1.5pt)[#textColored(body)]]
      #label("index:" + labl_parts.at(1))
    ]
  } else if labl != "" {
    return [
      #link(labl)[#underline(offset: 1.5pt)[#textColored(body)]]
    ]
  }
  return textColored(body)
}

#let indexReturn(labl) = {
  let labl_parts = str(labl).split(":")
  link(label("index:" + labl_parts.at(1)))[#underline(offset: 1.5pt)[
    #text(fill: color_sec, size: 9pt)[Regresar al índice]
  ]]
}

#let indexReturnBlock(labl) = {
  let labl_parts = str(labl).split(":")
  link(labl)[#underline(offset: 1.5pt)[
    #text(fill: color_sec, size: 9pt)[Regresar al índice]
  ]]
}

#let fullNameLink(labl) = {
  show ref: it => {
    return link(it.target)[#text()[
      #it.element.body
    ]]
  }
  labl
}

// TABLES =================================
#let tableBashParams(..items) = {
  set text(size: 10pt)

  table(
    columns: (1.8cm, auto),
    align: (right, left),
    stroke: 0pt,
    ..items
  )
}

#let cell_colored(bdy, rowspan: 1, colspan: 1) = {
  let back_color = color_main
  let font_color = white

  table.cell(
    fill: back_color,
    align: center,
    rowspan: rowspan,
    colspan: colspan,
    text(fill: font_color, weight: "bold", bdy),
  )
}
