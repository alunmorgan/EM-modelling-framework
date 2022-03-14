function construct_gdf_file(paths, sim_name, modelling_inputs, port_name, sparameter_set, frequency)
% Generate the correct gdf file for the requested simulation.
restart_root = fullfile(paths.restart_files_path, modelling_inputs.base_model_name, modelling_inputs.model_name);
restart_out = construct_storage_area_path(restart_root, sim_type, port_name, sparameter_set, frequency);

if strcmp(sim_name, 's_parameter')
    construct_s_param_gdf_file(modelling_inputs, port_name, sparameter_set, restart_out)
elseif strcmp(sim_name, 'geometry')
    construct_geometry_gdf_file(modelling_inputs, restart_out)
elseif strcmp(sim_name, 'wake')
    construct_wake_gdf_file(modelling_inputs,restart_out)
elseif strcmp(sim_name, 'eigenmode')
    construct_eigenmode_gdf_file(modelling_inputs, 'no', restart_out)
elseif strcmp(sim_name, 'lossy_eigenmode')
    construct_eigenmode_gdf_file(modelling_inputs, 'yes', restart_out)
elseif strcmp(sim_name, 'shunt')
    construct_shunt_gdf_file(paths, modelling_inputs, frequency)
end %if