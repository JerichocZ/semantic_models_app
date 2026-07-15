// Preset color schemas ======================================================
// A schema matrix is cycled in constellation source order. Each entry styles
// both the constellation container and the blocks it contains.
#import "settings.typ": default_color_scheme

#let preset_color_schemas = (
  (
    id: "ember",
    label: [Ember],
    matrix: (
      (accent: rgb("#c7522a"), fill: rgb("#fff2ec"), block_accent: rgb("#d86438"), block_fill: rgb("#fffaf7")),
      (accent: rgb("#9b6a18"), fill: rgb("#fff7e6"), block_accent: rgb("#b9811e"), block_fill: rgb("#fffcf5")),
      (accent: rgb("#83503d"), fill: rgb("#fbf0eb"), block_accent: rgb("#9b624c"), block_fill: rgb("#fffaf8")),
      (accent: rgb("#7a3f61"), fill: rgb("#fbeef5"), block_accent: rgb("#914d72"), block_fill: rgb("#fff9fc")),
      (accent: rgb("#7b6227"), fill: rgb("#fbf7e8"), block_accent: rgb("#947734"), block_fill: rgb("#fffdf7")),
    ),
  ),
  (
    id: "tidal",
    label: [Tidal],
    matrix: (
      (accent: rgb("#176b87"), fill: rgb("#eaf7fb"), block_accent: rgb("#287f9d"), block_fill: rgb("#f8fdff")),
      (accent: rgb("#286f5c"), fill: rgb("#ecf8f2"), block_accent: rgb("#398673"), block_fill: rgb("#f8fdfb")),
      (accent: rgb("#455fa6"), fill: rgb("#f0f3ff"), block_accent: rgb("#5874bc"), block_fill: rgb("#fafbff")),
      (accent: rgb("#5a5c96"), fill: rgb("#f3f2fc"), block_accent: rgb("#6d70ad"), block_fill: rgb("#fbfbff")),
      (accent: rgb("#46737c"), fill: rgb("#eff8f9"), block_accent: rgb("#598b95"), block_fill: rgb("#f9fdfd")),
    ),
  ),
)

#let schema_by_id(schemas, id) = {
  schemas.find(schema => schema.id == id)
}

#let resolve_color_schema(metadata, custom_schemas: ()) = {
  // Custom schemas are first so a diagram can intentionally replace a preset.
  let schemas = custom_schemas + preset_color_schemas
  let requested = if metadata.keys().contains("color_scheme") {
    metadata.color_scheme
  } else {
    default_color_scheme
  }
  let selected = schema_by_id(schemas, requested)

  if selected != none {
    selected
  } else {
    schema_by_id(schemas, default_color_scheme)
  }
}

#let color_theme_for(schema, source_index) = {
  let matrix = schema.matrix
  let index = calc.rem(source_index - 1, matrix.len())
  matrix.at(index)
}
