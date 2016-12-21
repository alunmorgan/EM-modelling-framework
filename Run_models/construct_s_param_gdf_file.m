function construct_s_param_gdf_file(mi, modelling_inputs, port_name)
% Write the input gdf file for an S-paramter simulation of the requested
% model.
%
% mi is 
% modelling_inputs is
% port_name is
%
% Example: construct_s_param_gdf_file(mi, modelling_inputs, port_name)

mesh = mi.mesh_stepsize;
materials = mi.mat_list(:,1);
material_labels = mi.mat_list(:,2);
in_path = mi.input_file_path;
model_name = mi.model_name;
add_defs = modelling_inputs.defs;
num_threads = mi.n_cores;
excitation_f = mi.s_param_excitation_f;
excitation_bw = mi.s_param_excitation_bw;
tmax = mi.s_param_tmax;

material_override = find_material_overrides(materials,  add_defs);
model_file = [in_path, model_name, '_model_data'];
data = read_file_full_line(model_file);
fs = gdf_s_param_header_construction('', 'temp', num_threads, mesh,...
       material_override, material_labels);
mon = gdf_s_param_monitor_construction(port_name, excitation_f, excitation_bw, tmax);
% construct the full input file.
data = cat(1,fs, add_defs', data, mon);
% write the full datafile to base_path.
write_out_data( data, strcat('temp_data/','model.gdf') )
