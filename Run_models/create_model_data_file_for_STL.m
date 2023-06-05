function model_file = create_model_data_file_for_STL(modelling_inputs)
% Combines the geometry-material-map, mesh_definition, and port_definition
% files with the geometry STL files to form the core of the gdf input file.


background = modelling_inputs.background;
stl_mapping = modelling_inputs.stl_part_mapping;
model_angle = modelling_inputs.model_angle;
model_scaling = modelling_inputs.stl_scaling;

% setting for if optional stagesgeometry graphs are requested.
eyepos.twodxeyepos = '   eyeposition= (-1, 0, 0)';
eyepos.twodyeyepos = '   eyeposition= (0, 1, 0)';
eyepos.twodzeyepos = '   eyeposition= (0, 0, 1)';
eyepos.threedxeyepos = '   eyeposition= (-2.3, 1, 0.5)';
eyepos.threedyeyepos = '   eyeposition= (-0.5, 1, 2.3)';
eyepos.threedzeyepos = '   eyeposition= (-1, 2.3, 0.5)';

model_file = {'###################################################'};
model_file = cat(1, model_file, '# Filling the initial volume with material');
model_file = cat(1, model_file, '-brick');
model_file = cat(1, model_file, ['material=',background]);
model_file = cat(1, model_file, 'xlow= -INF, xhigh= INF');
model_file = cat(1, model_file, 'ylow= -INF, yhigh= INF');
model_file = cat(1, model_file, 'zlow= -INF, zhigh= INF');
model_file = cat(1, model_file, 'doit');

model_file = cat(1, model_file, '###################################################');
stls = dir_list_gen(modelling_inputs.stl_location, 'stl',1);
for lwdc = 1:size(stls,1)
    [~, stl_list_from_directory{lwdc},~] = fileparts(stls{lwdc});
end %for
t1 = squeeze(modelling_inputs.stl_part_mapping(:,1));
for lwfc = 1:length(stl_list_from_directory)
    nd = find(strcmp(stl_list_from_directory, t1{lwfc}));
    if isempty(nd)
        fprinf(['\nUnable to find file for component ', t1{lwfc}])
    else
        tmep(lwfc) = nd;
    end %if
end %for
ordering = cell2mat(squeeze(modelling_inputs.stl_part_mapping(:,3)));
stls = stls(tmep(ordering));
for lrd = 1:length(stls)
    tmp = strsplit(stls{lrd}, filesep);
    tmp = tmp{end}(1:end-4);
    mat_ind = find(strcmp(stl_mapping(:,1), tmp));
    if isempty(mat_ind)
        fprinf(['\ncreate_model_data_file_for_STL: mat_ind is empty. ' ,...
            'This probably means that there is a name mismatch ',...
            'between the STL files and the mapping to part names.'])
    end %if
    model_file = cat(1, model_file, '-stlfile');
    model_file = cat(1, model_file, 'xfixed= yes, yfixed= yes, zfixed= yes');
    model_file = cat(1, model_file, ['file=', stls{lrd}]);
    if strcmpi(modelling_inputs.main_axis, 'x')
        model_file = cat(1, model_file, '# FreeCAD defaults to x as the main axis. GdfidL uses z.');
        model_file = cat(1, model_file, '# The following two lines rotate the geometry to move');
        model_file = cat(1, model_file, '# From FreeCAD coordinates, to GdfidL coordinates.');
        model_file = cat(1, model_file, '# There is also an adjustment in yprime in order.');
        model_file = cat(1, model_file, '# to rotate the model around the beam axis, to ');
        model_file = cat(1, model_file, '# adjust port locations.');
        model_file = cat(1, model_file, 'xprime= (0 ,0 ,1)');
        model_file = cat(1, model_file, ['yprime= (',num2str(model_angle/90),',', num2str(1-(model_angle/90)),', 0)']);
    elseif strcmpi(modelling_inputs.main_axis, 'y')
        model_file = cat(1, model_file, '# FreeCAD model beam axis is y. GdfidL uses z.');
        model_file = cat(1, model_file, '# The following two lines rotate the geometry to move');
        model_file = cat(1, model_file, '# From FreeCAD coordinates, to GdfidL coordinates.');
        model_file = cat(1, model_file, '# There is also an adjustment in yprime in order.');
        model_file = cat(1, model_file, '# to rotate the model around the beam axis, to ');
        model_file = cat(1, model_file, '# adjust port locations.');
        model_file = cat(1, model_file, 'xprime= (-1 ,0 ,0)');
        model_file = cat(1, model_file, ['yprime= (',num2str(model_angle/90),', 0,', num2str(1-(model_angle/90)),')']);
    elseif strcmpi(modelling_inputs.main_axis, 'z')
        model_file = cat(1, model_file, '# FreeCAD and GdfidL agree on the main axis. Nothing more to be done.');
    else
        error('Please enter x, y, or z for the model beam axis')
    end %if
    model_file = cat(1, model_file, '# The following three lines account for if the input file scale is not in m.');
    model_file = cat(1, model_file, ['xscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['yscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['zscale = ', num2str(model_scaling)]);
    model_file = cat(1, model_file, ['material=', stl_mapping{mat_ind,2}]);
    model_file = cat(1, model_file, 'doit');
    if strcmp(modelling_inputs.geometry_plotting, 'stages')
        [~,part_name, ~]=fileparts(stls{lrd});
        k = strfind(part_name, '-');
        model_file_vols = create_3D_volume_plots(modelling_inputs, eyepos, [part_name(k+1:end), '_']);
        model_file = cat(1, model_file, model_file_vols);
    end %if
end %for