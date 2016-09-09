function construct_eigenmode_gdf_file(mi, modelling_inputs, islossy)
% Write the input gdf file for an eigenmode simulation of the requested
% model.
%
% mi is 
% modelling_inputs is
% islossy is
%
% Example: construct_eigenmode_gdf_file(mi, modelling_inputs, islossy)

mesh = mi.mesh_stepsize;
materials = mi.mat_list(:,1);
material_labels = mi.mat_list(:,2);
in_path = mi.input_file_path;
model_name = mi.model_name;
add_defs = modelling_inputs.defs;
num_threads = modelling_inputs.n_cores;

material_override = find_material_overrides(materials,  add_defs);

model_file = [in_path, model_name, '_model_data'];
data = read_file_full_line(model_file);
% switch the port descriptions to the eigenvalues section.
data = regexprep(data, '-fdtd', '-eigenvalues');
fs = gdf_eigenmode_header_construction('', 'temp', num_threads, mesh, material_override, material_labels);
mon = gdf_eigenmode_monitor_construction(100, islossy);
% construct the full input file.
data = cat(1,fs, add_defs', data, mon);
% write the full datafile to base_path.
 write_out_data( data, 'temp_data/model.gdf' )
