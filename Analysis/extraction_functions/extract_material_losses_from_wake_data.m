function [model_mat_data, mat_loss, m_time, m_data] = ...
    extract_material_losses_from_wake_data(pp_data, extension_names)
% wake data (structure): contains all the data from the wake postprocessing
%
% mat_loss (vector): Returns a value of total loss per material.
%
% Example: mat_loss = extract_material_losses_from_wake_data(wake_data)

if isfield(pp_data, 'mat_losses') && iscell(pp_data.mat_losses.single_mat_data)
    % I think that if the only material is PEC then this returns a 0 rather
    % than a cell. In which case don't do the interpolation.
    % TODO find the code which generates the zeros and change so that the
    % output type is constant.
    if ~isempty(pp_data.mat_losses.loss_time)

        for hsa = size(pp_data.mat_losses.single_mat_data,1):-1:1
            if isempty(extension_names)
                model_mat_index(hsa) = 1;
            else
                tmp = strcmp(extension_names, pp_data.mat_losses.single_mat_data{hsa,2});
                if sum(tmp) == 0
                    % material is part of the model.
                    model_mat_index(hsa) = 1;
                else
                    % material is part of the port extensions.
                    model_mat_index(hsa) = 0;
                end %if
            end %if
        end %for

        %select on only those materials which are in the model proper.
        model_mat_data = pp_data.mat_losses.single_mat_data(model_mat_index == 1,:);
        if ~isempty(model_mat_data)
            for mes = size(model_mat_data,1):-1:1
                mat_loss(mes) = model_mat_data{mes,4}(end,2);
            end %for
        end %if
    end %if
else
    model_mat_data =NaN;
    mat_loss = NaN;
end %if

% Evolution over time
if isfield(pp_data, 'mat_losses') && iscell(pp_data.mat_losses.single_mat_data)
    if isempty(pp_data.mat_losses.loss_time) == 0
        for na = size(model_mat_data,1):-1:1
            if isempty(model_mat_data{na,4})
                m_time{na} = 0;
                m_data{na} = 0;
            else
                m_time{na} = model_mat_data{na,4}(:,1).*1e9;
                m_data{na} = model_mat_data{na,4}(:,2).* 1e9;
            end %if
        end %for
    end %if
else
    m_time = {NaN};
    m_data = {NaN};
end %if