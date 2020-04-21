function wake_sweep_data = wake_sweep(sweep_lengths, raw_data, mi, ppi, log, port_modes_override)
% Run the frequency domain analysis over data which is increasingly reduced
% in length (i.e. having different wake lengths).
%
% Example: wake_sweeps = wake_sweep(time_domain_data, port_data)

% dsd = length(time_domain_data.timebase);
% Set the number of wake lengths to do.
%% pad to 1 revolution length
rev = ppi.RF_freq/936;
gap = 1/ppi.RF_freq;
% rev_time = (1/ppi.RF_freq) * 936; %time of 1 revolution
rev_time = (1/ppi.RF_freq) * 50; %time of 10 bunches %TEMP DUE TO MEMORY LIMITS
% raw_port_data = put_on_reference_timebase(time_domain_data.timebase, raw_data.port);
r_raw.time_series_data.Energy = raw_data.Energy;
r_raw.time_series_data.Charge_distribution = raw_data.Charge_distribution;
r_raw.time_series_data.Wake_potential = raw_data.Wake_potential;
r_raw.time_series_data.Wake_potential_trans_quad_X = raw_data.Wake_potential_trans_quad_X;
r_raw.time_series_data.Wake_potential_trans_quad_Y = raw_data.Wake_potential_trans_quad_Y;
r_raw.time_series_data.Wake_potential_trans_dipole_X = raw_data.Wake_potential_trans_dipole_X;
r_raw.time_series_data.Wake_potential_trans_dipole_Y = raw_data.Wake_potential_trans_dipole_Y;
r_raw.time_series_data.port_data = raw_data.port.data;
r_raw.time_series_data.port_data_all = raw_data.port.data_all;
r_raw.frequency_series_data.Wake_impedance = raw_data.Wake_impedance;
r_raw.frequency_series_data.Wake_impedance_trans_quad_X = raw_data.Wake_impedance_trans_quad_X;
r_raw.frequency_series_data.Wake_impedance_trans_quad_Y = raw_data.Wake_impedance_trans_quad_Y;
r_raw.frequency_series_data.Wake_impedance_trans_dipole_X = raw_data.Wake_impedance_trans_dipole_X;
r_raw.frequency_series_data.Wake_impedance_trans_dipole_Y = raw_data.Wake_impedance_trans_dipole_Y;
r_raw.wake_setup = raw_data.wake_setup;
if isfield(raw_data, 'mat_losses')
    % if the model is PEC only then this will not exist.
    r_raw.mat_losses = raw_data.mat_losses;
end %if
    r_raw.port.labels = raw_data.port.labels;
r_raw.port.labels_table = raw_data.port.labels_table;
r_raw.port.frequency_cutoffs = raw_data.port.frequency_cutoffs;
r_raw.port.frequency_cutoffs_all = raw_data.port.frequency_cutoffs_all;
r_raw.port.alpha = raw_data.port.alpha;
r_raw.port.beta = raw_data.port.beta;
r_raw.port.t_start = raw_data.port.t_start;

for se = length(sweep_lengths):-1:1
    
    
%     trimed_ports = find(raw_data.port.timebase(:,1) <= (sweep_lengths(se) / 3E8), 1, 'last');
%     if isempty(trimed)
%         warning(['Sweep length ', num2str(sweep_lengths(se)) ,' not found.'])
%         continue
%     end %if
    %     trimed = round((dsd/n_points)*se);
    % Construct a replacement structure containing the truncated datasets.
    r_data{se} = r_raw;
    r_names = fieldnames(r_data{se}.time_series_data);
    % only want time domain data.
%     r_names(find_position_in_cell_lst(strfind(r_names,'impedance'))) = [];
    %find the timebase with the smallest time step.
    starttime =  find_earliest_start(r_data{se}.time_series_data);
    timestep =  find_smallest_timestep(r_data{se}.time_series_data);
    r_data{se}.time_series_data.timescale_common = linspace(starttime, rev_time,(rev_time - starttime)/timestep + 1)';
    for ple =  1:length(r_names)
        temp_data = r_data{se}.time_series_data.(r_names{ple});
        if iscell(temp_data)
            for bsw =1:size(temp_data,2)
                for wda =1:size(temp_data{bsw},2)
                    tmp_cell(:,wda) = condition_timeseries(...
                        cat(2, raw_data.port.timebase, temp_data{bsw}(:,wda)), ...
                        sweep_lengths(se), starttime, rev_time, timestep);
                end %for
                r_data{se}.time_series_data.(r_names{ple}){bsw} = tmp_cell;
            end %for
        else
            r_data{se}.time_series_data.(r_names{ple}) = ...
                condition_timeseries(temp_data, sweep_lengths(se), starttime, rev_time, timestep);
        end %if
    end %for
    
%     r_data{se}.Wake_potential = r_data{se}.Wake_potential(1:trimmed,:);
%     r_data{se}.Wake_potential_trans_quad_X = r_data{se}.Wake_potential_trans_quad_X(1:trimmed,:);
%     r_data{se}.Wake_potential_trans_quad_Y = r_data{se}.Wake_potential_trans_quad_Y(1:trimmed,:);
%     r_data{se}.Wake_potential_trans_dipole_X = r_data{se}.Wake_potential_trans_dipole_X(1:trimmed,:);
%     r_data{se}.Wake_potential_trans_dipole_Y = r_data{se}.Wake_potential_trans_dipole_Y(1:trimmed,:);
%     r_data{se}.port.timebase = r_data{se}.port.timebase(1:trimed_ports, :);
%     for pda = length(r_data{se}.port.data_all):-1:1
%         r_data{se}.port.data_all{1,pda} = r_data{se}.port.data_all{1,pda}(1:trimed_ports,:);
%     end %for
%     for pd = length(r_data{se}.port.data):-1:1
%         r_data{se}.port.data{1,pd} = r_data{se}.port.data{1,pd}(1:trimed_ports, :);
%     end %for
    r_data{se}.wake_setup.Wake_length = sweep_lengths(se);
    %     t_data{se}.timebase = time_domain_data.timebase(1:trimed);
    %     t_data{se}.wakepotential = time_domain_data.wakepotential(1:trimed);
    %     t_data{se}.wakepotential_trans_quad_x = time_domain_data.wakepotential_trans_quad_x(1:trimed);
    %     t_data{se}.wakepotential_trans_quad_y = time_domain_data.wakepotential_trans_quad_y(1:trimed);
    %     t_data{se}.wakepotential_trans_dipole_x = time_domain_data.wakepotential_trans_dipole_x(1:trimed);
    %     t_data{se}.wakepotential_trans_dipole_y = time_domain_data.wakepotential_trans_dipole_y(1:trimed);
    %     t_data{se}.charge_distribution = time_domain_data.charge_distribution(1:trimed);
    %     pt_data{se}.timebase = time_domain_data.timebase(1:trimed);
    %% set to common timebase
    
    
%     % Pad the time domain data to one revolution length.
%     
%     
%     if iscell(raw_port_data)
%         [ ~, port_data_bc] = ...
%             pad_data(time_domain_data.timebase, rev_time, 'time', raw_port_data);
%     else
%         port_data_bc = NaN;
%     end %if
    %% Time domain analysis
    t_data{se} = time_domain_analysis(r_data{se}, log, port_modes_override);
    %% Frequency domain analysis
    if isfield(t_data{1, se}, 'port_data')
        % Run the frequency analysis.
        f_data{se} = frequency_domain_analysis(...
            r_data{se}.port.frequency_cutoffs, ...
            t_data{se},...
            r_data{se}.time_series_data.port_data,...
            log, ppi.hfoi);
    else
        % Run the frequency analysis.
        f_data{se} = frequency_domain_analysis(...
            NaN, t_data{se}, NaN, log, ppi.hfoi);
    end %if
%     f_data{se}.Wake_length = round(r_data{se}.Wake_potential(end,1)*3e8, 2);
    % Material loss
    if isfield(r_raw, 'mat_losses')
        mt_ind = find(r_raw.mat_losses.loss_time < t_data{se}.timebase(end), 1, 'last');
        m_data{se}.loss_time = r_raw.mat_losses.loss_time(1:mt_ind);
        m_data{se}.total_loss = r_raw.mat_losses.total_loss(1:mt_ind);
        m_data{se}.single_mat_data = r_raw.mat_losses.single_mat_data;
        for shw = 1:size(m_data{se}.single_mat_data,1)
            m_data{se}.single_mat_data{shw, 4} =  interp1(...
                m_data{se}.single_mat_data{shw, 4}(:,1),...
                m_data{se}.single_mat_data{shw, 4}(:,2),...
                m_data{se}.loss_time);
%             m_data{se}.single_mat_data{shw, 4}(1:mt_ind,:);
        end %for
    else
        m_data{se} = NaN;
    end %if
    %% Generating data for time slices
    f_data{se}.time_slices = time_slices(t_data{se}.timebase, ...
        t_data{se}.wakepotential, ppi.hfoi);
    %% Calculating the losses for different bunch lengths
    f_data{se}.extrap_data.beam_sigma_sweep = variation_with_beam_sigma(mi.beam_sigma, t_data{se}.timebase, ...
    f_data{se}.Wake_Impedance_data, log.charge, f_data{se}.port_impedances, f_data{se}.port_fft);
    
%%    and bunch charges.
    f_data{se}.extrap_data.diff_machine_conds = loss_extrapolation(t_data{se}.timebase, f_data{se}, ppi);
end %for

wake_sweep_data.raw = r_data;
wake_sweep_data.frequency_domain_data = f_data;
wake_sweep_data.time_domain_data = t_data;
wake_sweep_data.mat_losses = m_data;