function construct_gdf_file(sim_name, modelling_inputs, port_name, sparameter_set, frequency)
% Generate the correct gdf file for the requested simulation.

if strcmp(sim_name, 's_parameter')
    construct_s_param_gdf_file(modelling_inputs, port_name, sparameter_set)
elseif strcmp(sim_name, 'geometry')
    construct_geometry_gdf_file(modelling_inputs)
elseif strcmp(sim_name, 'wake')
    construct_wake_gdf_file(modelling_inputs)
elseif strcmp(sim_name, 'eigenmode')
    construct_eigenmode_gdf_file(modelling_inputs, 'no')
elseif strcmp(sim_name, 'lossy_eigenmode')
    construct_eigenmode_gdf_file(modelling_inputs, 'yes')
elseif strcmp(sim_name, 'shunt')
    construct_shunt_gdf_file(modelling_inputs, frequency)
end %if