function model_file = create_3D_volume_plots(modelling_inputs, eyepos, geom_prefix, out_loc)
model_file = {'-volumeplot'};
model_file = cat(1, model_file, eyepos.threedxeyepos);
model_file = cat(1, model_file, '   scale=3.5');
model_file = cat(1, model_file,['    plotopts = -o ' fullfile(out_loc, [geom_prefix, '3Dmodel.ps -colorps'])]);
model_file = cat(1, model_file, 'doit');

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
    model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '3Dmodel_cut_',modelling_inputs.cuts{ndw, 1},'_user',num2str(count3d),'.ps']),' -colorps']);
    model_file = cat(1, model_file, 'doit');
end %for
