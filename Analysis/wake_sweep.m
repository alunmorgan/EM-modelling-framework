function wake_sweep_data = wake_sweep(sweep_lengths, raw_data, ppi, log, port_modes_override)
% Run the frequency domain analysis over data which is increasingly reduced
% in length (i.e. having different wake lengths).
%
% Example: wake_sweeps = wake_sweep(time_domain_data, port_data)

%% pad to 1 revolution length
% rev_time = (1/ppi.RF_freq) * 936; %time of 1 revolution
rev_time = (1/ppi.RF_freq) * 50; %time of 10 bunches %TEMP DUE TO MEMORY LIMITS

r_raw = rearrange_input_structure(raw_data);

for se = length(sweep_lengths):-1:1
    r_data{se} = r_raw;
    r_names = fieldnames(r_data{se}.time_series_data);
    starttime =  find_earliest_start(r_data{se}.time_series_data);
    timestep =  find_smallest_timestep(r_data{se}.time_series_data);
    r_data{se}.time_series_data.timescale_common = linspace(starttime, rev_time,(rev_time - starttime)/timestep + 1)';
    for ple =  1:length(r_names)
        if strcmp(r_names{ple}, 'port_data')
            substructure = fieldnames(r_data{se}.time_series_data.port_data.data.time);
            for whs = 1:length(substructure)
                r_data{se}.time_series_data.port_data.data.time.(substructure{whs}).data =...
                    condition_port_timeseries(...
                    r_data{se}.time_series_data.port_data.data.time.(substructure{whs}).data,...
                    r_data{se}.time_series_data.port_data.timebase',...
                    sweep_lengths(se), starttime, rev_time, timestep); %W
                if isfield(r_data{se}.time_series_data.port_data.data.time.(substructure{whs}), 'bunch_signal')
                    r_data{se}.time_series_data.port_data.data.time.(substructure{whs}).bunch_signal =...
                        condition_port_timeseries(...
                        r_data{se}.time_series_data.port_data.data.time.(substructure{whs}).bunch_signal,...
                        r_data{se}.time_series_data.port_data.timebase',...
                        sweep_lengths(se), starttime, rev_time, timestep); %W
                end %if
                if isfield(r_data{se}.time_series_data.port_data.data.time.(substructure{whs}), 'remnant_signal')
                    r_data{se}.time_series_data.port_data.data.time.(substructure{whs}).remnant_signal =...
                        condition_port_timeseries(...
                        r_data{se}.time_series_data.port_data.data.time.(substructure{whs}).remnant_signal,...
                        r_data{se}.time_series_data.port_data.timebase',...
                        sweep_lengths(se), starttime, rev_time, timestep); %W
                end %if
            end %for
            r_raw.time_series_data.port_data = rmfield(r_raw.time_series_data.port_data,'timebase');
        else
            temp_data = r_data{se}.time_series_data.(r_names{ple});
            r_data{se}.time_series_data.(r_names{ple}) = ...
                condition_timeseries(temp_data, sweep_lengths(se), starttime, rev_time, timestep);
        end %if
    end %for
    r_data{se}.wake_setup.Wake_length = sweep_lengths(se);
    
    %% Time domain analysis
    t_data{se} = time_domain_analysis(r_data{se}, log, port_modes_override);
    %% Frequency domain analysis
        f_data{se} = frequency_domain_analysis(t_data{se},r_data{se}.time_series_data.port_data.data.frequency.power_port.data, log, ppi.hfoi);
    %% Material loss
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
        end %for
    else
        m_data{se} = NaN;
    end %if
%     %% Generating data for time slices
%     f_data{se}.time_slices = time_slices(t_data{se}.timebase, ...
%         t_data{se}.wakepotential, ppi.hfoi);
%     %% Calculating the losses for different bunch lengths
%     f_data{se}.extrap_data.beam_sigma_sweep = variation_with_beam_sigma(ppi.bunch_lengths, t_data{se}.timebase, ...
%         f_data{se}.Wake_Impedance_data, log.charge, f_data{se}.port_impedances, f_data{se}.port_fft);
%     
%     %% and bunch charges.
%     f_data{se}.extrap_data.diff_machine_conds = loss_extrapolation(t_data{se}.timebase, f_data{se}, ppi);
end %for

% wake_sweep_data.raw = r_data;
wake_sweep_data.frequency_domain_data = f_data;
wake_sweep_data.time_domain_data = t_data;
wake_sweep_data.mat_losses = m_data;
end %function

function port_data_out = condition_port_timeseries(temp_data, original_timebase, data_length, starttime, rev_time, timestep)
for bsw =1:size(temp_data,2)
    if all(temp_data{bsw} == 0)
        port_data_out{bsw}(:,1) = condition_timeseries(NaN, data_length, starttime, rev_time, timestep);
        clear port_mode_temp
    else
        %  There is at least one transmitting mode.
        for wda =1:size(temp_data{bsw},2)
            port_mode_temp = cat(2, original_timebase, temp_data{bsw}(:,wda));
            port_data_out{bsw}(:,wda) = ...
                condition_timeseries(port_mode_temp, data_length, starttime, rev_time, timestep);
            clear port_mode_temp
        end %for
    end %if
end %for
end %function

function r_raw = rearrange_input_structure(raw_data)
% rearranging the raw data structure into a form which is more useful for
% later analysis and plotting.
r_raw.time_series_data.Energy = raw_data.Energy.data;
r_raw.time_series_data.Charge_distribution = raw_data.Charge_distribution.data;
r_raw.time_series_data.Wake_potential = raw_data.Wake_potential.s.data;
r_raw.time_series_data.Wake_potential_trans_X = raw_data.Wake_potential.x.data;
r_raw.time_series_data.Wake_potential_trans_Y = raw_data.Wake_potential.y.data;
r_raw.time_series_data.port_data = raw_data.port; %W
r_raw.frequency_series_data.Wake_impedance = raw_data.Wake_impedance.s.data;
r_raw.frequency_series_data.Wake_impedance_trans_X = raw_data.Wake_impedance.x.data;
r_raw.frequency_series_data.Wake_impedance_trans_Y = raw_data.Wake_impedance.y.data;
r_raw.wake_setup = raw_data.wake_setup;
if isfield(raw_data, 'mat_losses')
    % if the model is PEC only then this will not exist.
    r_raw.mat_losses = raw_data.mat_losses;
end %if
end %function
