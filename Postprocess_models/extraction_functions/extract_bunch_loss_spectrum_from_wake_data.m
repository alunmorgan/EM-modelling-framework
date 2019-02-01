function [frequency_scale, bls] = extract_bunch_loss_spectrum_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
frequency_scale = wake_data.frequency_domain_data.f_raw*1E-9;
bls = wake_data.frequency_domain_data.Bunch_loss_energy_spectrum *1e9;