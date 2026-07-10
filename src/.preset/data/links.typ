#let links = (
  (
    id: "mc_processes_process_name_location_fk",
    source: (block: "mc_processes", row: "location_id"),
    target: (block: "lo_locations", row: "location_id"),
    mode: "direct",
  ),
  (
    id: "mc_machines_process_fk",
    source: (block: "mc_machines", row: "process_id"),
    target: (block: "mc_processes", row: "process_id"),
    mode: "auto",
  ),
  (
    id: "mc_machines_device_fk",
    source: (block: "mc_machines", row: "device_id"),
    target: (block: "ds_devices", row: "device_id"),
    mode: "direct",
  ),
  (
    id: "ds_devices_gateway_fk",
    source: (block: "ds_devices", row: "gateway_id"),
    target: (block: "gw_gateways", row: "gateway_id"),
    mode: "auto",
  ),
  (
    id: "mc_machines_gateway_fk",
    source: (block: "mc_machines", row: "gateway_id"),
    target: (block: "gw_gateways", row: "gateway_id"),
    mode: "direct",
  ),
  (
    id: "hist_samples_machine_fk",
    source: (block: "hist_samples", row: "machine_id"),
    target: (block: "mc_machines", row: "machine_id"),
    mode: "auto",
  ),
  (
    id: "hist_samples_location_fk",
    source: (block: "hist_samples", row: "location_id"),
    target: (block: "lo_locations", row: "location_id"),
    mode: "auto",
  ),
)
