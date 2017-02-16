function construct_wake_gdf_file(mi, modelling_inputs)
% Write the input gdf file for an wake simulation of the requested
% model.
%
% mi is 
% modelling_inputs is
%
% Example: construct_s_param_gdf_file(mi, modelling_inputs)

sigma =  mi.beam_sigma;
mesh = mi.mesh_stepsize;
wake_length = mi.wakelength;

in_path = mi.input_file_path;
model_name = mi.model_name;
add_defs = modelling_inputs.defs;
num_threads = modelling_inputs.n_cores;
if ~isempty(mi.mat_list)
    materials = mi.mat_list(:,1);
    material_labels = mi.mat_list(:,2);
    material_override = find_material_overrides(materials,  add_defs);
else
    material_labels = [];
    material_override = [];
end
model_file = [in_path, model_name, '_model_data'];
data = read_file_full_line(model_file);
fs = gdf_wake_header_construction('', 'temp', num_threads, mesh, sigma, ...
    wake_length, material_override,material_labels);
if isfield(modelling_inputs, 'geom_only')
    vdsp = {'-volumeplot'};
    vdsp = cat(1,vdsp,'    doit');
    % construct the full input file.
    data = cat(1,fs, add_defs', data, vdsp);
else
    mon = gdf_wake_monitor_construction(wake_length);
    % construct the full input file.
    data = cat(1,fs, add_defs', data, mon);
end

 write_out_data( data, 'temp_data/model.gdf' )