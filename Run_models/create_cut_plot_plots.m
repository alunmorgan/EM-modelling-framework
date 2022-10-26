function model_file = create_cut_plot_plots (modelling_inputs, eyepos, geom_prefix)
model_file = {'-cutplot'};
model_file = cat(1, model_file, 'draw= approximated');
x_count = 0;
y_count = 0;
z_count = 0;
for ndw = 1:size(modelling_inputs.cuts,1)
    if strcmp(modelling_inputs.cuts{ndw, 1},'x')
        model_file = cat(1, model_file, '    normal=x');
        model_file = cat(1, model_file, ['   cutat=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodxeyepos);
        x_count = x_count +1;
        count = x_count;
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
        model_file = cat(1, model_file, '    normal=y');
        model_file = cat(1, model_file, ['   cutat=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodyeyepos);
        y_count = y_count +1;
        count = y_count;
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
        model_file = cat(1, model_file, '    normal=z');
        model_file = cat(1, model_file, ['   cutat=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodzeyepos);
        z_count = z_count +1;
        count = z_count;
    end %if
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dmodel_cutplot_',modelling_inputs.cuts{ndw, 1},'_user',num2str(count),'.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
end %for
for ndfd = 1:length(modelling_inputs.subsections)
    model_file = cat(1, model_file,'-volumeplot');
    model_file = cat(1, model_file, ['   bbxhigh=', modelling_inputs.subsections{ndfd}.xmax]);
    model_file = cat(1, model_file, ['   bbxlow=', modelling_inputs.subsections{ndfd}.xmin]);
    model_file = cat(1, model_file, ['   bbyhigh=', modelling_inputs.subsections{ndfd}.ymax]);
    model_file = cat(1, model_file, ['   bbylow=', modelling_inputs.subsections{ndfd}.ymin]);
    model_file = cat(1, model_file, ['   bbzhigh=', modelling_inputs.subsections{ndfd}.zmax]);
    model_file = cat(1, model_file, ['   bbzlow=', modelling_inputs.subsections{ndfd}.zmin]);
    model_file = cat(1, model_file, '   scale=3');
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file,'-cutplot');
    model_file = cat(1, model_file, 'draw= approximated');
    model_file = cat(1, model_file, '    normal=x');
    model_file = cat(1, model_file, ['   cutat= (',modelling_inputs.subsections{ndfd}.xmax, ') - (', modelling_inputs.subsections{ndfd}.xmin, ')']);
    model_file = cat(1, model_file, eyepos.twodxeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dsub',num2str(ndfd),'_cutplot_x.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, '    normal=y');
    model_file = cat(1, model_file, ['   cutat= (',modelling_inputs.subsections{ndfd}.ymax, ') - (', modelling_inputs.subsections{ndfd}.ymin, ')']);
    model_file = cat(1, model_file, eyepos.twodyeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dsub',num2str(ndfd),'_cutplot_y.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, '    normal=z');
    model_file = cat(1, model_file, ['   cutat= (',modelling_inputs.subsections{ndfd}.zmax, ') - (', modelling_inputs.subsections{ndfd}.zmin, ')']);
    model_file = cat(1, model_file, eyepos.twodzeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ./', geom_prefix, '2Dsub',num2str(ndfd),'_cutplot_z.ps -colorps']);
    model_file = cat(1, model_file, 'doit');
end %for
