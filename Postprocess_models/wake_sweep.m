function sweep = wake_sweep(time_domain_data, port_data, raw_data, hfoi, log)
% Run the frequency domain analysis over data which is increasingly reduced
% in length (i.e. having different wake lengths).
%
% Example: wake_sweeps = wake_sweep(time_domain_data, port_data)

dsd = length(time_domain_data.timebase);
% Set the number of wake lengths to do.

raw_port_data = put_on_reference_timebase(time_domain_data.timebase, port_data);
n_points = 20;
for se = n_points:-1:1
    % find the data length required.
    trimed = round((dsd/n_points)*se);
    % Construct a replacement structure containing the truncated datasets.
    tmp_time.timebase = time_domain_data.timebase(1:trimed);
    tmp_time.wakepotential = time_domain_data.wakepotential(1:trimed);
    tmp_time.wakepotential_trans_x = time_domain_data.wakepotential_trans_x(1:trimed);
    tmp_time.wakepotential_trans_y = time_domain_data.wakepotential_trans_y(1:trimed);
    tmp_time.charge_distribution = time_domain_data.charge_distribution(1:trimed);
    tmp_port.timebase = time_domain_data.timebase(1:trimed);
    if isfield(port_data, 'data')
        for nr = 1:length(port_data.data)
            tmp_port.data{nr} = raw_port_data{nr}(1:trimed,:);
        end
        % Run the analysis.
        sweep{se} = frequency_domain_analysis(...
            raw_data.port.frequency_cutoffs, ...
            tmp_time,...
            tmp_port,...
            log, hfoi);
    else
        % Run the analysis.
        sweep{se} = frequency_domain_analysis(...
            NaN, tmp_time, NaN, log, hfoi);
    end
    sweep{se}.Wake_length = ...
        raw_data.wake_setup.Wake_length / n_points * se;
end

