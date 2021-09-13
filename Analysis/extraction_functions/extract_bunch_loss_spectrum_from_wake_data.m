function [bls] = extract_bunch_loss_spectrum_from_wake_data(wake_data, cut_freq_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
bls = wake_data.frequency_domain_data.Bunch_loss_energy_spectrum(1:cut_freq_ind) *1e9;