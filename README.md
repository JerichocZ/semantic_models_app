# Concept
This workspace is a Typst-based app to create models diagrams with some features and rules.

## Diagrams
The diagrams this outputs targets are models usefull to represent database models or other semantic relations with references and dependencies. All diagrams have blocks linked with arrows.

### Blocks
Each block is a table with a title and undefined rows. Each block row has a singular format and rows sections depending on what user wants to represent. Also, a block must belong to a constellation which is a group of blocks.

__DEV note: we may use different colors for block in different constellations. So, each constellation is represented with a different color.__

### Links and references
Each row may reference one or several rows from other tables. A row may link another using a line and an arrow or just a small arrow pointing an small block with a label, named _link blocks_. A link block also appears beside the target row pointing to it.

__DEV Note: we may make tables referencing tables in the same constellation to point using arrows and tables referencing foreign tables uses the link blocks. It has a weakness, if a constellation is large enought, the links may become spagetti. So, the user should decide if to use a link blocks or not. Also, an automatic system to define it would work too.__

## Output
The Typst app generates a PDF with some pages. Each diagram type may have differents outputs behaviours but, here we define a basic and general shape.

So, we have the following pages:

1. General: It is ussually a large page with all blocks in their respective constellation. Also, there is a legend with abstractions; for example, NN | Not null. An author part in a corner and a comments spaces beside.
2. Constelations pages: we will have several pages, each one for each constellation. Again we will have a legend with the abstractions used in this constellation, an author and comments section.

Always, the page size fits its content.

## Diagrams types
A diagram type defines the blocks content and some other behaviours.

### Database
The diagram will represent database models. So, Each block represents a table and each constellation represents an schema.

#### Blocks format
The table rows are:

1. Table name
2. Columns definitions: here we'll have several rows. Eeach one represents a table column and will have three different parts: column name, data type and caracteristics, for example:
```
process_id      |   int     | NN FK
machine_name    |   var 255 | NN
last_report     |   tmtz    | Dnow  
```

the column `process_id` is of `int` type and is `Not nullable` and `Foreign key`. Likewise, the `last report` column is of `TIMESTAMPTZ` type and its default value is `now`. Since it has some abstrations, each database diagram has a legend with the info of what each `NN`, `FK`, ... means.

__DEV note: the columsn definitins section may be a single row that has a table with undefined rows and three columns.__

3. Constraints definition: here will have another section with several rows. Each one represents a single constraint. Also, it will have three different parts: constraint name, type and appendix that may say which columns affect or other info. For example:

```
c_machine_name_uniqueness | UN | (machine_id, process_id)
```

__DEV Note: it may also be a single row with a table.__

# Directories
The `src` directory contains all diagrams and some utils and general resources for each diagram to use.

- `.common_resourceṣ`: Contains some common resouces that all diagrams may call: logos and other stuff.
- `.preset`: An empty diagram. It will be copied-pasted to create another empty diagram.
- `.utils` : some src functions that may be called from each diagram.

# Instructions
To create a new diagram, add a new folder to the `src` directory with diagram files. It is ussually done using:

```sh
cp -r src/.preset src/<new diagram directory name>
```

## Diagram building
There are two ways of defining diagrams: defining its content using YAML format, fast and easy, and full typst coding, more customizable.

__DEV note: the following info must be consider in the development stage. It may be changed or supplemented later__
### YAML
User example:
```YAML
diagram:
  title: Vibration database model
  type: database
  author: Javier Soler

constellations:
  - id: lo
    name: Locations
    color: orange

  - id: mc
    name: Maintenance Core
    color: blue

blocks:
  - id: mc_machines
    constellation: mc
    title: mc_machines
    layout:
      column: 1
      order: 2
    columns:
      - id: machine_id
        name: machine_id
        type: int
        tags: [PK, NN]
      - id: process_id
        name: process_id
        type: int
        tags: [FK, NN]
      - id: name
        name: name
        type: var 255
        tags: [NN]
    constraints:
      - name: c_machine_name_unique
        type: UN
        appendix: "(process_id, name)"

links:
  - from: mc_machines.process_id
    to: mc_processes.process_id
    mode: auto
```

# Typst

