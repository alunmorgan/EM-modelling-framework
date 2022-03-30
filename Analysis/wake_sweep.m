function wake_sweep_data = wake_sweep(sweep_lengths, r_raw, ppi, log)
% Run the frequency domain analysis over data which is increasingly reduced
% in length (i.e. having different wake lengths).
%
% Example: wake_sweeps = wake_sweep(time_domain_data, port_data)

for se = length(sweep_lengths):-1:1
    new_timescale = r_raw.timebase(r_raw.timebase < sweep_lengths(se)/3E8);
    r_data{se} = pp_apply_new_timebase(r_raw, new_timescale);
    r_data{se}.wake_setup.Wake_length = sweep_lengths(se);
    
    %% Time domain analysis
    t_data{se} = time_domain_analysis(r_data{se}, log);
    %% Frequency domain analysis
    f_data{se} = frequency_domain_analysis(t_data{se}, log, ppi.hfoi);
   
    %     %% Generating data for time slices
    %     f_data{se}.time_slices = time_slices(t_data{se}.timebase, ...
    %         t_data{se}.wakepotential, ppi.hfoi);
    %     %% Calculating the losses for different bunch lengths
    %     f_data{se}.extrap_data.beam_sigma_sweep = variation_with_beam_sigma(ppi.bunch_lengths, t_data{se}.timebase, ...
    %         f_data{se}.Wake_Impedance_data, log.charge, f_data{se}.port_impedances, f_data{se}.port_fft);
    %
    %     %% and bunch charges.
    %     f_data{se}.extrap_data.diff_machine_conds = loss_extrapolation(t_data{se}.timebase, f_data{se}, ppi);
end %for

wake_sweep_data.frequency_domain_data = f_data;
wake_sweep_data.time_domain_data = t_data;

