function [time_domain_analysed_data] = time_domain_analysis(raw_data, log, mode_overrides)
% Takes the raw time domain data and calculates the wake loss factor
% and port losses from it.
%
% example: [time_domain_analysis, port_data] = time_domain_analysis(raw_data, beam_data)

% The wake potential needs to be scaled from V/charge to V/C
wake_potential = raw_data.time_series_data.Wake_potential ./ log.charge; 
wake_potential_trans_quad_x = raw_data.time_series_data.Wake_potential_trans_quad_X ./ log.charge; 
wake_potential_trans_quad_y = raw_data.time_series_data.Wake_potential_trans_quad_Y ./ log.charge; 
wake_potential_trans_dipole_x = raw_data.time_series_data.Wake_potential_trans_dipole_X ./ log.charge; 
wake_potential_trans_dipole_y = raw_data.time_series_data.Wake_potential_trans_dipole_Y ./ log.charge; 

% % Rescale the charge distribution timebase to match the wake potential scale
% ncd_scaled = interp1(raw_data.Charge_distribution(:,1), raw_data.Charge_distribution(:,2),...
%     raw_data.Wake_potential(:,1));
% % replace any NaNs with zeros. The interpolation function will have returned
% % NaNs where the new timescale was longer than the original one.
% ncd_scaled(isnan(ncd_scaled)) = 0;
time_step = abs(raw_data.time_series_data.timescale_common(2) - raw_data.time_series_data.timescale_common(1));
% Scale the charge distribution to have the normalised integral value of 1C.
cd_scaling = sum(raw_data.time_series_data.Charge_distribution .* time_step, 'omitnan');
charge_distribution = raw_data.time_series_data.Charge_distribution ./ cd_scaling; 

% Calculate the wake loss distribution
wake_loss_dist = charge_distribution .* wake_potential; %(V\C)

% Calculate the wake loss factor (V\C)
wake_loss_factor = -sum(wake_loss_dist .* time_step, 'omitnan'); %(V\C)

% Calculate the energy lost from the beam (J)
loss_from_beam = wake_loss_factor * log.charge.^2 ;

time_domain_analysed_data.charge_distribution = charge_distribution;
time_domain_analysed_data.wakepotential = wake_potential;
time_domain_analysed_data.wakepotential_trans_quad_x = wake_potential_trans_quad_x;
time_domain_analysed_data.wakepotential_trans_quad_y = wake_potential_trans_quad_y;
time_domain_analysed_data.wakepotential_trans_dipole_x = wake_potential_trans_dipole_x;
time_domain_analysed_data.wakepotential_trans_dipole_y = wake_potential_trans_dipole_y;
time_domain_analysed_data.timebase = raw_data.time_series_data.timescale_common;
time_domain_analysed_data.wake_loss_dist = wake_loss_dist;
time_domain_analysed_data.wake_loss_factor = wake_loss_factor;
time_domain_analysed_data.loss_from_beam = loss_from_beam;


if isempty(raw_data.time_series_data.port_data_all)
    time_domain_analysed_data.port_data.total_energy = 0;
else
    %% Port calculations
    time_domain_analysed_data.port_data = port_analysis(raw_data.time_series_data.timescale_common, ...
        raw_data.time_series_data.port_data, mode_overrides);
end
