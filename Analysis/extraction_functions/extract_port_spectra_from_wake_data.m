function [beam_port_spectrum, signal_port_spectrum,...
    port_spectra] = extract_port_spectra_from_wake_data(...
    wake_data, cut_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
signal_port_spectrum = wake_data.frequency_domain_data.signal_port_spectrum(1:cut_ind)*1e9; %nJ
beam_port_spectrum = wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind)*1e9; %nJ
port_spectra = wake_data.frequency_domain_data.port_specatra(:,1:cut_ind)*1e9; %nJ
