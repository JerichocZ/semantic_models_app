#let example_recipe = (
  metadata: (
    title: [Alignment contract example],
    subtitle: [Manual levels, fallback orders, auto link modes, and diagnostics],
    diagram_type: [Database],
    author: [Javier Soler],
    company: [Sensomatic SAS],
    version: [0.1.0],
    date: [2026-07-10],
    comments: [This recipe exercises the Stage 3 alignment data model.],
  ),
  constellations: (
    (
      id: "lo",
      title: [Locations],
      level: 1,
      order: 1,
    ),
    (
      id: "ds",
      title: [Datasources],
      level: 1,
    ),
    (
      id: "mc",
      title: [Maintenance],
      level: 2,
      order: 1,
    ),
    (
      id: "qa",
      title: [Quality rules],
      level: 2,
      order: 2,
    ),
    (
      id: "hist",
      title: [History],
      level: 3,
      order: 1,
    ),
  ),
  blocks: (
    (
      id: "lo_locations",
      constellation: "lo",
      title: [lo_locations],
      order: 1,
      columns: (
        (id: "location_id", name: [location_id]),
        (id: "location_name", name: [location_name]),
      ),
    ),
    (
      id: "ds_sensors",
      constellation: "ds",
      title: [ds_sensors],
      columns: (
        (id: "sensor_id", name: [sensor_id]),
        (id: "sensor_name", name: [sensor_name]),
      ),
    ),
    (
      id: "mc_processes",
      constellation: "mc",
      title: [mc_processes],
      order: 1,
      columns: (
        (id: "process_id", name: [process_id]),
        (id: "location_id", name: [location_id]),
      ),
    ),
    (
      id: "mc_machines",
      constellation: "mc",
      title: [mc_machines],
      order: 2,
      columns: (
        (id: "machine_id", name: [machine_id]),
        (id: "process_id", name: [process_id]),
        (id: "sensor_id", name: [sensor_id]),
      ),
    ),
    (
      id: "qa_rules",
      constellation: "qa",
      title: [qa_rules],
      order: 1,
      columns: (
        (id: "rule_id", name: [rule_id]),
        (id: "machine_id", name: [machine_id]),
      ),
    ),
    (
      id: "hist_machine_samples",
      constellation: "hist",
      title: [hist_machine_samples],
      columns: (
        (id: "sample_id", name: [sample_id]),
        (id: "machine_id", name: [machine_id]),
        (id: "location_id", name: [location_id]),
      ),
    ),
  ),
  links: (
    (
      id: "mc_machines_process_fk",
      source: (block: "mc_machines", row: "process_id"),
      target: (block: "mc_processes", row: "process_id"),
      mode: "auto",
    ),
    (
      id: "mc_processes_location_fk",
      source: (block: "mc_processes", row: "location_id"),
      target: (block: "lo_locations", row: "location_id"),
      mode: "auto",
    ),
    (
      id: "mc_machines_rule_fk",
      source: (block: "mc_machines", row: "machine_id"),
      target: (block: "qa_rules", row: "machine_id"),
      mode: "auto",
    ),
    (
      id: "hist_samples_location_fk",
      source: (block: "hist_machine_samples", row: "location_id"),
      target: (block: "lo_locations", row: "location_id"),
      mode: "auto",
    ),
    (
      id: "hist_samples_machine_fk",
      source: (block: "hist_machine_samples", row: "machine_id"),
      target: (block: "mc_machines", row: "machine_id"),
      mode: "link-block",
    ),
    (
      id: "hist_samples_missing_fk",
      source: (block: "hist_machine_samples", row: "ghost_id"),
      target: (block: "missing_table", row: "missing_id"),
      mode: "auto",
    ),
  ),
)
