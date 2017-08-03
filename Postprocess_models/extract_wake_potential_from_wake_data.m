function [timebase, wp] = extract_wake_potential_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
timebase = wake_data.time_domain_data.timebase * 1E9; % ns
wp = wake_data.time_domain_data.wakepotential * 1E-12; % mV/pC