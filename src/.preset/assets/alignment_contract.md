# Alignment contract

Stage 3 defines a resolver contract, not the final drawing system.

## Entry points

- `src/.preset/preambles/alignment_model.typ`
  - `normalize_recipe(recipe)`
  - `normalize_constellations(constellations)`
  - `normalize_blocks(blocks, constellations)`
  - `normalize_links(links, blocks, constellations)`
  - `resolve_link_mode(requested_mode, relation)`
- `src/.preset/alignment_contract.typ`
  - Compiles a readable report for the example recipe.
- `src/.preset/preambles/layouts.typ`
  - `diagram_general_page(...)`
  - `diagram_constellation_page(...)`
  - Resolves the current recipe and renders the Stage 4 general page.
- `src/.preset/preambles/elements.typ`
  - `constellation_container(...)`
  - `compact_database_block(...)`

## Normalized layout fields

Constellations resolve to:

- `level`
- `order`
- `layout.column`
- `layout.stack_order`

Blocks resolve to:

- `constellation`
- `constellation_level`
- `constellation_order`
- `order`
- `rows`
- `layout.column`
- `layout.constellation_stack_order`
- `layout.block_stack_order`

Links resolve to:

- source and target block, row, constellation, and level
- source and target row anchor metadata
- `relation`: `internal`, `adjacent-level`, `same-level`, `skip-level`, or `invalid`
- `requested_mode`
- final `mode`: `direct`, `link-block`, or `invalid`

## Auto mode rules

- same constellation -> `direct`
- adjacent levels -> `direct`
- same-level constellations -> `link-block`
- skip-level references -> `link-block`
- invalid references -> diagnostic and `invalid`

Advanced graph layout, smart routing, and anchor drawing are intentionally left for later stages.

## Stage 4 visual layout

The first visual layout pass renders:

- levels as horizontal columns
- constellations as colored containers stacked by `order`
- blocks inside each constellation stacked by block `order`
- rows as compact table rows

No direct arrows or link-blocks are drawn yet. The row data keeps stable `id`
fields so later stages can introduce anchors without changing the authoring
shape.

## Stage 5 row anchors

Every normalized row receives deterministic anchor names through:

- `row_anchor(block_id, row_id, side)`
- `row_anchor_set(block_id, row_id)`
- `endpoint_anchor(endpoint, role)`

Supported sides:

- `left`
- `right`
- `center`
- `source`, which resolves to `left`
- `target`, which resolves to `right`

The current convention follows the parent-left / child-right layout:

- source/FK row -> left-side anchor
- target/PK row -> right-side anchor

The compact renderer places both anchors outside the table in the row's side
gutters. Their horizontal positions are the same points used by link-block
arrows: the left anchor is where a source link-block line begins, and the right
anchor is where a target link-block line ends. Their vertical position is the
exact center of the row.

Rows with one or more target-side link-blocks also expose a conditional
`right-outer` anchor at the far edge of the link-block marker. A direct arrow
targeting that row uses `right-outer`, so it stops before crossing the badge.
The outer anchor adds the same clearance used between a table edge and its
normal row port. Its width is reserved inside the target-side row gutter, and
the constellation inset remains outside that reserve, so the anchor and its
arrowhead cannot overlap the constellation border. Rows without a target-side
link-block continue using the normal `right` anchor.

Constellation height follows its stacked content. Width uses
`layout_column_width` as a minimum and grows when a contained block needs an
outer target anchor. The widest constellation determines the width of its
level column; page and direct-arrow overlay widths use those resolved level
widths.

Example anchor ids:

- `mc_machines.process_id.left`
- `mc_processes.process_id.right`

The visual renderer can show left/right row markers when
`layout_show_anchor_debug` is true. The info column also includes a row-anchor
debug panel listing resolved source-to-target anchor pairs for current links.

These anchors are stable row ports rather than markers embedded in table
cells. Stage 7 uses them to route inter-level direct arrows without entering
the block body.

## Stage 6 link-blocks

Resolved links whose final `mode` is `link-block` render paired compact badges
outside the block table:

- source row: badge on the left side
- target row: matching badge on the right side

Helper functions:

- `link_block_label(label, role: "source")`
- `link_block_stack(links, role: "source")`
- `link_block_code(link)`
- `row_destination_label(link_scope, block_id, row_id)`
- `dedupe_link_blocks_by_code(links)`
- `link_block_arrow()`
- `link_block_badge(link_data, role: "source", clickable: false, link_scope: "general")`
- `link_block_marker(link_data, role: "source", clickable: false, link_scope: "general")`
- `link_block_marker_stack(links, role: "source", visible_block_ids: none, link_scope: "general")`
- `link_blocks_for_source(links, block_id, row_id)`
- `link_blocks_for_target(links, block_id, row_id)`
- `link_blocks_panel(resolved)`

The badge text abbreviates the target endpoint and is rendered uppercase. For
example, `gw_gateways.gateway_id` in constellation `gw` becomes `GWGWGI`.
Target-side badges are deduplicated by rendered code, so multiple source rows
referencing the same target row share one target-side badge.

Source badges are native Typst links when the target row is visible on the
current page. The renderer scopes row labels by page, for example `general` or
`constellation:hist`, so a future multi-page output can avoid duplicate labels.

CeTZ renders local arrow pairs in the link-block side gutters:

- source row -> source badge
- target badge -> target row

## Stage 7 direct arrows

Adjacent-level direct links render as orthogonal row-to-row arrows. Each boundary
between two visible levels has a routing pipe centered in the normal column
gap. A pipe has no additional width when no direct link crosses it. Otherwise,
its width is:

```text
2 * pipe-inset + lane-count * line-width + (lane-count - 1) * lane-gutter
```

Each link receives a stable lane based on its resolved link order. The route
starts at the external source-side row port, travels horizontally to its lane,
moves vertically in the pipe, then travels horizontally to the external
target-side row port. Only the target end receives an arrowhead. The arrow uses
the source constellation color, and its CeTZ `stealth` arrowhead is explicitly
filled with the same color.

`layout_direct_arrow_corner_radius` controls the rounded bends between the
horizontal branches and the vertical pipe lane.

Current limitation: same-constellation direct links have no inter-level pipe,
and explicit skip-level direct links would need multiple pipes. Both routing
cases remain deferred.

Examples in the preset:

- explicit `direct`: `mc_machines.gateway_id -> gw_gateways.gateway_id`
- explicit `direct`: `mc_processes.process_name -> lo_locations.location_id`
- auto same-level: `ds_devices.gateway_id -> gw_gateways.gateway_id`
- auto skip-level: `hist_samples.location_id -> lo_locations.location_id`
