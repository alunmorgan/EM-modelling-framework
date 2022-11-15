function r_raw = rearrange_pp_data_structure(raw_data)
% rearranging the raw data structure into a form which is more useful for
% later analysis and plotting.
r_raw.time_series_data.Energy = raw_data.Energy.data;
r_raw.time_series_data.Charge_distribution = raw_data.Charge_distribution.data;
r_raw.time_series_data.Wake_potential = raw_data.Wake_potential.s.data;
r_raw.time_series_data.Wake_potential_trans_X = raw_data.Wake_potential.x.data;
r_raw.time_series_data.Wake_potential_trans_Y = raw_data.Wake_potential.y.data;
r_raw.time_series_data.port_data = raw_data.port.data.time; %W
r_raw.time_series_data.port_timebase = raw_data.port.timebase;
r_raw.time_series_data.port_labels = raw_data.port.labels;
% r_raw.frequency_series_data.port_data = raw_data.port.data.frequency;
r_raw.frequency_series_data.port_labels = raw_data.port.labels;
r_raw.frequency_series_data.Wake_impedance = raw_data.Wake_impedance.s.data;
r_raw.frequency_series_data.Wake_impedance_trans_X = raw_data.Wake_impedance.x.data;
r_raw.frequency_series_data.Wake_impedance_trans_Y = raw_data.Wake_impedance.y.data;
r_raw.wake_setup = raw_data.wake_setup;
if isfield(raw_data, 'mat_losses')
    % if the model is PEC only then this will not exist.
    r_raw.mat_losses = raw_data.mat_losses;
end %if
end %function