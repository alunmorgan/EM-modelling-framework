function construct_gdf_file(paths, sim_name, modelling_inputs, port_name, frequency, plots)
% Generate the correct gdf file for the requested simulation.

if strcmp(sim_name, 'S-parameter')
    construct_s_param_gdf_file(paths.path_to_models, modelling_inputs, port_name)
elseif strcmp(sim_name, 'Wake')
    construct_wake_gdf_file(paths.path_to_models, modelling_inputs, plots)
elseif strcmp(sim_name, 'Eigenmode')
    construct_eigenmode_gdf_file(paths.path_to_models, modelling_inputs, plots, 'no')
elseif strcmp(sim_name, 'Lossy eigenmode')
    construct_eigenmode_gdf_file(paths.path_to_models, modelling_inputs, plots, 'yes')
elseif strcmp(sim_name, 'Shunt')
    construct_shunt_gdf_file(paths.path_to_models, modelling_inputs, frequency)
end %if