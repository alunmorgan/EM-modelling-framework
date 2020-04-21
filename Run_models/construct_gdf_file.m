function construct_gdf_file(sim_name, modelling_inputs, port_name, frequency)
% Generate the correct gdf file for the requested simulation.

if strcmp(sim_name, 'S-parameter')
    construct_s_param_gdf_file(modelling_inputs, port_name)
elseif strcmp(sim_name, 'Geometry')
    construct_geometry_gdf_file(modelling_inputs)
elseif strcmp(sim_name, 'Wake')
    construct_wake_gdf_file(modelling_inputs)
elseif strcmp(sim_name, 'Eigenmode')
    construct_eigenmode_gdf_file(modelling_inputs, 'no')
elseif strcmp(sim_name, 'Lossy eigenmode')
    construct_eigenmode_gdf_file(modelling_inputs, 'yes')
elseif strcmp(sim_name, 'Shunt')
    construct_shunt_gdf_file(modelling_inputs, frequency)
end %if