function model_file = create_volume_plots(modelling_inputs, eyepos, geom_prefix)
model_file = {'-volumeplot'};
model_file = cat(1, model_file, eyepos.threedxeyepos);
model_file = cat(1, model_file, '   scale=3.5');
model_file = cat(1, model_file,['    plotopts = -o ./', geom_prefix, '3Dmodel.ps -colorps']);
model_file = cat(1, model_file, 'doit');
% model_file = cat(1, model_file, 'showlines=yes');
% model_file = cat(1, model_file,['    plotopts = -o ./', geom_prefix, '3Dmodel_w_lines.ps -colorps']);
% model_file = cat(1, model_file, 'doit');
x_count = 0;
y_count = 0;
z_count = 0;

model_file = cat(1, model_file, 'showlines=no');
for ndw = 1:size(modelling_inputs.cuts,1)
    if strcmp(modelling_inputs.cuts{ndw, 1},'x')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbxlow=', modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, ['   bbxhigh=', modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodxeyepos);
        x_count = x_count +1;
        model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dmodel_cut_', modelling_inputs.cuts{ndw, 1},'_user',num2str(x_count),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbylow=', modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, ['   bbyhigh=', modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodyeyepos);
        y_count = y_count +1;
        model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dmodel_cut_', modelling_inputs.cuts{ndw, 1},'_user', num2str(y_count),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbzlow=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, ['   bbzhigh=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodzeyepos);
        z_count = z_count +1;
        model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dmodel_cut_',modelling_inputs.cuts{ndw, 1},'_user',num2str(z_count),'.ps -colorps']);
        model_file = cat(1, model_file, 'doit');
    end %if
end %for
x3d_count = 0;
y3d_count = 0;
z3d_count = 0;
model_file = cat(1, model_file, 'showlines=yes');
for ndw = 1:size(modelling_inputs.cuts,1)
    
    if strcmp(modelling_inputs.cuts{ndw, 1},'x')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbxlow=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.threedxeyepos);
        x3d_count = x3d_count +1;
        count3d = x3d_count;
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbyhigh=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.threedyeyepos);
        y3d_count = y3d_count +1;
        count3d = y3d_count;
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbzlow=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.threedzeyepos);
        z3d_count = z3d_count +1;
        count3d = y3d_count;
    end %if
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '3Dmodel_cut_',modelling_inputs.cuts{ndw, 1},'_user',num2str(count3d),'.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
end %for
for ndfd = 1:length(modelling_inputs.subsections)
    model_file = cat(1, model_file, ['   bbxhigh=', modelling_inputs.subsections{ndfd}.xmax]);
    model_file = cat(1, model_file, ['   bbxlow=', modelling_inputs.subsections{ndfd}.xmin]);
    model_file = cat(1, model_file, ['   bbyhigh=', modelling_inputs.subsections{ndfd}.ymax]);
    model_file = cat(1, model_file, ['   bbylow=', modelling_inputs.subsections{ndfd}.ymin]);
    model_file = cat(1, model_file, ['   bbzhigh=', modelling_inputs.subsections{ndfd}.zmax]);
    model_file = cat(1, model_file, ['   bbzlow=', modelling_inputs.subsections{ndfd}.zmin]);
    model_file = cat(1, model_file, 'doit');
    x_centre = ['(', modelling_inputs.subsections{ndfd}.xmax, ') - (', modelling_inputs.subsections{ndfd}.xmin, ')'];
    y_centre = ['(', modelling_inputs.subsections{ndfd}.ymax, ') - (', modelling_inputs.subsections{ndfd}.ymin, ')'];
    z_centre = ['(', modelling_inputs.subsections{ndfd}.zmax, ') - (', modelling_inputs.subsections{ndfd}.zmin, ')'];
    %     model_file = cat(1, model_file, '   scale=3');
    model_file = cat(1, model_file, ['   bbxhigh=', x_centre]);
    model_file = cat(1, model_file, ['   bbxlow=', x_centre]);
    model_file = cat(1, model_file, eyepos.twodxeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dsub',num2str(ndfd),'_cut_x_.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, ['   bbxhigh=', modelling_inputs.subsections{ndfd}.xmax]);
    model_file = cat(1, model_file, ['   bbxlow=', modelling_inputs.subsections{ndfd}.xmin]);
    model_file = cat(1, model_file, ['   bbyhigh=', y_centre]);
    model_file = cat(1, model_file, ['   bbylow=', y_centre]);
    model_file = cat(1, model_file, eyepos.twodyeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dsub',num2str(ndfd),'_cut_y_.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, ['   bbyhigh=', modelling_inputs.subsections{ndfd}.ymax]);
    model_file = cat(1, model_file, ['   bbylow=', modelling_inputs.subsections{ndfd}.ymin]);
    model_file = cat(1, model_file, ['   bbzhigh=', z_centre]);
    model_file = cat(1, model_file, ['   bbzlow=', z_centre]);
    model_file = cat(1, model_file, eyepos.twodzeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dsub',num2str(ndfd),'_cut_z_.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, ['   bbzhigh=', modelling_inputs.subsections{ndfd}.zmax]);
    model_file = cat(1, model_file, ['   bbzlow=', modelling_inputs.subsections{ndfd}.zmin]);
    model_file = cat(1, model_file, eyepos.threedxeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '3Dsub',num2str(ndfd),'.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
end %for
model_file = reset_bounding_box(model_file);
