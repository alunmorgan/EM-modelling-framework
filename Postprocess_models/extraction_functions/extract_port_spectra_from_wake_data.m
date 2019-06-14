function [frequency_scale, beam_port_spectrum, signal_port_spectrum,...
    port_energy_spectra] = extract_port_spectra_from_wake_data(...
    pp_data, wake_data, cut_ind, lab_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
frequency_scale = wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9; % GHz
signal_port_spectrum = wake_data.frequency_domain_data.signal_port_spectrum(1:cut_ind)*1e9; %nJ
beam_port_spectrum = wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind)*1e9; %nJ

for ns = 1:length(lab_ind)
    port_energy_spectra{ns} = wake_data.frequency_domain_data.raw_port_energy_spectrum(1:cut_ind,lab_ind(ns))*1e9; %nJ
end %for