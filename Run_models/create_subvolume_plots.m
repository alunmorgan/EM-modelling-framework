function model_file = create_subvolume_plots(modelling_inputs, eyepos, geom_prefix, out_loc)
model_file = {'-volumeplot'};

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
    model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '2Dsub',num2str(ndfd),'_cut_x_.ps']), ' -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, ['   bbxhigh=', modelling_inputs.subsections{ndfd}.xmax]);
    model_file = cat(1, model_file, ['   bbxlow=', modelling_inputs.subsections{ndfd}.xmin]);
    model_file = cat(1, model_file, ['   bbyhigh=', y_centre]);
    model_file = cat(1, model_file, ['   bbylow=', y_centre]);
    model_file = cat(1, model_file, eyepos.twodyeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '2Dsub',num2str(ndfd),'_cut_y_.ps']), ' -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, ['   bbyhigh=', modelling_inputs.subsections{ndfd}.ymax]);
    model_file = cat(1, model_file, ['   bbylow=', modelling_inputs.subsections{ndfd}.ymin]);
    model_file = cat(1, model_file, ['   bbzhigh=', z_centre]);
    model_file = cat(1, model_file, ['   bbzlow=', z_centre]);
    model_file = cat(1, model_file, eyepos.twodzeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '2Dsub',num2str(ndfd),'_cut_z_.ps']), ' -colorps']);
    model_file = cat(1, model_file, 'doit');
    model_file = cat(1, model_file, ['   bbzhigh=', modelling_inputs.subsections{ndfd}.zmax]);
    model_file = cat(1, model_file, ['   bbzlow=', modelling_inputs.subsections{ndfd}.zmin]);
    model_file = cat(1, model_file, eyepos.threedxeyepos);
    model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '3Dsub',num2str(ndfd),'.ps']), ' -colorps']);
    model_file = cat(1, model_file, 'doit');
end %for
model_file = reset_bounding_box(model_file);
