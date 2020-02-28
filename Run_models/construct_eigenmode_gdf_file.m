function construct_eigenmode_gdf_file(models_location, modelling_inputs, plots, islossy)
% Write the input gdf file for an eigenmode simulation of the requested
% model.
%
% mi is
% modelling_inputs is
% islossy is
%
% Example: construct_eigenmode_gdf_file(mi, modelling_inputs, islossy)

if ~isempty(modelling_inputs.mat_list)
    materials = modelling_inputs.mat_list(:,1);
    material_labels = modelling_inputs.mat_list(:,2);
    % add_defs = modelling_inputs.defs;
    material_override = find_material_overrides(materials,  modelling_inputs.defs);
else
    material_labels = [];
    material_override = [];
end %if

fs = gdf_eigenmode_header_construction('', 'temp', ...
    modelling_inputs.NPMLs,...
    modelling_inputs.n_cores,...
    modelling_inputs.mesh_stepsize,...
    modelling_inputs.mesh_density_scaling,...
    material_override, ...
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
data = create_model_data_file_for_STL(modelling_inputs, models_location, plots);

% data = read_file_full_line(models_location);
% switch the port descriptions to the eigenvalues section.
data = regexprep(data, '-fdtd', '-eigenvalues');

if isempty(modelling_inputs.port_modes)
    port_defs = {''};
else
    % FIXME this assumes one port per side.
    if modelling_inputs.geometry_fraction == 1
        port_defs = gdf_write_port_definitions( modelling_inputs.ports,...
            modelling_inputs.port_location, modelling_inputs.port_modes);
    elseif modelling_inputs.geometry_fraction == 0.5
        port_defs = gdf_write_port_definitions( modelling_inputs.ports(1:3),...
            modelling_inputs.port_location(1:3), modelling_inputs.port_modes(1:3));
    elseif modelling_inputs.geometry_fraction == 0.25
        port_defs = gdf_write_port_definitions( modelling_inputs.ports(1:2),...
            modelling_inputs.port_location(1:2), modelling_inputs.port_modes(1:2));
    else
        error('invalid geometry fraction')
    end %if
end %if

if isfield(modelling_inputs, 'geom_only')
    mon = {''};
else
    
    mon = gdf_eigenmode_monitor_construction(...
        modelling_inputs.eigenmode.estimation_frequency, ...
        modelling_inputs.eigenmode.number_of_solutions, ...
        islossy, modelling_inputs.eigenmode.f_range);
end %if

% construct the full input file.
data = cat(1,fs, modelling_inputs.defs', geom, mesh_def, mesh_fixed_planes, data, port_defs, mon);
% write the full datafile to base_path.
write_out_data( data, 'temp_data/model.gdf' )
