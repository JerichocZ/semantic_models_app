# Blocks and Constellation Alignment Recipe

This document describes the first alignment rules for rendering model diagrams. These rules are based on diagrams where blocks represent semantic objects, such as database tables, and constellations represent groups of related blocks, such as database schemas.

The goal is to define a simple, predictable, and readable alignment system that can be implemented first. The system should prefer clear structure over automatic perfect layout.

---

# 1. Core Alignment Idea

The diagram uses a horizontal dependency flow.

For the first implementation, the preferred direction is:

```text
parents / referenced constellations  --->  children / referencing constellations
left                                --->  right
```

This means:

* Parent constellations are placed on the left.
* Child constellations are placed on the right.
* A constellation that references another constellation should appear to the right of the referenced constellation.
* Arrows generally point from right to left when showing references, because the child row references a parent row.
* The visual reading order is dependency-first: foundational objects appear first, dependent objects appear later.

Example:

```text
[Parent constellation]      [Child constellation]      [Grandchild constellation]
        lo                         mc                           data
```

If `mc` references `lo`, then `lo` is placed to the left of `mc`.

If `data` references `mc`, then `mc` is placed to the left of `data`.

---

# 2. Constellation Levels

Each constellation belongs to a horizontal level.

A level represents how far a constellation is from the foundational parent constellations.

## 2.1 Level 1

Level 1 constellations are root or parent constellations.

They do not reference any other constellation using normal direct arrows.

Example:

```text
Level 1
lo
ds
gw
```

A level 1 constellation may still have exceptional references, but those references should use link-blocks instead of long direct arrows.

## 2.2 Level 2

Level 2 constellations reference level 1 constellations.

These references may use direct arrows.

Example:

```text
Level 1        Level 2
lo       <---  mc
ds       <---  mc
gw       <---  mc
```

## 2.3 Level 3 and Higher

Level 3 constellations should have at least one direct reference to a level 2 constellation.

References from level 3 to level 1 are considered skip-level references. They should use link-blocks by default, not direct arrows.

Example:

```text
Level 1        Level 2        Level 3
lo       <---  mc       <---  hist
```

If `hist` also references `lo`, that reference should use a link-block because it skips level 2.

---

# 3. Horizontal Placement Rules

Constellations are placed in vertical columns according to their level.

```text
Column 1       Column 2       Column 3       Column 4
Level 1        Level 2        Level 3        Level 4
parents        children       deeper         deepest
```

Rules:

1. Lower-level constellations are placed further left.
2. Higher-level constellations are placed further right.
3. A direct reference should usually connect constellations in adjacent columns.
4. References that skip one or more columns should use link-blocks.
5. Same-level constellations should not use direct arrows between each other in the first implementation.
6. Same-level references, if required, should use link-blocks.

---

# 4. Vertical Placement Rules

Constellations that belong to the same level are stacked vertically.

Example:

```text
Column 1       Column 2
lo             mc
ds
gw
```

The vertical order may be defined manually by the user using an `order` field.

If no manual order is provided, the renderer may use a simple automatic order.

Suggested automatic order:

1. Constellations with more incoming references appear closer to the vertical center.
2. Constellations referenced by many child constellations should be visually prominent.
3. Constellations with fewer references may appear above or below.
4. As a fallback, use the order in which the constellations are defined in the source file.

For the first implementation, manual order is preferred.

## 4.1 Block Alignment Inside a Constellation

Each constellation contains a second, independent horizontal alignment
domain. Blocks use their own `level` and `order` values; these values do not
change the constellation's level or order.

```text
Block level 1       Block level 2       Block level 3
parents             children            deeper children
```

Rules:

1. Lower block levels render to the left of higher block levels.
2. Blocks sharing a level stack vertically using block `order`.
3. Missing block level defaults to level 1.
4. Missing block order and duplicate positions use source order as a
   deterministic fallback or tie-breaker.
5. Direct internal references between adjacent block levels use routing pipes
   inside the constellation.
6. Internal same-level, skip-level, and same-block references use link-blocks
   by default.

Constellation and block levels must remain distinct in the normalized model
and in link endpoints. Cross-constellation arrows use constellation levels;
internal arrows use block levels.

---

# 5. Constellation Dependency Rules

A constellation dependency exists when at least one block row in one constellation references a block row in another constellation.

For example, if table `mc_machines` belongs to constellation `mc` and references table `lo_locations` in constellation `lo`, then:

```text
mc depends on lo
mc is child of lo
lo is parent of mc
```

The layout should place:

```text
lo     before     mc
left              right
```

A constellation may reference multiple parent constellations.

Example:

```text
mc depends on lo
mc depends on ds
mc depends on gw
```

Then `mc` should be placed to the right of `lo`, `ds`, and `gw`.

---

# 6. Direct Arrow Rules

Direct arrows are used for important, local, readable references.

A direct arrow should be used when:

1. The source and target constellations are in adjacent levels.
2. The reference is important to understand the main structure.
3. The arrow does not create excessive visual crossing.
4. The user explicitly requests a direct arrow.

For database diagrams, a direct arrow usually connects a foreign-key column to the referenced primary-key column.

Example:

```text
mc_machines.process_id  --->  mc_processes.process_id
```

However, because the visual layout places parents on the left and children on the right, the arrow may visually point from the child block toward the parent block.

---

# 7. Link-Block Rules

A link-block is a small visual element used to represent a reference without drawing a long direct arrow across the diagram.

A link-block should be used when:

1. A reference skips one or more constellation levels.
2. A reference connects same-level constellations.
3. A reference would create too many crossing arrows.
4. A reference points to a far-away constellation.
5. The user explicitly requests `link-block` mode.
6. The diagram would become visually noisy with a direct arrow.

A link-block should appear beside the source row and should identify the target row.

A matching link-block may also appear beside the target row to show that it is referenced from somewhere else.

Example:

```text
Source side:
machine_id | int | FK   [→ mc_machines.machine_id]

Target side:
machine_id | int | PK   [← referenced by mc_registries.machine_id]
```

For the first implementation, link-blocks may be simple labeled boxes. They do not need advanced routing.

---

# 8. Link Mode Rules

Each link may define a mode.

Supported modes for the first implementation:

```text
direct
link-block
auto
```

## 8.1 direct

Always draw a direct arrow between the source row and the target row.

## 8.2 link-block

Always represent the reference using link-blocks.

## 8.3 auto

The renderer decides the mode using simple rules.

Suggested `auto` behavior:

```text
different constellations, adjacent constellation levels -> direct
different constellations, same or skipped levels         -> link-block
same constellation, adjacent block levels                -> direct
same constellation, same or skipped block levels         -> link-block
same block                                                 -> link-block
```

This replaces the earlier coarse `same constellation -> direct` rule. The
renderer should always classify the routing domain before resolving `auto`.

The user should be able to override the automatic choice by setting the link mode explicitly.

---

# 9. Same-Level References

The default model assumes that same-level constellations do not reference each other.

This means:

* Children do not normally reference other children.
* Parents do not normally reference other parents.
* Constellations in the same column should avoid direct arrows between them.

If a same-level reference exists, it should use a link-block by default.

This keeps the main dependency flow clean and prevents diagrams from becoming spaghetti diagrams.

---

# 10. Skip-Level References

A skip-level reference happens when a constellation references another constellation that is more than one level to the left.

Example:

```text
Level 1        Level 2        Level 3
lo             mc             hist
```

If `hist` references `lo`, this is a skip-level reference.

Default behavior:

```text
Use link-block.
```

Reason:

A direct arrow from level 3 to level 1 can cross many blocks and make the diagram harder to read.

---

# 11. Block Alignment Inside a Constellation

Each constellation contains one or more blocks.

For database diagrams, each block usually represents a table.

Inside a constellation, blocks follow the same parent-left / child-right logic
as constellations. Block `level` selects a horizontal block column and block
`order` selects the vertical position within that column.

Referenced blocks should normally use a lower block level than the blocks that
reference them. Manual block level and order have priority; missing values use
the documented deterministic fallbacks.

Example:

```yaml
blocks:
  - id: mc_processes
    constellation: mc
    level: 1
    order: 1

  - id: mc_machines
    constellation: mc
    level: 2
    order: 1

  - id: mc_registries
    constellation: mc
    level: 2
    order: 2
```

---

# 12. General Page Layout

The general page shows all constellations.

Rules:

1. The page is divided into horizontal columns.
2. Each column represents one constellation level.
3. Constellations in the same level are stacked vertically.
4. Blocks inside each constellation use nested block-level columns and stack by block order within each column.
5. Direct arrows are preferred only for nearby references.
6. Link-blocks are preferred for far, same-level, or skip-level references.
7. The page size should fit the content plus margins.
8. A legend should appear in a fixed area, preferably near a corner.
9. Author information should appear in a fixed area.
10. A comments area should be available beside or below the diagram.

---

# 13. Constellation Page Layout

Each constellation should also have its own page.

A constellation page focuses on one constellation and its internal blocks.

Rules:

1. The selected constellation is rendered as the main content.
2. Internal adjacent-block-level links may use direct arrows through inner pipes.
3. External references should usually use link-blocks.
4. The legend should only include abbreviations used on that page.
5. Author information should appear in a fixed area.
6. A comments area should be available.
7. The page size should fit the selected constellation content plus margins.

External parent or child constellations should not be fully rendered in the first implementation unless explicitly requested.

Instead, external references should be represented with link-blocks.

---

# 14. Manual Layout Overrides

The renderer should allow manual layout hints.

Recommended fields:

```yaml
constellations:
  - id: lo
    level: 1
    order: 1

  - id: ds
    level: 1
    order: 2

  - id: mc
    level: 2
    order: 1
```

For blocks:

```yaml
blocks:
  - id: mc_processes
    constellation: mc
    level: 1
    order: 1

  - id: mc_machines
    constellation: mc
    level: 2
    order: 1
```

Manual layout should take priority over automatic layout.

Automatic layout should only fill missing values.

---

# 15. Automatic Level Detection

For the first implementation, automatic level detection is optional.

If implemented, the renderer may compute levels from constellation dependencies.

Basic rule:

```text
If constellation A references constellation B,
then A must be placed to the right of B.
```

This means:

```text
level(A) > level(B)
```

Root constellations with no outgoing references to other constellations may start at level 1.

However, because automatic dependency layout can become complex, the first implementation should prefer explicit user-defined levels.

---

# 16. First Implementation Priority

The first implementation should prioritize predictable diagrams over perfect diagrams.

Required first features:

1. Render constellations in manually defined levels.
2. Stack same-level constellations vertically.
3. Render blocks inside each constellation.
4. Render database table rows.
5. Render direct arrows for selected links.
6. Render link-blocks for selected links.
7. Support `direct`, `link-block`, and `auto` link modes.
8. Generate a general page.
9. Generate one page per constellation.
10. Render legends, author area, and comments area.

Not required in the first implementation:

1. Perfect automatic graph layout.
2. Advanced arrow routing.
3. Collision avoidance.
4. Drag-and-drop editing.
5. Curved or orthogonal smart connectors.
6. Interactive diagrams.
7. Non-database diagram types.

---

# 17. Summary of Default Rules

Default constellation direction:

```text
parents left, children right
```

Default level behavior:

```text
level 1 -> references nothing using direct arrows
level 2 -> references level 1 using direct arrows
level 3 -> references level 2 using direct arrows
skip-level references -> link-blocks
same-level references -> link-blocks
```

Default block behavior:

```text
lower block levels -> left
higher block levels -> right
same block level -> vertical stack
manual order is preferred
source file order is fallback
```

Default link behavior:

```text
cross-constellation adjacent levels -> direct through outer pipe
internal adjacent block levels -> direct through inner pipe
cross-constellation or internal skip-level -> link-block
cross-constellation or internal same-level -> link-block
same-block -> link-block
unsupported explicit direct -> preserved in contract with diagnostic render fallback
```

The purpose of these rules is to create readable diagrams that scale to many blocks and many references without becoming visually chaotic.
