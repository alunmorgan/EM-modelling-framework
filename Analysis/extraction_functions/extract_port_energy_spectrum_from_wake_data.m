function pes = extract_port_energy_spectrum_from_wake_data(wake_data, cut_freq_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
pes = wake_data.frequency_domain_data.Total_port_spectrum(1:cut_freq_ind) .* 1e9; %nJ