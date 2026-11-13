-- Synthetic HVAC samples for @os20/hvac-ontology (illustrative only).
-- Compatible with os20-reg product-data schema (001_product_data.sql).
-- Does NOT claim certified manufacturer specifications.

INSERT INTO semantic_definition (semantic_id, canonical_name, description, value_type, quantity_kind, compatible_units) VALUES
  ('hvac.cooling_capacity', 'Cooling capacity', 'Refrigeration cooling capacity', 'number', 'power', '["Kilowatt","Watt"]'),
  ('hvac.heat_rejection_capacity', 'Heat rejection capacity', 'Condenser heat rejection rate', 'number', 'power', '["Kilowatt","Watt"]'),
  ('hvac.rated_capacity', 'Rated capacity', 'Rated thermal/flow capacity of a device', 'number', 'power', '["Kilowatt","Watt"]')
ON CONFLICT (semantic_id) DO UPDATE SET
  canonical_name = EXCLUDED.canonical_name,
  description = EXCLUDED.description,
  value_type = EXCLUDED.value_type,
  quantity_kind = EXCLUDED.quantity_kind,
  compatible_units = EXCLUDED.compatible_units,
  updated_at = now();

INSERT INTO semantic_alias (semantic_id, alias, normalized_alias) VALUES
  ('hvac.cooling_capacity', 'Cooling Capacity', 'cooling capacity'),
  ('hvac.cooling_capacity', 'Q_cooling', 'q_cooling'),
  ('hvac.heat_rejection_capacity', 'Heat Rejection', 'heat rejection'),
  ('hvac.rated_capacity', 'Rated Capacity', 'rated capacity')
ON CONFLICT DO NOTHING;

-- One portal package holding five synthetic component categories.
INSERT INTO product_package (package_key, display_name, description) VALUES
  ('@example/hvac-ontology-samples', 'HVAC Ontology Samples',
   'Synthetic sample components for @os20/hvac-ontology demos. Illustrative values only.')
ON CONFLICT (package_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = now();

INSERT INTO product_category (category_id, package_key, name, semantic_id, sort_order) VALUES
  ('cat_hvac_compressor', '@example/hvac-ontology-samples', 'Compressor', NULL, 10),
  ('cat_hvac_condenser',  '@example/hvac-ontology-samples', 'Condenser',  NULL, 20),
  ('cat_hvac_evaporator', '@example/hvac-ontology-samples', 'Evaporator', NULL, 30),
  ('cat_hvac_txv',        '@example/hvac-ontology-samples', 'ExpansionValve', NULL, 40),
  ('cat_hvac_fan',        '@example/hvac-ontology-samples', 'Fan', NULL, 50)
ON CONFLICT (category_id) DO UPDATE SET
  name = EXCLUDED.name,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();

INSERT INTO product_property (
  property_id, category_id, package_key, name, semantic_id, value_type,
  value_number, unit, description, source_ref, part_ref, sort_order
) VALUES
  -- Sample Scroll Compressor  (sysml: @os20/hvac-ontology#Compressor)
  ('prop_sample_comp_q', 'cat_hvac_compressor', '@example/hvac-ontology-samples',
   'Cooling capacity', 'hvac.cooling_capacity', 'number', 3500, 'Watt',
   'SYNTHETIC. Maps to Compressor.coolingCapacity', 'catalog/samples.json#sample.scroll_compressor.001',
   'Sample Scroll Compressor', 10),
  ('prop_sample_comp_suc_d', 'cat_hvac_compressor', '@example/hvac-ontology-samples',
   'Suction diameter', 'geometry.inner_diameter', 'number', 12.7, 'Millimeter',
   'SYNTHETIC. Maps to Compressor.suctionDiameter', 'catalog/samples.json#sample.scroll_compressor.001',
   'Sample Scroll Compressor', 20),
  ('prop_sample_comp_dis_d', 'cat_hvac_compressor', '@example/hvac-ontology-samples',
   'Discharge diameter', 'geometry.inner_diameter', 'number', 9.5, 'Millimeter',
   'SYNTHETIC. Maps to Compressor.dischargeDiameter', 'catalog/samples.json#sample.scroll_compressor.001',
   'Sample Scroll Compressor', 30),
  ('prop_sample_comp_pwr', 'cat_hvac_compressor', '@example/hvac-ontology-samples',
   'Rated power', 'other.power', 'number', 1100, 'Watt',
   'SYNTHETIC. Maps to Compressor.ratedPower', 'catalog/samples.json#sample.scroll_compressor.001',
   'Sample Scroll Compressor', 40),

  -- Sample Air-Cooled Condenser
  ('prop_sample_cond_q', 'cat_hvac_condenser', '@example/hvac-ontology-samples',
   'Heat rejection capacity', 'hvac.heat_rejection_capacity', 'number', 4200, 'Watt',
   'SYNTHETIC. Maps to Condenser.heatRejectionCapacity', 'catalog/samples.json#sample.air_cooled_condenser.001',
   'Sample Air-Cooled Condenser', 10),
  ('prop_sample_cond_in_d', 'cat_hvac_condenser', '@example/hvac-ontology-samples',
   'Inlet diameter', 'geometry.inner_diameter', 'number', 9.5, 'Millimeter',
   'SYNTHETIC. Maps to Condenser.inletDiameter', 'catalog/samples.json#sample.air_cooled_condenser.001',
   'Sample Air-Cooled Condenser', 20),
  ('prop_sample_cond_out_d', 'cat_hvac_condenser', '@example/hvac-ontology-samples',
   'Outlet diameter', 'geometry.inner_diameter', 'number', 9.5, 'Millimeter',
   'SYNTHETIC. Maps to Condenser.outletDiameter', 'catalog/samples.json#sample.air_cooled_condenser.001',
   'Sample Air-Cooled Condenser', 30),

  -- Sample Evaporator Coil
  ('prop_sample_evap_q', 'cat_hvac_evaporator', '@example/hvac-ontology-samples',
   'Cooling capacity', 'hvac.cooling_capacity', 'number', 3500, 'Watt',
   'SYNTHETIC. Maps to Evaporator.coolingCapacity', 'catalog/samples.json#sample.evaporator_coil.001',
   'Sample Evaporator Coil', 10),
  ('prop_sample_evap_in_d', 'cat_hvac_evaporator', '@example/hvac-ontology-samples',
   'Inlet diameter', 'geometry.inner_diameter', 'number', 9.5, 'Millimeter',
   'SYNTHETIC. Maps to Evaporator.inletDiameter', 'catalog/samples.json#sample.evaporator_coil.001',
   'Sample Evaporator Coil', 20),
  ('prop_sample_evap_out_d', 'cat_hvac_evaporator', '@example/hvac-ontology-samples',
   'Outlet diameter', 'geometry.inner_diameter', 'number', 12.7, 'Millimeter',
   'SYNTHETIC. Maps to Evaporator.outletDiameter', 'catalog/samples.json#sample.evaporator_coil.001',
   'Sample Evaporator Coil', 30),

  -- Sample Expansion Valve
  ('prop_sample_txv_q', 'cat_hvac_txv', '@example/hvac-ontology-samples',
   'Rated capacity', 'hvac.rated_capacity', 'number', 3500, 'Watt',
   'SYNTHETIC. Maps to ExpansionValve.ratedCapacity', 'catalog/samples.json#sample.expansion_valve.001',
   'Sample Expansion Valve', 10),
  ('prop_sample_txv_in_d', 'cat_hvac_txv', '@example/hvac-ontology-samples',
   'Inlet diameter', 'geometry.inner_diameter', 'number', 6.0, 'Millimeter',
   'SYNTHETIC. Maps to ExpansionValve.inletDiameter', 'catalog/samples.json#sample.expansion_valve.001',
   'Sample Expansion Valve', 20),
  ('prop_sample_txv_out_d', 'cat_hvac_txv', '@example/hvac-ontology-samples',
   'Outlet diameter', 'geometry.inner_diameter', 'number', 9.5, 'Millimeter',
   'SYNTHETIC. Maps to ExpansionValve.outletDiameter', 'catalog/samples.json#sample.expansion_valve.001',
   'Sample Expansion Valve', 30),

  -- Sample Axial Fan
  ('prop_sample_fan_q', 'cat_hvac_fan', '@example/hvac-ontology-samples',
   'Airflow rate', 'other.flow_rate', 'number', 0.35, 'Dimensionless',
   'SYNTHETIC. Maps to Fan.airflowRate', 'catalog/samples.json#sample.axial_fan.001',
   'Sample Axial Fan', 10),
  ('prop_sample_fan_pwr', 'cat_hvac_fan', '@example/hvac-ontology-samples',
   'Power', 'other.power', 'number', 85, 'Watt',
   'SYNTHETIC. Maps to Fan.power', 'catalog/samples.json#sample.axial_fan.001',
   'Sample Axial Fan', 20),
  ('prop_sample_fan_out_d', 'cat_hvac_fan', '@example/hvac-ontology-samples',
   'Outlet diameter', 'geometry.diameter', 'number', 300, 'Millimeter',
   'SYNTHETIC. Maps to Fan.outletDiameter', 'catalog/samples.json#sample.axial_fan.001',
   'Sample Axial Fan', 30)
ON CONFLICT (property_id) DO UPDATE SET
  name = EXCLUDED.name,
  value_number = EXCLUDED.value_number,
  unit = EXCLUDED.unit,
  description = EXCLUDED.description,
  source_ref = EXCLUDED.source_ref,
  part_ref = EXCLUDED.part_ref,
  updated_at = now();
