function [port_time_data, time_domain_data, frequency_domain_data,...
    wake_sweep_data]= wake_analysis(raw_data, ppi, mi, log)
% Takes the model generated data and processes it in order to get an 
%idea where the power/heat is going.
%
% example:
%
% [port_time_data, time_domain_data, frequency_domain_data,...
%     beam_data]= wake_analysis(raw_data, ppi, logs)
%

%% Time domain analysis
[time_domain_data, port_time_data] = time_domain_analysis(raw_data, log, ppi.port_modes_override);

%% Frequency domain analysis.
% As this is a linear system power cannot be moved between frequencies.
% Therefore if we account for the power in the frequency domain then
% each frequency can be treated separately.

% calculate the wake impedence and the frequency distribution of the bunch.
if isfield(raw_data.port, 'data') && ~isempty(raw_data.port.data)
    frequency_domain_data = frequency_domain_analysis(...
        raw_data.port.frequency_cutoffs, ...
        time_domain_data,...
        port_time_data,...
        log, ppi.hfoi);
else
    frequency_domain_data = frequency_domain_analysis(...
        NaN, time_domain_data, NaN, log, ppi.hfoi);
end

%% Generating data for time slices
frequency_domain_data.time_slices = time_slices(time_domain_data, ppi.hfoi);

%% Calculating the losses for different bunch lengths and bunch charges.
frequency_domain_data.extrap_data = loss_extrapolation(...
    time_domain_data,...
    port_time_data,...
    mi,...
    ppi,...
    raw_data, log);

%% Generating data for increasingly short wakes
wake_sweep_data = wake_sweep(time_domain_data, port_time_data, raw_data, ppi.hfoi, log);
