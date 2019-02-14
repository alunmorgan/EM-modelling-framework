function wake_sweep_data = wake_sweep(time_domain_data, port_data, raw_data, hfoi, log)
% Run the frequency domain analysis over data which is increasingly reduced
% in length (i.e. having different wake lengths).
%
% Example: wake_sweeps = wake_sweep(time_domain_data, port_data)

dsd = length(time_domain_data.timebase);
% Set the number of wake lengths to do.

raw_port_data = put_on_reference_timebase(time_domain_data.timebase, port_data);
n_points = 20;
for se = n_points:-1:1
    % find the data length required.
    trimed = round((dsd/n_points)*se);
    % Construct a replacement structure containing the truncated datasets.
    t_data{se}.timebase = time_domain_data.timebase(1:trimed);
    t_data{se}.wakepotential = time_domain_data.wakepotential(1:trimed);
    t_data{se}.wakepotential_trans_quad_x = time_domain_data.wakepotential_trans_quad_x(1:trimed);
    t_data{se}.wakepotential_trans_quad_y = time_domain_data.wakepotential_trans_quad_y(1:trimed);
    t_data{se}.wakepotential_trans_dipole_x = time_domain_data.wakepotential_trans_dipole_x(1:trimed);
    t_data{se}.wakepotential_trans_dipole_y = time_domain_data.wakepotential_trans_dipole_y(1:trimed);
    t_data{se}.charge_distribution = time_domain_data.charge_distribution(1:trimed);
    pt_data{se}.timebase = time_domain_data.timebase(1:trimed);
    if isfield(port_data, 'data')
        for nr = 1:length(port_data.data)
            pt_data{se}.data{nr} = raw_port_data{nr}(1:trimed,:);
        end %for
        % Run the frequency analysis.
        f_data{se} = frequency_domain_analysis(...
            raw_data.port.frequency_cutoffs, ...
            t_data{se},...
            pt_data{se},...
            log, hfoi);
    else
        % Run the frequency analysis.
        f_data{se} = frequency_domain_analysis(...
            NaN, t_data{se}, NaN, log, hfoi);
    end %if
    f_data{se}.Wake_length = ...
        raw_data.wake_setup.Wake_length / n_points * se;
    % Material loss
    mt_ind = find(raw_data.mat_losses.loss_time < t_data{se}.timebase(end), 1, 'last');
    m_data{se}.loss_time = raw_data.mat_losses.loss_time(1:mt_ind);
    m_data{se}.total_loss = raw_data.mat_losses.total_loss(1:mt_ind);
    m_data{se}.single_mat_data = raw_data.mat_losses.single_mat_data;
    for shw = 1:size(m_data{se}.single_mat_data,1)
        m_data{se}.single_mat_data{shw, 4} =  m_data{se}.single_mat_data{shw, 4}(1:mt_ind,:);
    end %for
end %for

wake_sweep_data.frequency_domain_data = f_data;
wake_sweep_data.time_domain_data = t_data;
wake_sweep_data.port_time_data = pt_data;
wake_sweep_data.mat_losses = m_data;