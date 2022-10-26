function wake_sweep_data = wake_sweep(sweep_lengths, r_raw, log)
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
    n_bunches_in_input_pattern = 1;
    f_data{se} = frequency_domain_analysis(t_data{se}, log.charge, n_bunches_in_input_pattern);
end %for
wake_sweep_data.frequency_domain_data = f_data;
wake_sweep_data.time_domain_data = t_data;






