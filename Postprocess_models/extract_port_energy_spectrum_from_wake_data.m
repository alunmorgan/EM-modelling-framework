function [timebase, pes] = extract_port_energy_spectrum_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
timebase = wake_data.frequency_domain_data.f_raw*1E-9;
pes = wake_data.frequency_domain_data.Total_port_spectrum * 1e9;