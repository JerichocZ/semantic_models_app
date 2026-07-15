#let links = (
  // Internal adjacent block levels: auto resolves to an inner direct pipe.
  (
    id: "lo_locations_type_fk",
    source: (block: "locations", row: "type_id"),
    target: (block: "types_locations", row: "type_id"),
    mode: "auto",
  ),
  (
    id: "gw_brand_to_references_fk",
    source: (
      block: "presets_references",
      row: "brand_id",
    ),
    target: (
      block: "presets_brands",
      row: "brand_id",
    ),
    mode: "auto",
  ),
  (
    id: "gw_reference_to_gateway_fk",
    source: (
      block: "gateways",
      row: "reference_id",
    ),
    target: (
      block: "presets_references",
      row: "reference_id",
    ),
    mode: "auto",
  ),
  (
    id: "gw_type_to_event",
    source: (
      block: "events",
      row: "type_id",
    ),
    target: (
      block: "types_events",
      row: "event_id",
    ),
    mode: "auto",
  ),
  (
    id: "gw_types_to_entries_fk",
    source: (
      block: "entries",
      row: "type_id",
    ),
    target: (
      block: "types_entries",
      row: "type_id",
    ),
    mode: "auto",
  ),
  (
    id: "gw_chunk_to_entry_fk",
    source: (
      block: "entries",
      row: "chunk_id",
    ),
    target: (
      block: "registries",
      row: "chunk_id",
    ),
    mode: "auto",
  ),
  (
    id: "ds_brand_to_reference",
    source: (
      block: "presets_sensors",
      row: "brand_id",
    ),
    target: (
      block: "presets_brands_sensors",
      row: "brand_id",
    ),
    mode: "auto",
  ),
  (
    id: "ds_reference_to_sensor",
    source: (
      block: "sensors",
      row: "reference_id",
    ),
    target: (
      block: "presets_sensors",
      row: "reference_id",
    ),
    mode: "auto",
  ),
  (
    id: "ds_sensor_to_dimension",
    source: (
      block: "dimensions",
      row: "sensor_id",
    ),
    target: (
      block: "sensors",
      row: "sensor_id",
    ),
    mode: "auto",
  ),
  (
    id: "ds_unit_to_dimension",
    source: (
      block: "dimensions",
      row: "unit_id",
    ),
    target: (
      block: "presets_units",
      row: "unit_id",
    ),
    mode: "auto",
  ),
  (
    id: "ds_type_to_dimension_fk",
    source: (
      block: "dimensions",
      row: "type_id",
    ),
    target: (
      block: "types_dimensions",
      row: "type_id",
    ),
    mode: "auto",
  ),
  (
    id: "mc_location_to_process",
    source: (
      block: "processes",
      row: "location_id",
    ),
    target: (
      block: "locations",
      row: "location_id",
    ),
    mode: "auto",
  ),
  (
    id: "mc_sensor_to_attached_fk",
    source: (
      block: "sensors_attached",
      row: "sensor_id",
    ),
    target: (
      block: "sensors",
      row: "sensor_id",
    ),
    mode: "link-block",
  ),
  (
    id: "mc_machine_to_attached_fk",
    source: (
      block: "sensors_attached",
      row: "machine_id",
    ),
    target: (
      block: "machines",
      row: "machine_id",
    ),
    mode: "link-block",
  ),
  (
    id: "mc_type_to_threshold_fk",
    source: (
      block: "thresholds",
      row: "type_id",
    ),
    target: (
      block: "types_thresholds",
      row: "type_id",
    ),
    mode: "auto",
  ),
  (
    id: "mc_machine_to_threshold_fk",
    source: (
      block: "thresholds",
      row: "machine_id",
    ),
    target: (
      block: "machines",
      row: "machine_id",
    ),
    mode: "link-block",
  ),
  (
    id: "mc_dimension_to_threshold",
    source: (
      block: "thresholds",
      row: "dimension_id",
    ),
    target: (
      block: "dimensions",
      row: "dimension_id",
    ),
    mode: "link-block",
  ),
  (
    id: "mc_machine_to_registry_fk",
    source: (
      block: "registries",
      row: "machine_id",
    ),
    target: (
      block: "machines",
      row: "machine_id",
    ),
    mode: "link-block",
  ),
)
