function [time_domain_data_pad] = pad_time_domain_data(time_domain_data, n_samples)
%% Pad the time domain data.

%make sure all the unpadded data it captured.
time_domain_data_pad = time_domain_data;

% now overwrite the relavent variables.
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
p1 = fieldnames(time_domain_data.port_data);
p1_ref = {'voltage_port_mode', 'power_port_mode'};
p1 = intersect(p1, p1_ref);
p2 = fieldnames(time_domain_data.port_data.(p1{1}));
p2_ref = {'full_signal', 'bunch_only', 'remnant_only'};
p2 = intersect(p2, p2_ref);
p3 = fieldnames(time_domain_data.port_data.(p1{1}).(p2{1}));
p3_ref = {'port_mode_signals', 'port_mode_energy_time', 'port_signals'};
p3 = intersect(p3, p3_ref);
for hsh = 1:length(p1)
    for nrs = 1:length(p2)
        for whs = 1:length(p3)
            port_sigs_temp = time_domain_data.port_data.(p1{hsh}).(p2{nrs}).(p3{whs});
            for sha = 1:size(port_sigs_temp,1)
                if strcmp(p3{whs}, 'port_signals')
                    if sha==1
                        [~, temp] = pad_data(time_domain_data.timebase, squeeze(port_sigs_temp(sha,:)), n_samples, 'samples');
                        port_data_pad = NaN(size(port_sigs_temp,1), length(temp));
                        port_data_pad(sha, :) = temp;
                        clear temp
                    else
                        [~, port_data_pad(sha, :)] = pad_data(time_domain_data.timebase, squeeze(port_sigs_temp(sha, :)), n_samples, 'samples');
                    end %if
                elseif strcmp(p3{whs}, 'port_mode_signals') || strcmp(p3{whs}, 'port_mode_energy_time')
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
                end %if
            end %for
            time_domain_data_pad.port_data.(p1{hsh}).(p2{nrs}).(p3{whs}) = port_data_pad;
            clear port_data_pad
        end %for
    end %for
end %for