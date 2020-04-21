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

