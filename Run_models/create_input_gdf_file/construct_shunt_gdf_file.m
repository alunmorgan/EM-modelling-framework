function construct_shunt_gdf_file(path_to_model_data_file, modelling_inputs, frequency)

materials = modelling_inputs.mat_list(:,1);
material_labels = modelling_inputs.mat_list(:,2);
add_defs = modelling_inputs.defs;
material_override = find_material_overrides(materials,  add_defs);

data = read_file_full_line(path_to_model_data_file);
% switch the port descriptions to the eigenvalues section.
fs = gdf_shunt_header_construction('', 'temp',...
    modelling_inputs.NPMLs,...
    modelling_inputs.n_cores,...
    modelling_inputs.mesh_stepsize,...
    material_override, material_labels, frequency);

port_defs = gdf_write_port_definitions( modelling_inputs.ports,...
    modelling_inputs.port_location, modelling_inputs.port_modes);

mon = gdf_shunt_monitor_construction;
% construct the full input file.
data = cat(1,fs, add_defs', data, port_defs, mon);
% write the full datafile to base_path.
 write_out_data( data, 'temp_data/model.gdf' )
