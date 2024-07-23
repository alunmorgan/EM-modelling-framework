function construct_gdf_file(out_loc, paths, tail, sim_name, modelling_inputs, port_name, sparameter_set, frequency)
% Generate the correct gdf file for the requested simulation.

if strcmp(sim_name, 'sparameter')
    construct_s_param_gdf_file(out_loc, modelling_inputs, paths, tail, port_name, sparameter_set)
elseif strcmp(sim_name, 'geometry')
    construct_geometry_gdf_file(out_loc, modelling_inputs, paths, tail)
elseif strcmp(sim_name, 'wake')
    construct_wake_gdf_file(out_loc, modelling_inputs, paths, tail)
elseif strcmp(sim_name, 'eigenmode')
    construct_eigenmode_gdf_file(out_loc, modelling_inputs, paths, tail, 'no')
elseif strcmp(sim_name, 'lossy_eigenmode')
    construct_eigenmode_gdf_file(out_loc, modelling_inputs, paths, tail, 'yes')
elseif strcmp(sim_name, 'shunt')
    construct_shunt_gdf_file(out_loc, modelling_inputs, paths, tail, frequency)
end %if