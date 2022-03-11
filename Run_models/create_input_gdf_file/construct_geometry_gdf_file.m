function construct_geometry_gdf_file(modelling_inputs, restart_out)
% Write the input gdf file to generate the geometry of the requested
% model.
%
% input_file_path is the path to the geometry model gdf file.
% modelling_inputs is the structure containing the input data for a single
% simulation run.
%
% Example: construct_wake_gdf_file(models_location, storage_location, modelling_inputs, plots)

if ~isempty(modelling_inputs.mat_list)
    materials = modelling_inputs.mat_list(:,1);
    material_labels = modelling_inputs.mat_list(:,2);
    material_override = find_material_overrides(...
        materials,  modelling_inputs.defs);
else
    material_labels = [];
    material_override = [];
end %if

fs = gdf_wake_header_construction('',restart_out, 'temp', ...
    modelling_inputs.NPMLs,...
    modelling_inputs.n_cores, ...
    modelling_inputs.mesh_stepsize,...
    modelling_inputs.mesh_density_scaling,...
    modelling_inputs.beam_sigma, ...
    modelling_inputs.beam_offset_x, ...
    modelling_inputs.beam_offset_y, ...
    modelling_inputs.wakelength,...
    material_override,...
    material_labels);

geom = {'###################################################'};
if ~isempty(length(modelling_inputs.geometry_defs))
    for gdefind = 1:length(modelling_inputs.geometry_defs)
        geom = cat(1, geom, ['define(',modelling_inputs.geometry_defs{gdefind}{1},...
            ',',num2str(modelling_inputs.geometry_defs{gdefind}{2}{1}),')']);
    end %for
else
    geom =  cat(1, geom, '# NO parameter file assume fixed geometry #');
end %if
geom = cat(1, geom, '###################################################');

modelling_inputs.mesh = modify_mesh_definition(modelling_inputs.mesh, modelling_inputs.geometry_fraction);
mesh_def = mesh_definition_construction(modelling_inputs.mesh, modelling_inputs.mesh_density_scaling);
mesh_def = cat(1,mesh_def, '#');
mesh_def = cat(1,mesh_def, '# We enforce a meshline at the position of the linecharge');
mesh_def = cat(1,mesh_def, '# by enforcing two meshplanes');
mesh_def = cat(1,mesh_def, '#');
mesh_fixed_planes = gdf_write_mesh_fixed_planes(modelling_inputs.beam_offset_x, ...
    modelling_inputs.beam_offset_y);
data = create_model_data_file_for_STL(modelling_inputs);
plots = create_geometry_plots(modelling_inputs);
% construct the full input file.
data = cat(1,fs, modelling_inputs.defs', geom, mesh_def, mesh_fixed_planes, ...
    data, plots);
write_out_data( data, 'model.gdf' )