function construct_wake_gdf_file(data_location, storage_location, modelling_inputs, model_angle, plots)
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
    material_override = find_material_overrides(...
        materials,  modelling_inputs.defs);
else
    material_labels = [];
    material_override = [];
end %if

fs = gdf_wake_header_construction('', 'temp', ...
    modelling_inputs.NPMLs,...
    modelling_inputs.n_cores, ...
    modelling_inputs.mesh_stepsize,...
    modelling_inputs.beam_sigma, ...
    modelling_inputs.beam_offset_x, ...
    modelling_inputs.beam_offset_y, ...
    modelling_inputs.wakelength,...
    material_override,...
    material_labels);

geom_params = read_file_full_line(fullfile(data_location, modelling_inputs.base_model_name, ...
    [modelling_inputs.base_model_name, '_parameters.txt']));

geom = {'###################################################'};
for hes = 1:length(geom_params)
    temp_name = geom_params{hes};
    brk_ind = strfind(temp_name, ' : ');
    g_name = temp_name(1:brk_ind-1);
    g_val = regexprep(temp_name(brk_ind+3:end), '\s', '');
    geom = cat(1, geom, ['define(',g_name,',',g_val,')']);
end %for
geom = cat(1, geom, '###################################################');
modify_mesh_definition( storage_location, 'temp_data', modelling_inputs.geometry_fraction)
mesh_def = read_file_full_line(fullfile('temp_data', 'mesh_definition.txt'));
mesh_fixed_planes = gdf_write_mesh_fixed_planes(modelling_inputs.beam_offset_x, ...
    modelling_inputs.beam_offset_y);
data = create_model_data_file_for_STL(data_location, modelling_inputs.stl_part_mapping, ...
    modelling_inputs.base_model_name, model_angle, plots);

port_defs = gdf_write_port_definitions( modelling_inputs.ports,...
    modelling_inputs.port_location, modelling_inputs.port_modes);

if isfield(modelling_inputs, 'geom_only')
    mon = {'-volumeplot'};
    mon = cat(1,mon,'    doit');
else
    mon = gdf_wake_monitor_construction(modelling_inputs.wakelength);
end %if
% construct the full input file.
data = cat(1,fs, modelling_inputs.defs', geom, mesh_def, mesh_fixed_planes, ...
    data, port_defs, mon);
write_out_data( data, 'temp_data/model.gdf' )