function model_file = create_geometry_plots(modelling_inputs)
% Write the geometry plotting part of the gdf file.

model_file = {'###################################################'};
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