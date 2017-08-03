function [model_mat_data, mat_loss] = extract_material_losses_from_wake_data(wake_data, extension_names)
% wake data (structure): contains all the data from the wake postprocessing
%
% mat_loss (vector): Returns a value of total loss per material.
%
% Example: mat_loss = extract_material_losses_from_wake_data(wake_data)

if isfield(wake_data.raw_data, 'mat_losses')
    if ~isempty(wake_data.raw_data.mat_losses.loss_time)
        for hsa = size(wake_data.raw_data.mat_losses.single_mat_data,1):-1:1
            tmp = strcmp(extension_names, wake_data.raw_data.mat_losses.single_mat_data{hsa,2});
            if sum(tmp) == 0
                % material is part of the model.
                model_mat_index(hsa) = 1;
            else
                % material is part of the port extensions.
                model_mat_index(hsa) = 0;
            end %if
        end %for
        %select on only those materials which are in the model proper.
        model_mat_data = wake_data.raw_data.mat_losses.single_mat_data(model_mat_index == 1,:);
        if ~isempty(model_mat_data)
            for mes = size(model_mat_data,1):-1:1;
                mat_loss(mes) = model_mat_data{mes,4}(end,2);
            end %for    
        end %if
    end %if
end %if