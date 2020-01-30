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
stls = dir_list_gen(modelling_inputs.stl_location, 'stl',1);
t1 = squeeze(modelling_inputs.stl_part_mapping(:,1));
for lwfc = 1:size(stls,1)
    tmep(lwfc) = find_position_in_cell_lst(strfind(stls, t1{lwfc}));
end
ordering = cell2mat(squeeze(modelling_inputs.stl_part_mapping(:,3)));
stls = stls(tmep(ordering));
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
    model_file = cat(1, model_file, 'xprime= (0 ,0 ,-1)');
    model_file = cat(1, model_file, ['yprime= (',num2str(model_angle/90),',', num2str(1-(model_angle/90)),', 0)']);
    model_file = cat(1, model_file, '# The following three lines account for if the input file scale is not in m.');
    model_file = cat(1, model_file, ['xscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['yscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['zscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['material=', stl_mapping{mat_ind,2}]);
    model_file = cat(1, model_file, 'doit');
    if plots > 1
        model_file = cat(1, model_file, '-volumeplot');
        model_file = cat(1, model_file,['    plotopts = -o temp_data/3Dmodel_partial_',num2str(lrd),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    end %if
end %for

if plots == 1
    model_file = cat(1, model_file, '-volumeplot');
    model_file = cat(1, model_file,'    plotopts = -o temp_data/3Dmodel.ps -colorps');
    model_file = cat(1, model_file, 'doit');
    for ndw = 1:size(modelling_inputs.cuts,1)
        model_file = cat(1, model_file, '-volumeplot');
        if strcmp(modelling_inputs.cuts{ndw, 1},'x')
            model_file = reset_bounding_box(model_file);
            model_file = cat(1, model_file, ['   bbxlow=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, ['   bbxhigh=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (1, 0, 0)');
        elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
            model_file = reset_bounding_box(model_file);
            model_file = cat(1, model_file, ['   bbylow=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, ['   bbyhigh=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (0, 1, 0)');
        elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
            model_file = reset_bounding_box(model_file);
            model_file = cat(1, model_file, ['   bbzlow=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, ['   bbzhigh=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (0, 0, 1)');
        end %if
        model_file = cat(1, model_file, ['   plotopts = -o temp_data/2Dmodel_cut_',modelling_inputs.cuts{ndw, 1},'_',num2str(modelling_inputs.cuts{ndw, 2}),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    end %for
    for ndw = 1:size(modelling_inputs.cuts,1)
        model_file = cat(1, model_file, '-volumeplot');
        if strcmp(modelling_inputs.cuts{ndw, 1},'x')
            model_file = reset_bounding_box(model_file);
            model_file = cat(1, model_file, ['   bbxhigh=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (2.3, 1, -0.5)');
        elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
            model_file = reset_bounding_box(model_file);
            model_file = cat(1, model_file, ['   bbyhigh=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (1, 2.3, -0.5)');
        elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
            model_file = reset_bounding_box(model_file);
            model_file = cat(1, model_file, ['   bbzhigh=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (-0.5, 1, 2.3)');
        end %if
        model_file = cat(1, model_file, ['   plotopts = -o temp_data/3Dmodel_cut_',modelling_inputs.cuts{ndw, 1},'_',num2str(modelling_inputs.cuts{ndw, 2}),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    end %for
        model_file = reset_bounding_box(model_file);
    for ndw = 1:size(modelling_inputs.cuts,1)
        model_file = cat(1, model_file, '-cutplot');
        model_file = cat(1, model_file, 'draw= approximated');
        if strcmp(modelling_inputs.cuts{ndw, 1},'x')
            model_file = cat(1, model_file, '    normal=x');
            model_file = cat(1, model_file, ['   cutat=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (1, 0, 0)');
        elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
            model_file = cat(1, model_file, '    normal=y');
            model_file = cat(1, model_file, ['   cutat=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (0, 1, 0)');
        elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
            model_file = cat(1, model_file, '    normal=z');
            model_file = cat(1, model_file, ['   cutat=',num2str(modelling_inputs.cuts{ndw, 2})]);
            model_file = cat(1, model_file, '   eyeposition= (0, 0, 1)');
        end %if
        model_file = cat(1, model_file, ['   plotopts = -o temp_data/2Dmodel_cutplot_',modelling_inputs.cuts{ndw, 1},'_',num2str(modelling_inputs.cuts{ndw, 2}),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    end %for
end %if

model_file = cat(1, model_file, '###################################################');
end %function
function text_data = reset_bounding_box(text_data)
text_data = cat(1, text_data, '   bbxlow= -1E+30');
text_data = cat(1, text_data, '   bbylow= -1E+30');
text_data = cat(1, text_data, '   bbzlow= -1E+30');
text_data = cat(1, text_data, '   bbxhigh= 1E+30');
text_data = cat(1, text_data, '   bbyhigh= 1E+30');
text_data = cat(1, text_data, '   bbzhigh= 1E+30');
end % function