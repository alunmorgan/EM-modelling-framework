function [bs] = extract_bunch_spectrum_from_wake_data(wake_data, cut_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
bs = wake_data.frequency_domain_data.bunch_spectra(1:cut_ind);