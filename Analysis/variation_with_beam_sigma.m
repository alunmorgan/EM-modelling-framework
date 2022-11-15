function beam_sigma_sweep = variation_with_beam_sigma(bunch_length, time_domain_data, charge)
%% Find the variation with increasing beam sigma.

for odf = 1:length(bunch_length)
    pulse_sig = bunch_length(odf) *1E-3 ./ 3E8; % bunch length is in mm
    % generate the time domain signal
    pulse = 1 * exp(-(time_domain_data.timebase.^2)/(2*pulse_sig^2));
    pulse_sum = sum(pulse) .* (time_domain_data.timebase(2) - time_domain_data.timebase(1));
    pulse = pulse ./ pulse_sum .* charge;
    
    time_domain_data.pulse_for_reconstruction = pulse;
    time_domain_data.pulse_total_charge = charge;
    frequency_domain_data = frequency_domain_analysis(time_domain_data, charge, 1);
    
    beam_sigma_sweep.sig_time(odf) = pulse_sig;
    fn_time = fieldnames(time_domain_data);
    for nse = 1:length(fn_time)
        beam_sigma_sweep.time.(fn_time{nse}){odf} = time_domain_data.(fn_time{nse});
    end %for
    fn_freq = fieldnames(frequency_domain_data);
    for nre = 1:length(fn_freq)
        beam_sigma_sweep.freq.(fn_freq{nre}){odf} = frequency_domain_data.(fn_freq{nre});
    end %for
    clear pulse pulse_sig fn_time fn_freq time_domain_data.pulse_for_reconstruction frequency_domain_data
end
