function [frequency_scale, beam_port_spectrum, signal_port_spectrum,...
    port_energy_spectra] = extract_port_spectra_from_wake_data(...
    pp_data, wake_data, cut_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
frequency_scale = wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9; % GHz
if ~isnan(wake_data.frequency_domain_data.signal_port_spectrum)
    signal_port_spectrum = wake_data.frequency_domain_data.signal_port_spectrum(1:cut_ind)*1e9; %nJ
else
    signal_port_spectrum = NaN;
end%if
if ~isnan(wake_data.frequency_domain_data.beam_port_spectrum)
    beam_port_spectrum = wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind)*1e9; %nJ
else
    beam_port_spectrum = NaN;
end %if

if ~isnan(wake_data.frequency_domain_data.raw_port_energy_spectrum)
    for ns = 1:size(wake_data.frequency_domain_data.raw_port_energy_spectrum, 2)
        port_energy_spectra{ns} = wake_data.frequency_domain_data.raw_port_energy_spectrum(1:cut_ind,ns)*1e9; %nJ
    end %for
else
    port_energy_spectra{1} = NaN(size(wake_data.frequency_domain_data.raw_port_energy_spectrum, 2),1);
end %if
