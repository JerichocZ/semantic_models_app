# Intruduction
This document contains tasks that the AI agents must comply. The `Tasks` section has all activities with the following format:

- `<Task name>`
    - `Context`: Context related to the task
    - `Activities`: Has a list with all actions the AI agent must perform. It ussually has several stages. Each stage may have a purpose.
    - `Agent comments`: Section where the agent write things related to the task.
        - `Status`: Ussually, the achievement date and an status mark; if the tasks has several stages, it will have tha date and status of each one.
        - `Information`: Ussually it is left empty. If the tasks have some info searching or consult stages, the AI agent writes the results here.
        - `Recomendations`: It is ussually left empty. If the tasks find some improvements related to the task result, he must write them here.

If empty sections, delete them! no `# Recomendations` with nothing.

# Tasks
## Diagrams base
### Context
We are in the developing of a first version of this diagram maker app. We want to define a first version folder structure for each diagram. Our target is the `src/.preset` folder.

We may inspire in the `src/.presentations_preset` structure. It is a `.preset` structure for another app pretty similar to this one but for presentations. There, we define layouts and settings and the presentations building is just calling those presents. Here we may want something similar: defining blocks and constellations and call them in the `main.typ` file.

### Activities
#### Stage 1
- Do not implement anything yet. Please study the `src/.presentations_preset` structure and propose, in the `Information` section of this dicument, an structure folder for each diagram for this project. Describe folders, files and their purpose. We will implement them in later Stages.

#### Stage 2
- _Purpose_: Our target is making the `.preset` folder to generate a single page with a block.

1. Please feed the `.preset` folder with the files and folders that you described before. Please code each file having in mind what we want to reach at the end. But, for a first step please make its `main.typ` file to show a single block that represents a database table with some dummy columns and constraints.

#### Stage 3 — Define the Alignment Data Model and Layout Contract

Please read `alignment.md` before coding.

In this stage, do **not** implement the full visual alignment system yet. The goal is to define the internal data model and layout contract that later stages will use.

##### Goal

Create a clear internal representation for:

* constellations
* blocks
* rows
* links/references
* layout hints
* resolved layout positions
* resolved link modes

The implementation should support the alignment rules described in `alignment.md`, especially:

* parents on the left
* children on the right
* manual constellation `level`
* manual constellation `order`
* manual block `order`
* `direct`, `link-block`, and `auto` link modes
* same-level and skip-level references defaulting to `link-block`
* adjacent-level references defaulting to `direct`

##### Requirements

Implement or define the structures/functions needed to represent a diagram recipe.

The model should support this kind of input conceptually:

```yaml
constellations:
  - id: lo
    title: Locations
    level: 1
    order: 1

  - id: mc
    title: Maintenance
    level: 2
    order: 1

blocks:
  - id: lo_locations
    constellation: lo
    order: 1

  - id: mc_machines
    constellation: mc
    order: 2

links:
  - source:
      block: mc_machines
      row: process_id
    target:
      block: mc_processes
      row: process_id
    mode: auto
```

The exact syntax may follow the current project conventions. Do not force YAML if the project already uses Typst dictionaries or another structure.

##### Implement

Create functions or modules that can:

1. Normalize the input recipe.
2. Resolve missing constellation order using source order as fallback.
3. Resolve missing block order using source order as fallback.
4. Resolve each block’s constellation.
5. Resolve each link’s source and target constellation.
6. Resolve each link’s source and target level.
7. Compute whether a link is:

   * internal to the same constellation
   * adjacent-level
   * same-level
   * skip-level
   * invalid or unresolved
8. Resolve `auto` link mode using the first simple rules:

   * same constellation -> `direct`
   * adjacent constellation levels -> `direct`
   * same-level constellations -> `link-block`
   * skip-level constellation reference -> `link-block`
   * unresolved or invalid reference -> diagnostic warning

##### Non-goals

Do not implement final drawing yet.

Do not implement advanced graph layout.

Do not implement smart routing.

Do not implement crossing minimization.

Do not implement plugin/external language support.

##### Acceptance Criteria

At the end of this stage:

1. There is a small example diagram recipe.
2. The project can resolve the recipe into a normalized internal layout structure.
3. The resolved structure clearly shows constellation levels and orders.
4. The resolved structure clearly shows block orders.
5. The resolved structure clearly shows each link’s final mode.
6. Invalid references produce readable diagnostics.
7. The implementation is documented enough for the next stage.

Please finish by reporting:

* files changed
* main functions added
* example input used
* known limitations
* what the next stage should implement

#### Stage 4 — Implement Manual Constellation and Block Placement

Please read `alignment.md` and use the Stage 3 layout contract.

In this stage, implement the first real visual layout pass.

##### Goal

Render constellations in horizontal columns based on their manually resolved `level`.

Make constellations visible. They should be colored rectangles with their respective name and all their respective blocks in. Colors are important, each represents a constellation.

Inside each column, stack constellations vertically based on their resolved `order`.

Inside each constellation, stack blocks vertically based on their resolved block `order`.

This stage should produce a readable static diagram without direct arrows yet.

##### Requirements

Implement the layout rules:

* level 1 constellations are placed in column 1
* level 2 constellations are placed in column 2
* level 3 constellations are placed in column 3
* lower levels are further left
* higher levels are further right
* constellations in the same level are stacked vertically
* blocks inside a constellation are stacked vertically
* manual order has priority
* source order is the fallback

##### Implement

Add layout configuration options for:

* column gap
* constellation vertical gap
* block vertical gap
* page margin
* constellation padding
* block padding
* row height or row spacing

The result should be deterministic: the same input should always produce the same layout.

##### Visual Output

Render:

* constellation containers
* constellation titles
* blocks inside each constellation
* block titles
* table rows or simple row placeholders

For now, rows only need to appear visually. They do not yet need final arrow anchors, but the implementation should avoid decisions that would make row anchors impossible later.

##### Non-goals

Do not implement direct arrows yet.

Do not implement link-blocks yet.

Do not implement automatic graph layout.

Do not implement collision avoidance.

Do not implement page splitting yet unless it is already easy with existing code.

##### Acceptance Criteria

At the end of this stage:

1. A general page can render multiple constellation levels.
2. Same-level constellations are vertically stacked.
3. Blocks are rendered inside their constellation.
4. Manual constellation order is respected.
5. Manual block order is respected.
6. A simple example with `lo`, `ds`, `gw`, and `mc` renders correctly.
7. The page size either fits the content or uses the project’s current page sizing strategy.

Please finish by reporting:

* files changed
* layout functions added
* example rendered
* limitations
* what must be done before direct arrows are safe to implement

#### Stage 5 — Add Stable Row Anchors for Future Arrows

Please read `alignment.md` and continue from Stage 4.

This is a critical stage. Do not implement full arrows until row anchors are stable.

##### Goal

Modify the block/table renderer so that every linkable row exposes a stable anchor that later direct arrows can target.

The alignment system needs to connect foreign-key rows to referenced primary-key rows. Therefore, every row that can participate in a reference must have a predictable identity and position.

##### Requirements

Each rendered row should have a stable anchor identity based on:

* block id
* row id or row name
* optional side of the row:

  * left
  * right
  * center
  * source side
  * target side

The system should be able to refer to anchors conceptually like:

```text
row-anchor("mc_machines", "process_id", "left")
row-anchor("mc_processes", "process_id", "right")
```

The exact API may follow the current project style.

##### Implement

Add support for:

1. Row ids.
2. Stable anchor names.
3. Anchor metadata collection if needed.
4. Source-side and target-side anchor conventions.
5. A simple debug option to display anchor markers or anchor labels.

The implementation should make it possible for a later stage to draw a direct arrow from a source row to a target row.

##### Important Design Rule

Because the visual layout places parents on the left and children on the right, many database reference arrows will visually point from right to left.

For example:

```text
child FK row  --->  parent PK row
```

So the source row may often use its left-side anchor, and the target row may use its right-side anchor.

##### Non-goals

Do not implement final arrow routing yet.

Do not implement smart orthogonal connectors.

Do not implement arrow crossing minimization.

Do not redesign the whole block renderer unless necessary.

##### Acceptance Criteria

At the end of this stage:

1. Every rendered row can be uniquely identified.
2. Every rendered row can expose at least left and right anchors.
3. A debug mode can show or verify anchor positions.
4. The implementation has a small example with at least one FK row and one PK row.
5. The next stage can use these anchors to draw direct arrows.

Please finish by reporting:

* files changed
* anchor API added
* example anchors created
* any limitations in the current Typst/CeTZ approach
* whether direct arrows are now safe to implement



#### Stage 6 — Implement Link Mode Resolution and Link-Blocks

Please read `alignment.md` and continue from the previous stages.

In this stage, implement link-block rendering before direct arrows. Link-blocks are simpler and are the safest fallback for same-level, skip-level, or visually noisy references.

##### Goal

Render references whose final resolved mode is `link-block`.

A link-block is a small visual label placed to the left of the source row and to the right of the target row. It represents a reference without drawing a long direct arrow.

##### Requirements

Support explicit and automatic link modes:

* `direct`
* `link-block`
* `auto`

The final mode should already be resolved by the layout/model layer. This stage should render all links whose final mode is `link-block`.

##### Link-Block Rules

Use link-blocks when:

* the link mode is explicitly `link-block`
* the link is same-level and mode is `auto`
* the link is skip-level and mode is `auto`
* the link is unresolved but should still be shown as a warning, if appropriate
* the reference would be too far for a first direct-arrow implementation

##### Visual Behavior

On the source row, render a compact label such as:

```text
→ mc_machines.machine_id
```

On the target row, optionally render a compact reverse label such as:

```text
← referenced by mc_registries.machine_id
```

For the first implementation, the source-side link-block is required.

The target-side reverse link-block is optional, but the data model should not prevent adding it later.

##### Non-goals

Do not implement direct arrows in this stage.

Do not implement advanced routing.

Do not implement automatic noise reduction.

Do not implement collision avoidance between link-blocks beyond simple spacing.

##### Acceptance Criteria

At the end of this stage:

1. Explicit `link-block` links render as link-blocks.
2. `auto` same-level references render as link-blocks.
3. `auto` skip-level references render as link-blocks.
4. Link-block labels identify the target block and row.
5. Link-block rendering works inside the general page.
6. Link-block rendering works or degrades cleanly on constellation pages.
7. The implementation includes a small example with at least one skip-level or same-level reference.

Please finish by reporting:

* files changed
* link-block API added
* example rendered
* limitations
* what remains before direct arrows


#### Stage 7 — Implement Direct Arrows Between Row Anchors

Please read `alignment.md` and continue from the previous stages.

Only start this stage after stable row anchors exist.

##### Goal

Render direct arrows for links whose final resolved mode is `direct`.

Direct arrows should connect source rows to target rows using the row anchors created in the previous stage.

##### Requirements

Direct arrows should be used when:

* the link mode is explicitly `direct`
* the link mode is `auto` and the source and target are in the same constellation
* the link mode is `auto` and the source and target constellations are in adjacent levels

The renderer should respect explicit user overrides.

##### Arrow Direction

For database references, the logical source is usually the foreign-key row and the logical target is the referenced primary-key row.

Because the diagram places parents on the left and children on the right, many arrows will visually point from right to left.

Example:

```text
mc_machines.process_id  --->  mc_processes.process_id
```

But visually this may appear as:

```text
mc_processes.process_id  <---  mc_machines.process_id
```

Do not reverse the data model just to match the visual direction.

##### Implement

Add direct-arrow rendering using the project’s current drawing system.

The first implementation may use simple straight connectors.

Preferred behavior:

* source row left/right anchor chosen according to relative position
* target row left/right anchor chosen according to relative position
* simple arrow head at the target
* optional label disabled by default
* debug mode available if useful

##### Fallback Behavior

If an anchor cannot be found:

* do not crash the whole diagram
* emit a readable diagnostic
* optionally render the link as a link-block fallback

##### Non-goals

Do not implement perfect routing.

Do not implement automatic crossing minimization.

Do not implement obstacle avoidance.

Do not implement curved or orthogonal smart connectors unless already trivial.

##### Acceptance Criteria

At the end of this stage:

1. Explicit `direct` links render as arrows.
2. `auto` same-constellation links render as arrows.
3. `auto` adjacent-level links render as arrows.
4. Missing anchors produce diagnostics.
5. A simple parent-left / child-right example renders correctly.
6. Direct arrows and link-blocks can coexist in the same diagram.

Please finish by reporting:

* files changed
* arrow rendering approach
* example rendered
* known limitations
* whether any Typst/CeTZ limitations were found


### Agents comments
#### Status
- 2026-07-09: Stage 1 completed. Proposed base folder structure added in the Information section.
- 2026-07-09: Stage 2 completed. `src/.preset` now has the proposed scaffold and compiles to a single page with one dummy database table block.
- 2026-07-10: Stage 3 completed. Added an alignment data model resolver, example recipe, readable contract report, and diagnostics for unresolved references.
- 2026-07-10: Stage 4 completed. The main preset page now renders manual constellation columns by level, stacks same-level constellations by order, and stacks blocks inside each constellation by block order.
- 2026-07-10: Stage 5 completed. Added stable row anchor identities, source/target side conventions, visible row anchor markers, and a debug panel listing resolved link anchor pairs.
- 2026-07-10: Stage 6 completed. Added source-side link-block rendering for resolved `link-block` links, plus explicit, same-level auto, and skip-level auto examples.
- 2026-07-10: Stage 7 partially implemented. Adjacent-level direct links render between invisible external row ports through lane-sized routing pipes. Shared link-block clearances, filled arrowheads, conditional outer target ports, and configurable rounded corners prevent overlap. Same-constellation, skip-level direct routing, and missing-anchor reporting remain pending.
#### Information
The `src/.presentations_preset` folder uses a simple and useful split: `main.typ` assembles the final document, while `preambles/` contains settings, page style, low-level elements, layout builders, and common helpers. For diagrams, the same idea should stay, but each diagram also needs a clear data layer because blocks, constellations, links, and legends are the main user-authored content.

Proposed first version structure for each diagram folder:

```txt
src/.preset/
  main.typ
  data/
    metadata.typ
    constellations.typ
    blocks.typ
    links.typ
    legend.typ
  preambles/
    settings.typ
    page_style.typ
    elements.typ
    layouts.typ
    common_functions.typ
  assets/
    README.md
```

Purpose of each path:

- `main.typ`: Entry point for the diagram. It should import the diagram data and the layout builders, then call a small number of high-level functions such as the general page and constellation pages. The target is that this file reads like assembly, not like implementation.
- `data/metadata.typ`: Diagram-level metadata: title, subtitle, diagram type, author, company, version/date, notes, and any text used by the author/comments areas.
- `data/constellations.typ`: Definitions for constellation groups. Each item should have an id, display name, optional description, and visual theme or color token.
- `data/blocks.typ`: Definitions for all blocks. Each block should have an id, constellation id, title, and row sections. For database diagrams, this is where table columns and constraints would be defined.
- `data/links.typ`: Definitions for relations between block rows. Each link should identify source and target ids and choose the representation mode when needed, for example direct arrow or link block.
- `data/legend.typ`: Abbreviation definitions used by the diagram, for example `NN`, `FK`, `UN`, or default markers. Later this can be generated partially from block/link data, but a first version can keep it explicit.
- `preambles/settings.typ`: Diagram visual defaults: fonts, colors, spacing, block sizing, arrow styling, legend sizing, page margins, and common resource paths.
- `preambles/page_style.typ`: Global Typst document wrapper, equivalent to the presentation preset `Document` function. It should define page behavior, text defaults, margins, and any fit-to-content page logic.
- `preambles/elements.typ`: Low-level reusable drawing pieces: block header, block row, row section, legend item, author box, comment box, arrow style, link block, and constellation label.
- `preambles/layouts.typ`: High-level page builders: general diagram page, per-constellation page, page frame, legend placement, comments placement, and block/constellation placement strategy.
- `preambles/common_functions.typ`: Data helpers: look up blocks by id, filter blocks by constellation, collect links for a page, collect used legend terms, validate required fields, and normalize optional values.
- `assets/`: Diagram-local resources only. Project-wide logos and shared page assets should remain in `src/.common_resources`.

Recommended authoring flow for later stages:

1. A user copies `src/.preset` to `src/<diagram-name>`.
2. The user edits only files in `data/` for normal diagram content.
3. `main.typ` imports data and calls the diagram layouts.
4. Files in `preambles/` are changed only when the diagram type, visual system, or output behavior changes.


## /*/*name/*/*
### Context
### Activities
### Agents comments
#### Status
#### Information
#### Recommendations
