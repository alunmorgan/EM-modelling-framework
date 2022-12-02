function model_file = create_2D_geometry_plots(modelling_inputs, eyepos, geom_prefix, out_loc)
model_file = {'-volumeplot'};

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
        model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '2Dmodel_cut_', modelling_inputs.cuts{ndw, 1},'_user',num2str(x_count),'.ps']), ' -colorps']);
        model_file = cat(1, model_file, 'doit');
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'y')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbylow=', modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, ['   bbyhigh=', modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodyeyepos);
        y_count = y_count +1;
        model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '2Dmodel_cut_', modelling_inputs.cuts{ndw, 1},'_user', num2str(y_count),'.ps']), ' -colorps']);
        model_file = cat(1, model_file, 'doit');
    elseif strcmp(modelling_inputs.cuts{ndw, 1},'z')
        model_file = reset_bounding_box(model_file);
        model_file = cat(1, model_file, ['   bbzlow=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, ['   bbzhigh=',modelling_inputs.cuts{ndw, 2}]);
        model_file = cat(1, model_file, eyepos.twodzeyepos);
        z_count = z_count +1;
        model_file = cat(1, model_file, ['   plotopts = -o ', fullfile(out_loc, [geom_prefix, '2Dmodel_cut_',modelling_inputs.cuts{ndw, 1},'_user',num2str(z_count),'.ps']), ' -colorps']);
        model_file = cat(1, model_file, 'doit');
    end %if
end %for
model_file = reset_bounding_box(model_file);
