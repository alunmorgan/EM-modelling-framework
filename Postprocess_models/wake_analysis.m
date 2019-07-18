function wake_sweep_data = wake_analysis(raw_data, ppi, mi, log, wake_sweep_vals)
% Takes the model generated data and processes it in order to get an 
%idea where the power/heat is going.
%
% example:
%
% [port_time_data, time_domain_data, frequency_domain_data,...
%     beam_data]= wake_analysis(raw_data, ppi, logs)
%

% %% Time domain analysis
% [time_domain_data, port_time_data] = time_domain_analysis(raw_data, log, ppi.port_modes_override);

% %% Frequency domain analysis.
% % As this is a linear system power cannot be moved between frequencies.
% % Therefore if we account for the power in the frequency domain then
% % each frequency can be treated separately.
% 
% % calculate the wake impedence and the frequency distribution of the bunch.
% if isfield(raw_data.port, 'data') && ~isempty(raw_data.port.data)
%     frequency_domain_data = frequency_domain_analysis(...
%         raw_data.port.frequency_cutoffs, ...
%         time_domain_data,...
%         raw_data.port,...
%         log, ppi.hfoi);
% else
%     frequency_domain_data = frequency_domain_analysis(...
%         NaN, time_domain_data, NaN, log, ppi.hfoi);
% end

%% Generating data for increasingly short wakes
wake_sweep_data = wake_sweep(wake_sweep_vals, raw_data, mi, ppi, log);
% [120, 80, 60, 40, 20]
% chosen_wake_length_ind = 1;
chosen_wake_ind = find(wake_sweep_vals == str2double(chosen_wake_length));
if isempty(chosen_wake_ind)
    chosen_wake_ind = find(wake_sweep_vals == max(wake_sweep_vals));
    warning('Chosen wake length too long. Setting the wakelength to maximum value.')
end %if
wake_data.port_time_data = wake_sweep_data.port_time_data{chosen_wake_ind};
wake_data.time_domain_data = wake_sweep_data.time_domain_data{chosen_wake_ind};
wake_data.frequency_domain_data = wake_sweep_data.frequency_domain_data{chosen_wake_ind};
wake_data.wake_sweep_data = wake_sweep_data;

% wake_data.port_time_data = port_time_data;
% wake_data.time_domain_data = time_domain_data;
% wake_data.frequency_domain_data = frequency_domain_data;
% wake_data.wake_sweep_data = wake_sweep_data;

%% Generating data for time slices
wake_data.frequency_domain_data.time_slices = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.time_slices;
% wake_data.frequency_domain_data.time_slices = time_slices(wake_data.time_domain_data, ppi.hfoi);

%% Calculating the losses for different bunch lengths and bunch charges.
wake_data.frequency_domain_data.extrap_data = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.extrap_data;
% wake_data.frequency_domain_data.extrap_data = loss_extrapolation(...
%     wake_data.time_domain_data,...
%     wake_data.port_time_data,...
%     mi,...
%     ppi,...
%     raw_data, log);