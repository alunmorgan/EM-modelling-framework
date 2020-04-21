function [m_time, m_data] = extract_mat_losses_from_wake_data(wake_data, model_mat_data)

if isfield(wake_data.raw_data, 'mat_losses')
    if isempty(wake_data.raw_data.mat_losses.loss_time) == 0
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
    m_time = NaN;
    m_data = NaN;
end %if