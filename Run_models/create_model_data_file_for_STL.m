function create_model_data_file_for_STL(data_location)

parts = strsplit(data_location, filesep);
common_file_loc = fullfile(parts{1:end-1});
if strcmp(data_location(1), filesep)
    % fullfile does not keep the initial slash for an absolute path on
    % linux. This puts it back.
    common_file_loc = strcat(filesep, common_file_loc);
end %if

geom = read_file_full_line(fullfile(common_file_loc, 'geometry-material-map.txt'));
mesh_def = read_file_full_line(fullfile(common_file_loc, 'mesh_definition.txt'));
port_def = read_file_full_line(fullfile(common_file_loc, 'port_definition.txt'));

geom = reduce_cell_depth(geom);
vals = reduce_cell_depth(reduce_cell_depth(...
    regexp(geom, '(.*)\s:\s(.*)', 'tokens')));

model_file = {'###################################################'};
for hes = 1:length(mesh_def)
model_file = cat(1, model_file, mesh_def{hes}{1});
end
model_file = cat(1, model_file, '###################################################');

%TODO - middle section
stls = dir_list_gen(fullfile(data_location, 'ascii'), 'stl');
for lrd = 1:length(stls)
    tmp = strsplit(stls{lrd}, filesep);
    tmp = tmp{end}(1:end-4);
    mat_ind = find_position_in_cell_lst(strfind(vals(:,1), tmp));
model_file = cat(1, model_file, '-stlfile');
model_file = cat(1, model_file, ['file=', stls{lrd}]);
model_file = cat(1, model_file, 'xprime= (0 ,0 ,1)');
model_file = cat(1, model_file, 'yprime= (0, 1, 0)');
model_file = cat(1, model_file, ['material=', vals{mat_ind,2}]);
% model_file = cat(1, model_file, 'xscale= 1e-3');
% model_file = cat(1, model_file, 'yscale= 1e-3');
% model_file = cat(1, model_file, 'zscale= 1e-3');
model_file = cat(1, model_file, 'doit');
end %for

model_file = cat(1, model_file, '###################################################');
for hef = 1:length(port_def)
model_file = cat(1, model_file, port_def{hef}{1});
end

write_out_data(model_file, fullfile(data_location, [parts{end}, '_model_data']))
