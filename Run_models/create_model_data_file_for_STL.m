function model_file = create_model_data_file_for_STL(modelling_inputs, models_location, plots)
% Combines the geometry-material-map, mesh_definition, and port_definition
% files with the geometry STL files to form the core of the gdf input file.

% geom = read_file_full_line(fullfile(storage_location, 'geometry-material-map.txt'));
% mesh_def = read_file_full_line(fullfile(storage_location, 'mesh_definition.txt')); % <- start HERE
% geom_params = read_file_full_line(fullfile(data_location, base_model_name, ...
%     [base_model_name, '_parameters.txt']));

% geom = reduce_cell_depth(geom);
% stl_mapping = reduce_cell_depth(reduce_cell_depth(...
%     regexp(geom, '(.*)\s:\s(.*)', 'tokens')));

 background = modelling_inputs.background;
 stl_mapping = modelling_inputs.stl_part_mapping;
%  base_model_name = modelling_inputs.base_model_name; 
%  model_name = modelling_inputs.model_name;
 model_angle = modelling_inputs.model_angle;
 model_scaling = modelling_inputs.stl_scaling;

model_file = {'###################################################'};
% for hes = 1:length(geom_params)
%     temp_name = geom_params{hes};
%     brk_ind = strfind(temp_name, ' : ');
%     g_name = temp_name(1:brk_ind-1);
%     g_val = regexprep(temp_name(brk_ind+3:end), '\s', '');
%     model_file = cat(1, model_file, ['define(',g_name,',',g_val,')']);
% end
% model_file = cat(1, model_file, '###################################################');
% for hes = 1:length(mesh_def)
%     model_file = cat(1, model_file, mesh_def{hes});
% end
% model_file = cat(1, model_file, '###################################################');
model_file = cat(1, model_file, '# Filling the initial volume with material');
model_file = cat(1, model_file, '-brick');
model_file = cat(1, model_file, ['material=',background]);
model_file = cat(1, model_file, 'xlow= -INF, xhigh= INF');
model_file = cat(1, model_file, 'ylow= -INF, yhigh= INF');
model_file = cat(1, model_file, 'zlow= -INF, zhigh= INF');
model_file = cat(1, model_file, 'doit');

model_file = cat(1, model_file, '###################################################');
stls = dir_list_gen(fullfile(models_location, base_model_name, model_name, 'ascii'), 'stl',1);

for lrd = 1:length(stls)
    tmp = strsplit(stls{lrd}, filesep);
    tmp = tmp{end}(1:end-4);
    mat_ind = find_position_in_cell_lst(strfind(stl_mapping(:,1), tmp));
    if isempty(mat_ind)
        warning(['create_model_data_file_for_STL: mat_ind is empty. ' ,...
            'This probably means that there is a name mismatch ',...
            'between the STL files and the mapping to part names.'])
    end %if
    model_file = cat(1, model_file, '-stlfile');
    model_file = cat(1, model_file, ['file=', stls{lrd}]);
    model_file = cat(1, model_file, '# FreeCAD defaults to x as the main axis. GdfidL uses z.');
    model_file = cat(1, model_file, '# The following two lines rotate the geometry to move');
    model_file = cat(1, model_file, '# From FreeCAD coordinates, to GdfidL coordinates.');
    model_file = cat(1, model_file, '# There is also an adjustment in yprime in order.');
    model_file = cat(1, model_file, '# to rotate the model around the beam axis, to ');
    model_file = cat(1, model_file, '# adjust port locations.');
    model_file = cat(1, model_file, 'xprime= (0 ,0 ,1)');
    model_file = cat(1, model_file, ['yprime= (',num2str(model_angle/90),',', num2str(1-(model_angle/90)),', 0)']);
    model_file = cat(1, model_file, '# The following three lines account for if the input file scale is not in m.');
    model_file = cat(1, model_file, ['xscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['yscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['zscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['material=', stl_mapping{mat_ind,2}]);
    model_file = cat(1, model_file, 'doit');
    if plots > 1
        model_file = cat(1, model_file, '-volumeplot');
        model_file = cat(1, model_file, 'doit');
    end %if
end %for

if plots == 1
    model_file = cat(1, model_file, '-volumeplot');
    model_file = cat(1, model_file, 'doit');
end %if

model_file = cat(1, model_file, '###################################################');
