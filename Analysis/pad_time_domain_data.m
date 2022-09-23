function [time_domain_data_pad, port_data_pad] = pad_time_domain_data(time_domain_data, n_samples)
%% Pad the time domain data.

[time_domain_data_pad.timebase, time_domain_data_pad.charge_distribution] = ...
    pad_data(time_domain_data.timebase, time_domain_data.charge_distribution, n_samples, 'samples');
[~, time_domain_data_pad.wakepotential] = ...
    pad_data(time_domain_data.timebase, time_domain_data.wakepotential, n_samples, 'samples');
[~, time_domain_data_pad.wakepotential_trans_X] = ...
    pad_data(time_domain_data.timebase, time_domain_data.wakepotential_trans_x, n_samples, 'samples');
[~, time_domain_data_pad.wakepotential_trans_Y] = ...
    pad_data(time_domain_data.timebase, time_domain_data.wakepotential_trans_y, n_samples, 'samples');

time_domain_data_pad.charge_distribution(isnan(time_domain_data_pad.charge_distribution)) = 0;
time_domain_data_pad.wakepotential(isnan(time_domain_data_pad.wakepotential)) = 0;
time_domain_data_pad.wakepotential_trans_X(isnan(time_domain_data_pad.wakepotential_trans_X)) = 0;
time_domain_data_pad.wakepotential_trans_Y(isnan(time_domain_data_pad.wakepotential_trans_Y)) = 0;

p1 = {'voltage_port_mode'};%,'power_port_mode'};
p2 = {'full_signal'};%, 'bunch_only', 'remnant_only'};
p3 = {'port_mode_signals'};%, 'port_mode_energy_time'};
for hsh = 1:length(p1)
    for nrs = 1:length(p2)
        for whs = 1:length(p3)
            port_sigs_temp = squeeze(sum(time_domain_data.port_data.(p1{hsh}).(p2{nrs}).(p3{whs}),2));
            for enf = 1:size(port_sigs_temp,1)
                [~, port_data_pad{enf}] = pad_data(time_domain_data.timebase, port_sigs_temp(enf,:), n_samples, 'samples');
                port_data_pad{enf} = port_data_pad{enf}';
            end %for
        end %for
    end %for
end %for