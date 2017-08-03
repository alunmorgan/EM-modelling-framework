function [frequency_scale, bs] = extract_bunch_spectrum_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
frequency_scale = wake_data.frequency_domain_data.f_raw*1E-9; %ns
bs = wake_data.frequency_domain_data.bunch_spectra;