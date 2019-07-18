function wake_sweep_data = wake_sweep(sweep_lengths, raw_data, mi, ppi, log, hfoi_override)
% Run the frequency domain analysis over data which is increasingly reduced
% in length (i.e. having different wake lengths).
%
% Example: wake_sweeps = wake_sweep(time_domain_data, port_data)

% dsd = length(time_domain_data.timebase);
% Set the number of wake lengths to do.

if nargin == 6
    hfoi = hfoi_override;
else
    hfoi = ppi.hfoi;
end %if

% raw_port_data = put_on_reference_timebase(time_domain_data.timebase, raw_data.port);
for se = length(sweep_lengths):-1:1
    % find the data length required.
    trimed = find(raw_data.Wake_potential(:,1) <= (sweep_lengths(se) / 3E8), 1, 'last');
    trimed_ports = find(raw_data.port.timebase(:,1) <= (sweep_lengths(se) / 3E8), 1, 'last');
    if isempty(trimed)
        warning(['Sweep length ', num2str(sweep_lengths(se)) ,' not found.'])
        continue
    end %if
    %     trimed = round((dsd/n_points)*se);
    % Construct a replacement structure containing the truncated datasets.
    r_data{se} = raw_data;
    r_data{se}.Wake_potential = r_data{se}.Wake_potential(1:trimed,:);
    r_data{se}.Wake_potential_trans_quad_X = r_data{se}.Wake_potential_trans_quad_X(1:trimed,:);
    r_data{se}.Wake_potential_trans_quad_Y = r_data{se}.Wake_potential_trans_quad_Y(1:trimed,:);
    r_data{se}.Wake_potential_trans_dipole_X = r_data{se}.Wake_potential_trans_dipole_X(1:trimed,:);
    r_data{se}.Wake_potential_trans_dipole_Y = r_data{se}.Wake_potential_trans_dipole_Y(1:trimed,:);
    r_data{se}.port.timebase = r_data{se}.port.timebase(1:trimed_ports, :);
    for pda = length(r_data{se}.port.data_all):-1:1
        r_data{se}.port.data_all{1,pda} = r_data{se}.port.data_all{1,pda}(1:trimed_ports,:);
    end %for
    for pd = length(r_data{se}.port.data):-1:1
        r_data{se}.port.data{1,pd} = r_data{se}.port.data{1,pd}(1:trimed_ports, :);
    end %for
    r_data{se}.wake_setup.Wake_length = sweep_lengths(se);
    %     t_data{se}.timebase = time_domain_data.timebase(1:trimed);
    %     t_data{se}.wakepotential = time_domain_data.wakepotential(1:trimed);
    %     t_data{se}.wakepotential_trans_quad_x = time_domain_data.wakepotential_trans_quad_x(1:trimed);
    %     t_data{se}.wakepotential_trans_quad_y = time_domain_data.wakepotential_trans_quad_y(1:trimed);
    %     t_data{se}.wakepotential_trans_dipole_x = time_domain_data.wakepotential_trans_dipole_x(1:trimed);
    %     t_data{se}.wakepotential_trans_dipole_y = time_domain_data.wakepotential_trans_dipole_y(1:trimed);
    %     t_data{se}.charge_distribution = time_domain_data.charge_distribution(1:trimed);
    %     pt_data{se}.timebase = time_domain_data.timebase(1:trimed);
    %% Time domain analysis
    [t_data{se}, pt_data{se}] = time_domain_analysis(r_data{se}, log, ppi.port_modes_override);
    if isfield(raw_data.port, 'data')
        % Run the frequency analysis.
        f_data{se} = frequency_domain_analysis(...
            r_data{se}.port.frequency_cutoffs, ...
            t_data{se},...
            r_data{se}.port,...
            log, hfoi);
    else
        % Run the frequency analysis.
        f_data{se} = frequency_domain_analysis(...
            NaN, t_data{se}, NaN, log, hfoi);
    end %if
    f_data{se}.Wake_length = round(r_data{se}.Wake_potential(end,1)*3e8, 2);
    % Material loss
    if isfield(raw_data, 'mat_losses')
        mt_ind = find(raw_data.mat_losses.loss_time < t_data{se}.timebase(end), 1, 'last');
        m_data{se}.loss_time = raw_data.mat_losses.loss_time(1:mt_ind);
        m_data{se}.total_loss = raw_data.mat_losses.total_loss(1:mt_ind);
        m_data{se}.single_mat_data = raw_data.mat_losses.single_mat_data;
        for shw = 1:size(m_data{se}.single_mat_data,1)
            m_data{se}.single_mat_data{shw, 4} =  m_data{se}.single_mat_data{shw, 4}(1:mt_ind,:);
        end %for
    else
        m_data{se} = NaN;
    end %if
    %% Generating data for time slices
    f_data{se}.time_slices = time_slices(t_data{se}, hfoi);
    %% Calculating the losses for different bunch lengths and bunch charges.
    f_data{se}.extrap_data = loss_extrapolation(...
    t_data{se}, pt_data{se}, mi, ppi, raw_data, log);
end %for

wake_sweep_data.raw = r_data;
wake_sweep_data.frequency_domain_data = f_data;
wake_sweep_data.time_domain_data = t_data;
wake_sweep_data.port_time_data = pt_data;
wake_sweep_data.mat_losses = m_data;