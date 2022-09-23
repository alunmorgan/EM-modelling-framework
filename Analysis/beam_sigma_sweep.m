function sigma_sweep = beam_sigma_sweep(time_domain_data, frequency_domain_data, bunch_charge, beam_sigma)
%% Find the variation with increasing beam sigma.
for odf = 1:5:60
    pulse_sig = str2double(beam_sigma) ./ 3E8 + (odf-1) * 1E-12;
    % generate the time domain signal
    pulse = (1/(sqrt(2*pi)*pulse_sig)) * ...
        exp(-(time_domain_data.timebase.^2)/(2*pulse_sig^2));
    
    bunch_spec_sig = fft(pulse)/length(time_domain_data.timebase);
    % truncate the new bunch sigma in the same way as all the other
    % frequency data.
    % the sqrt(2) it to account for the fact that really you should fold
    % over the signal and combine the overlapping signals to preserve
    % the power.
    bunch_spec_sig = bunch_spec_sig(1:length(frequency_domain_data.Wake_Impedance_data)) .* sqrt(2);
    
    [sigma_sweep.wlf(odf),...
        sigma_sweep.Bunch_loss_energy_spectrum{odf},...
        sigma_sweep.Total_bunch_energy_loss(odf)] = ...
        find_wlf_and_power_loss(bunch_charge, time_domain_data.timebase, ...
        bunch_spec_sig, frequency_domain_data.Wake_Impedance_data);
    sigma_sweep.sig_time(odf) = pulse_sig;
    clear pulse pulse_sig
    
    %     beam_sigma_sweep.beam_port_spectrum{odf},...
    %         ~,...
    %         beam_sigma_sweep.signal_port_spectrum{odf},...
    %         ~, ~, ~, ~]
    
    % ,...
    %         frequency_domain_data.port_impedances, frequency_domain_data.port_fft);
end
