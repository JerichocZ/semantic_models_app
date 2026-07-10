#let blocks = (
  (
    id: "lo_locations",
    constellation: "lo",
    title: [lo_locations],
    kind: "database_table",
    order: 1,
    columns: (
      (id: "location_id", name: [location_id], data_type: (source: "integer"), attrs: ("PK", "NN")),
      (id: "location_name", name: [location_name], data_type: (source: "varchar", size: 120), attrs: ("NN", "UN")),
      (id: "site_code", name: [site_code], data_type: (source: "varchar", size: 24), attrs: ("NN",)),
    ),
    constraints: (
      (name: [pk_lo_locations], constraint_type: [PK], detail: [(location_id)]),
      (name: [uq_lo_location_name], constraint_type: [UN], detail: [(location_name)]),
    ),
  ),
  (
    id: "ds_devices",
    constellation: "ds",
    title: [ds_devices],
    kind: "database_table",
    order: 1,
    columns: (
      (id: "device_id", name: [device_id], data_type: (source: "integer"), attrs: ("PK", "NN")),
      (id: "gateway_id", name: [gateway_id], data_type: (source: "integer"), attrs: ("FK",)),
      (id: "device_name", name: [device_name], data_type: (source: "varchar", size: 120), attrs: ("NN",)),
      (id: "device_kind", name: [device_kind], data_type: (source: "varchar", size: 40), attrs: ("NN",)),
    ),
    constraints: (
      (name: [pk_ds_devices], constraint_type: [PK], detail: [(device_id)]),
      (name: [fk_ds_devices_gateway], constraint_type: [FK], detail: [gateway_id -> gw_gateways.gateway_id]),
    ),
  ),
  (
    id: "gw_gateways",
    constellation: "gw",
    title: [gw_gateways],
    kind: "database_table",
    order: 1,
    columns: (
      (id: "gateway_id", name: [gateway_id], data_type: (source: "integer"), attrs: ("PK", "NN")),
      (id: "gateway_name", name: [gateway_name], data_type: (source: "varchar", size: 120), attrs: ("NN",)),
      (id: "last_seen", name: [last_seen], data_type: (source: "timestamptz"), attrs: ("Dnow",)),
    ),
    constraints: (
      (name: [pk_gw_gateways], constraint_type: [PK], detail: [(gateway_id)]),
    ),
  ),
  (
    id: "mc_processes",
    constellation: "mc",
    title: [mc_processes],
    kind: "database_table",
    order: 1,
    columns: (
      (id: "process_id", name: [process_id], data_type: (source: "integer"), attrs: ("PK", "NN")),
      (id: "location_id", name: [location_id], data_type: (source: "integer"), attrs: ("NN", "FK")),
      (id: "process_name", name: [process_name], data_type: (source: "varchar", size: 120), attrs: ("NN",)),
    ),
    constraints: (
      (name: [pk_mc_processes], constraint_type: [PK], detail: [(process_id)]),
      (name: [fk_mc_processes_location], constraint_type: [FK], detail: [location_id -> lo_locations.location_id]),
    ),
  ),
  (
    id: "mc_machines",
    constellation: "mc",
    title: [mc_machines],
    kind: "database_table",
    order: 2,
    columns: (
      (id: "machine_id", name: [machine_id], data_type: (source: "integer"), attrs: ("PK", "NN")),
      (id: "process_id", name: [process_id], data_type: (source: "integer"), attrs: ("NN", "FK")),
      (id: "device_id", name: [device_id], data_type: (source: "integer"), attrs: ("FK",)),
      (id: "gateway_id", name: [gateway_id], data_type: (source: "integer"), attrs: ("FK",)),
      (id: "machine_name", name: [machine_name], data_type: (source: "varchar", size: 160), attrs: ("NN", "UN")),
    ),
    constraints: (
      (name: [pk_mc_machines], constraint_type: [PK], detail: [(machine_id)]),
      (name: [fk_mc_machines_process], constraint_type: [FK], detail: [process_id -> mc_processes.process_id]),
      (name: [fk_mc_machines_device], constraint_type: [FK], detail: [device_id -> ds_devices.device_id]),
      (name: [fk_mc_machines_gateway], constraint_type: [FK], detail: [gateway_id -> gw_gateways.gateway_id]),
    ),
  ),
  (
    id: "hist_samples",
    constellation: "hist",
    title: [hist_samples],
    kind: "database_table",
    order: 1,
    columns: (
      (id: "sample_id", name: [sample_id], data_type: (source: "integer"), attrs: ("PK", "NN")),
      (id: "machine_id", name: [machine_id], data_type: (source: "integer"), attrs: ("FK",)),
      (id: "location_id", name: [location_id], data_type: (source: "integer"), attrs: ("FK",)),
      (id: "reported_at", name: [reported_at], data_type: (source: "timestamptz"), attrs: ("NN",)),
    ),
    constraints: (
      (name: [pk_hist_samples], constraint_type: [PK], detail: [(sample_id)]),
      (name: [fk_hist_samples_machine], constraint_type: [FK], detail: [machine_id -> mc_machines.machine_id]),
      (name: [fk_hist_samples_location], constraint_type: [FK], detail: [location_id -> lo_locations.location_id]),
    ),
  ),
)
