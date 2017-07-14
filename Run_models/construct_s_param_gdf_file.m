function construct_s_param_gdf_file(input_file_path, modelling_inputs, port_name)
% Write the input gdf file for an S-paramter simulation of the requested
% model.
%
% input_file_path is the path to the geometry model gdf file.
% modelling_inputs is the structure containing the input data for a single
% simulation run.
% port_name is
%
% Example: construct_s_param_gdf_file(mi, modelling_inputs, port_name)
if ~isempty(modelling_inputs.mat_list)
    materials = modelling_inputs.mat_list(:,1);
    material_labels = modelling_inputs.mat_list(:,2);
    material_override = find_material_overrides(...
        materials, modelling_inputs.defs);
else
    material_labels = [];
    material_override = [];
end %if


fs = gdf_s_param_header_construction('', 'temp', ...
       modelling_inputs.NPMLs,...
       modelling_inputs.n_cores,...
       modelling_inputs.mesh_stepsize,...
       material_override,...
       material_labels);
   
   
model_file = fullfile(input_file_path, ...
    [modelling_inputs.base_model_name, '_model_data']);
data = read_file_full_line(model_file);

mon = gdf_s_param_monitor_construction(port_name,...
    modelling_inputs.s_param_excitation_f, ...
    modelling_inputs.s_param_excitation_bw, ...
    modelling_inputs.s_param_tmax);
% construct the full input file.
data = cat(1,fs, modelling_inputs.defs', data, mon);
% write the full datafile to base_path.
write_out_data( data, 'temp_data/model.gdf')
