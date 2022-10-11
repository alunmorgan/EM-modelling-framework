function beam_sigma_sweep = variation_with_beam_sigma(beam_sigmas, timebase, ...
    Wake_Impedance_data, charge)
%% Find the variation with increasing beam sigma.
for odf = 1:length(beam_sigmas)
    pulse_sig = str2double(beam_sigmas(odf)) ./ 3E8;
    % generate the time domain signal
    pulse = (1/(sqrt(2*pi)*pulse_sig)) * ...
        exp(-(timebase.^2)/(2*pulse_sig^2));
    
    bunch_spec_sig = fft(pulse)/length(timebase);
    % truncate the new bunch sigma in the same way as all the other
    % frequency data.
    % the sqrt(2) it to account for the fact that really you should fold
    % over the signal and combine the overlapping signals to preserve
    % the power.
    bunch_spec_sig = bunch_spec_sig(1:length(Wake_Impedance_data)) .* sqrt(2);
    n_bunches_in_input_pattern = 1;
    [beam_sigma_sweep.wlf(odf),...
        beam_sigma_sweep.Bunch_loss_energy_spectrum{odf},...
        beam_sigma_sweep.Total_bunch_energy_loss(odf)] = ...
        find_wlf_and_power_loss(charge, timebase, ...
        bunch_spec_sig, Wake_Impedance_data, n_bunches_in_input_pattern);
    
    beam_sigma_sweep.sig_time(odf) = pulse_sig;
    clear pulse pulse_sig
end
