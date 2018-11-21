function [time_domain_analysis, port_data] = time_domain_analysis(raw_data, log, mode_overrides)
% Takes the raw time domain data and calculates the wake loss factor
% and port losses from it.
%
% example: [time_domain_analysis, port_data] = time_domain_analysis(raw_data, beam_data)

% The wake potential needs to be scaled from V/charge to V/C
wake_potential = raw_data.Wake_potential(:,2) ./ log.charge; 
wake_potential_trans_x = raw_data.Wake_potential_trans_X(:,2) ./ log.charge; 
wake_potential_trans_y = raw_data.Wake_potential_trans_Y(:,2) ./ log.charge; 

% Rescale the charge distribution timebase to match the wake potential scale
ncd_scaled = interp1(raw_data.Charge_distribution(:,1), raw_data.Charge_distribution(:,2),...
    raw_data.Wake_potential(:,1));
% replace any NaNs with zeros. The interpolation function will have returned
% NaNs where the new timescale was longer than the original one.
ncd_scaled(isnan(ncd_scaled)) = 0;

% Scale the charge distribution to have the normalised integral value of 1C.
cd_scaling = sum(ncd_scaled .* (raw_data.Wake_potential(2,1) - raw_data.Wake_potential(1,1)));
charge_distribution = ncd_scaled ./ cd_scaling;

% Calculate the wake loss distribution
wake_loss_dist = charge_distribution .* wake_potential; %(V\C)

% Calculate the wake loss factor (V\C)
wake_loss_factor = -sum(wake_loss_dist .* abs((raw_data.Wake_potential(2,1) - raw_data.Wake_potential(1,1)))); %(V\C)

% Calculate the energy lost from the beam (J)
loss_from_beam = wake_loss_factor * log.charge.^2 ;

time_domain_analysis.charge_distribution = charge_distribution;
time_domain_analysis.wakepotential = wake_potential;
time_domain_analysis.wakepotential_trans_x = wake_potential_trans_x;
time_domain_analysis.wakepotential_trans_y = wake_potential_trans_y;
time_domain_analysis.timebase = raw_data.Wake_potential(:,1);
time_domain_analysis.wake_loss_dist = wake_loss_dist;
time_domain_analysis.wake_loss_factor = wake_loss_factor;
time_domain_analysis.loss_from_beam = loss_from_beam;


if isempty(raw_data.port.data_all)
    port_data.total_energy = 0;
else
    %% Port calculations
    [port_data] = port_analysis(raw_data.port, mode_overrides);
end
