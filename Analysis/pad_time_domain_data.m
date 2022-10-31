function [time_domain_data_pad] = pad_time_domain_data(time_domain_data, n_samples)
%% Pad the time domain data.

[time_domain_data_pad.timebase, time_domain_data_pad.charge_distribution] = ...
    pad_data(time_domain_data.timebase, time_domain_data.charge_distribution, n_samples, 'samples');
[~, time_domain_data_pad.wakepotential] = ...
    pad_data(time_domain_data.timebase, time_domain_data.wakepotential, n_samples, 'samples');
[~, time_domain_data_pad.wakepotential_trans_x] = ...
    pad_data(time_domain_data.timebase, time_domain_data.wakepotential_trans_x, n_samples, 'samples');
[~, time_domain_data_pad.wakepotential_trans_y] = ...
    pad_data(time_domain_data.timebase, time_domain_data.wakepotential_trans_y, n_samples, 'samples');

time_domain_data_pad.charge_distribution(isnan(time_domain_data_pad.charge_distribution)) = 0;
time_domain_data_pad.wakepotential(isnan(time_domain_data_pad.wakepotential)) = 0;
time_domain_data_pad.wakepotential_trans_x(isnan(time_domain_data_pad.wakepotential_trans_x)) = 0;
time_domain_data_pad.wakepotential_trans_y(isnan(time_domain_data_pad.wakepotential_trans_y)) = 0;

p1 = {'voltage_port_mode', 'power_port_mode'};
p2 = {'full_signal', 'bunch_only', 'remnant_only'};
p3 = {'port_mode_signals', 'port_mode_energy_time'};
for hsh = 1:length(p1)
    for nrs = 1:length(p2)
        for whs = 1:length(p3)
            port_sigs_temp = time_domain_data.port_data.(p1{hsh}).(p2{nrs}).(p3{whs});
            for sha = 1:size(port_sigs_temp,1)
                for enf = 1:size(port_sigs_temp,2)
                    if sha==1 && enf == 1
                        [~, temp] = pad_data(time_domain_data.timebase, squeeze(port_sigs_temp(sha, enf,:)), n_samples, 'samples');
                        port_data_pad = NaN(size(port_sigs_temp,1), size(port_sigs_temp,2), length(temp));
                        port_data_pad(sha, enf, :) = temp;
                        clear temp
                    else
                        [~, port_data_pad(sha, enf, :)] = pad_data(time_domain_data.timebase, squeeze(port_sigs_temp(sha, enf,:)), n_samples, 'samples');
                    end %if
                end %for
            end %for
            time_domain_data_pad.port_data.(p1{hsh}).(p2{nrs}).(p3{whs}) = port_data_pad;
            clear port_data_pad
        end %for
    end %for
end %for