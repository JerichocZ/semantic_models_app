#let blocks = (
  (
    id: "types_locations",
    constellation: "lo",
    title: [types_locations],
    kind: "database_table",
    order: 1,
    level: 1,
    columns: (
      (
        id: "type_id",
        name: "type_id",
        data_type: (source: "integer"),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: "255",
        ),
        attrs: ("NN",),
      ),
    ),
  ),
  (
    id: "locations",
    constellation: "lo",
    title: [locations],
    kind: "database_table",
    order: 1,
    level: 2,
    columns: (
      (
        id: "location_id",
        name: [location_id],
        data_type: (source: "integer"),
        attrs: ("PK", "NN"),
      ),
      (
        id: "name",
        name: [name],
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN", "UN"),
      ),
      (
        id: "country",
        name: [country],
        data_type: (
          source: "varchar",
          size: 255,
        ),
      ),
      (
        id: "region",
        name: "region",
        data_type: (
          source: "varchar",
          size: 255,
        ),
      ),
      (
        id: "city",
        name: "city",
        data_type: (
          source: "varchar",
          size: 255,
        ),
      ),
      (
        id: "latitude",
        name: "latitude",
        data_type: (
          source: "float",
        ),
      ),
      (
        id: "longitude",
        name: "longitude",
        data_type: (
          source: "float",
        ),
      ),
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "int",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "active",
        name: "active",
        data_type: (
          source: "bool",
        ),
        attrs: ("NN", "Dtrue"),
      ),
    ),
    constraints: (
      (name: [pk_lo_locations], constraint_type: [PK], detail: [(location_id)]),
      (name: [uq_lo_location_name], constraint_type: [UN], detail: [(location_name)]),
    ),
  ),
  (
    id: "presets_brands",
    constellation: "gw",
    title: [presets_brands],
    kind: "database_table",
    order: 1,
    level: 1,
    columns: (
      (
        id: "brand_id",
        name: "brand_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
  ),
  (
    id: "presets_references",
    constellation: "gw",
    title: [presets_references],
    kind: "database_table",
    order: 1,
    level: 2,
    columns: (
      (
        id: "reference_id",
        name: "reference_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "brand_id",
        name: "brand_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "gateways",
    constellation: "gw",
    title: [gateways],
    kind: "database_table",
    order: 1,
    level: 3,
    columns: (
      (
        id: "gateway_id",
        name: "gateway_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "reference_id",
        name: "reference_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "software_version",
        name: "software_version",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: (),
      ),
      (
        id: "active",
        name: "active",
        data_type: (
          source: "bool",
        ),
        attrs: ("NN", "Dtrue"),
      ),
    ),
    constraints: (),
  ),
  (
    id: "types_events",
    constellation: "gw",
    title: [types_events],
    kind: "database_table",
    order: 2,
    level: 3,
    columns: (
      (
        id: "event_id",
        name: "event_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "events",
    constellation: "gw",
    title: [events],
    kind: "database_table",
    order: 1,
    level: 4,
    columns: (
      (
        id: "event_id",
        name: "event_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "gateway_id",
        name: "gateway_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "date",
        name: "date",
        data_type: (
          source: "timestamptz",
        ),
        attrs: ("NN", "Dnow"),
      ),
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "description",
        name: "description",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: (),
      ),
    ),
    constraints: (),
  ),
  (
    id: "registries",
    constellation: "gw",
    title: [registries],
    kind: "database_table",
    order: 3,
    level: 3,
    columns: (
      (
        id: "chunk_id",
        name: "chunk_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "gateway_id",
        name: "gateway_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK", "ODC"),
      ),
      (
        id: "date",
        name: "date",
        data_type: (
          source: "timestamptz",
        ),
        attrs: ("NN", "Dnow"),
      ),
    ),
    constraints: (),
  ),
  (
    id: "types_entries",
    constellation: "gw",
    title: [types_entries],
    kind: "database_table",
    order: 4,
    level: 3,
    columns: (
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "entries",
    constellation: "gw",
    title: [entries],
    kind: "database_table",
    order: 2,
    level: 4,
    columns: (
      (
        id: "entry_id",
        name: "entry_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "chunk_id",
        name: "chunk_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK", "ODC"),
      ),
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "value",
        name: "value",
        data_type: (
          source: "float",
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "presets_brands_sensors",
    constellation: "ds",
    title: [presets_brands_sensors],
    kind: "database_table",
    order: 1,
    level: 1,
    columns: (
      (
        id: "brand_id",
        name: "brand_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "presets_sensors",
    constellation: "ds",
    title: [presets_sensors],
    kind: "database_table",
    order: 1,
    level: 2,
    columns: (
      (
        id: "reference_id",
        name: "reference_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "brand_id",
        name: "brand_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "sensors",
    constellation: "ds",
    title: [sensors],
    kind: "database_table",
    level: 3,
    order: 1,
    columns: (
      (
        id: "sensor_id",
        name: "sensor_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "reference_id",
        name: "reference_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "last_activity",
        name: "last_activity",
        data_type: (
          source: "timestamptz",
        ),
        attrs: ("Dnow",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "presets_units",
    constellation: "ds",
    title: [presets_units],
    kind: "database_table",
    level: 3,
    order: 2,
    columns: (
      (
        id: "unit_id",
        name: "unit_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "types_dimensions",
    constellation: "ds",
    title: [types_dimensions],
    kind: "database_table",
    level: 3,
    order: 3,
    columns: (
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "dimensions",
    constellation: "ds",
    title: [dimensions],
    kind: "database_table",
    level: 4,
    order: 1,
    columns: (
      (
        id: "dimension_id",
        name: "dimension_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "sensor_id",
        name: "sensor_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "unit_id",
        name: "unit_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "description",
        name: "description",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: (),
      ),
    ),
    constraints: (),
  ),
  (
    id: "processes",
    constellation: "mc",
    title: [processes],
    kind: "database_table",
    level: 1,
    order: 1,
    columns: (
      (
        id: "process_id",
        name: "process_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
      (
        id: "location_id",
        name: "location_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "active",
        name: "active",
        data_type: (
          source: "bool",
        ),
        attrs: ("NN", "Dtrue"),
      ),
    ),
    constraints: (),
  ),
  (
    id: "machines",
    constellation: "mc",
    title: [machines],
    kind: "database_table",
    level: 1,
    order: 2,
    columns: (
      (
        id: "machine_id",
        name: "machine_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
      (
        id: "process_id",
        name: "process_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "gateway_id",
        name: "gateway_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("FK",),
      ),
      (
        id: "active",
        name: "active",
        data_type: (
          source: "bool",
        ),
        attrs: ("NN", "Dtrue"),
      ),
    ),
    constraints: (),
  ),
  (
    id: "sensors_attached",
    constellation: "mc",
    title: [sensors_attached],
    kind: "database_table",
    level: 1,
    order: 3,
    columns: (
      (
        id: "attach_id",
        name: "attach_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "sensor_id",
        name: "sensor_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "machine_id",
        name: "machine_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "gateway_port",
        name: "gateway_port",
        data_type: (
          source: "varchar",
          size: 64,
        ),
        attrs: (),
      ),
      (
        id: "position_name",
        name: "position_name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: (),
      ),
      (
        id: "notes",
        name: "notes",
        data_type: (
          source: "text",
        ),
        attrs: (),
      ),
      (
        id: "installed_at",
        name: "installed_at",
        data_type: (
          source: "timestamptz",
        ),
        attrs: ("NN", "Dnow"),
      ),
      (
        id: "removed_at",
        name: "removed_at",
        data_type: (
          source: "timestamptz",
        ),
        attrs: ("Dnow",),
      ),
      (
        id: "active",
        name: "active",
        data_type: (
          source: "bool",
        ),
        attrs: ("NN", "Dtrue"),
      ),
    ),
    constraints: (),
  ),
  (
    id: "types_thresholds",
    constellation: "mc",
    title: [types_thresholds],
    kind: "database_table",
    level: 2,
    order: 1,
    columns: (
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "name",
        name: "name",
        data_type: (
          source: "varchar",
          size: 255,
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "thresholds",
    constellation: "mc",
    title: [thresholds],
    kind: "database_table",
    level: 3,
    order: 1,
    columns: (
      (
        id: "threshold_id",
        name: "threshold_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "machine_id",
        name: "machine_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK", "ODC"),
      ),
      (
        id: "dimension_id",
        name: "dimension_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "type_id",
        name: "type_id",
        data_type: (
          source: "integer",
          size: 255,
        ),
        attrs: ("NN", "FK"),
      ),
      (
        id: "value",
        name: "value",
        data_type: (
          source: "float",
        ),
        attrs: ("NN",),
      ),
    ),
    constraints: (),
  ),
  (
    id: "registries",
    constellation: "mc",
    title: [registries],
    kind: "database_table",
    level: 2,
    order: 2,
    columns: (
      (
        id: "chunk_id",
        name: "chunk_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "PK"),
      ),
      (
        id: "machine_id",
        name: "machine_id",
        data_type: (
          source: "integer",
        ),
        attrs: ("NN", "FK", "ODC"),
      ),
      (
        id: "date",
        name: "date",
        data_type: (
          source: "timestamptz",
        ),
        attrs: ("NN", "Dnow"),
      ),
    ),
    constraints: (),
  ),
)
