function construct_wake_gdf_file(input_file_path, modelling_inputs)
% Write the input gdf file for an wake simulation of the requested
% model.
%
% input_file_path is the path to the geometry model gdf file.
% modelling_inputs is the structure containing the input data for a single
% simulation run.
%
% Example: construct_s_param_gdf_file(input_file_path, modelling_inputs)

if ~isempty(modelling_inputs.mat_list)
    materials = modelling_inputs.mat_list(:,1);
    material_labels = modelling_inputs.mat_list(:,2);
    material_override = find_material_overrides(materials,  modelling_inputs.defs);
else
    material_labels = [];
    material_override = [];
end

fs = gdf_wake_header_construction('', 'temp', ...
    modelling_inputs.NPMLs,...
    modelling_inputs.n_cores, ...
    modelling_inputs.mesh_stepsize,...
    modelling_inputs.beam_sigma, ...
    modelling_inputs.wakelength,...
    material_override,...
    material_labels);

model_name = modelling_inputs.model_name;
model_file = fullfile(input_file_path, [model_name, '_model_data']);
data = read_file_full_line(model_file);

if isfield(modelling_inputs, 'geom_only')
    mon = {'-volumeplot'};
    mon = cat(1,mon,'    doit');
else
    mon = gdf_wake_monitor_construction(modelling_inputs.wakelength);
end %if
% construct the full input file.
data = cat(1,fs, modelling_inputs.defs', data, mon);
write_out_data( data, 'temp_data/model.gdf' )