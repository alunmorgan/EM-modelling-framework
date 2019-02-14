function model_file = create_model_data_file_for_STL(data_location, storage_location, ...
    base_model_name, model_angle, plots)
% Combines the geometry-material-map, mesh_definition, and port_definition
% files with the geometry STL files to form the core of the gdf input file.

geom = read_file_full_line(fullfile(storage_location, 'geometry-material-map.txt'));
% mesh_def = read_file_full_line(fullfile(storage_location, 'mesh_definition.txt')); % <- start HERE
% geom_params = read_file_full_line(fullfile(data_location, base_model_name, ...
%     [base_model_name, '_parameters.txt']));

% geom = reduce_cell_depth(geom);
vals = reduce_cell_depth(reduce_cell_depth(...
    regexp(geom, '(.*)\s:\s(.*)', 'tokens')));

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
model_file = cat(1, model_file, '# Filling the initial volume with PEC');
model_file = cat(1, model_file, '-brick');
model_file = cat(1, model_file, 'material=PEC');
model_file = cat(1, model_file, 'xlow= -INF, xhigh= INF');
model_file = cat(1, model_file, 'ylow= -INF, yhigh= INF');
model_file = cat(1, model_file, 'zlow= -INF, zhigh= INF');
model_file = cat(1, model_file, 'doit');

model_file = cat(1, model_file, '###################################################');
stls = dir_list_gen(fullfile(data_location, base_model_name, 'ascii'), 'stl',1);
%%%% TEMP to fix ordering
temp1 = find_position_in_cell_lst(strfind(stls, '-vac.stl'));
temp2 = find_position_in_cell_lst(strfind(stls, '-button'));
temp3 = find_position_in_cell_lst(strfind(stls, '-ceramic'));
temp4 = find_position_in_cell_lst(strfind(stls, '-pin'));
temp5 = find_position_in_cell_lst(strfind(stls, '-shell'));
temp6 = find_position_in_cell_lst(strfind(stls, '-block.stl'));
temp7 = find_position_in_cell_lst(strfind(stls, '-beampipe.stl'));
inds = [temp1, temp2, temp3, temp4, temp5, temp6, temp7];
stls = stls(inds);
%%%%%%%%%%
for lrd = 1:length(stls)
    tmp = strsplit(stls{lrd}, filesep);
    tmp = tmp{end}(1:end-4);
    mat_ind = find_position_in_cell_lst(strfind(vals(:,1), tmp));
    if isempty(mat_ind)
        warning(['create_model_data_file_for_STL: mat_ind is empty. ' ,...
            'This probably means that there is a name mismatch ',...
            'between the STL files and the names in the ',...
            'geometry-material-map file.'])
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
    model_file = cat(1, model_file, ['material=', vals{mat_ind,2}]);
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

% write_out_data(model_file, fullfile(storage_location, output_name, [output_name, '_model_data']))
