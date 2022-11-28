function [time_domain_analysed_data] = time_domain_analysis(raw_data, log)
% Takes the raw time domain data and calculates the wake loss factor
% and port losses from it.
%
% example: [time_domain_analysis, port_data] = time_domain_analysis(raw_data, beam_data)

% The wake potential needs to be scaled from V/charge to V/C
wake_potential = raw_data.Wake_potential ./ log.charge;
wake_potential_trans_x = raw_data.Wake_potential_trans_X ./ log.charge;
wake_potential_trans_y = raw_data.Wake_potential_trans_Y ./ log.charge;

% Scale the charge distribution to have the normalised integral value of 1C.
time_step = abs(raw_data.timebase(2) - raw_data.timebase(1));
cd_scaling = sum(raw_data.Charge_distribution .* time_step, 'omitnan');
charge_distribution_1C = raw_data.Charge_distribution ./ cd_scaling;

% Calculate the wake loss distribution
wake_loss_dist = charge_distribution_1C .* wake_potential; %(V\C)

% Calculate the wake loss factor (V\C)
wake_loss_factor = -sum(wake_loss_dist, 'omitnan') .* time_step; %(V\C)

% Calculate the energy lost from the beam (J)
loss_from_beam = wake_loss_factor * log.charge.^2 ;

time_domain_analysed_data.charge_distribution_1C = charge_distribution_1C; % for 1C
time_domain_analysed_data.charge_distribution = raw_data.Charge_distribution; % for model charge.
time_domain_analysed_data.wakepotential = wake_potential;
time_domain_analysed_data.wakepotential_trans_x = wake_potential_trans_x;
time_domain_analysed_data.wakepotential_trans_y = wake_potential_trans_y;
time_domain_analysed_data.timebase = raw_data.timebase;
time_domain_analysed_data.wake_loss_dist = wake_loss_dist;
time_domain_analysed_data.wake_loss_factor = wake_loss_factor;
time_domain_analysed_data.loss_from_beam = loss_from_beam;


if isempty(raw_data.port_data)
    time_domain_analysed_data.port_data.total_energy = 0;
else
    %% Port calculations
    time_domain_analysed_data.port_lables = raw_data.port_labels;
    substructure = fieldnames(raw_data.port_data);
    for ha = 1:length(substructure)
        if strcmp(substructure{ha}, 'voltage_port_mode') || strcmp(substructure{ha}, 'power_port_mode')
            if strcmp(substructure{ha}, 'voltage_port_mode')
                time_domain_analysed_data.port_data.(substructure{ha}).full_signal = port_analysis(raw_data.timebase, ...
                    raw_data.port_data.(substructure{ha}).data, 'voltage');
                time_domain_analysed_data.port_data.(substructure{ha}).bunch_only = port_analysis(raw_data.timebase, ...
                    raw_data.port_data.(substructure{ha}).bunch_signal, 'voltage');
                time_domain_analysed_data.port_data.(substructure{ha}).remnant_only = port_analysis(raw_data.timebase, ...
                    raw_data.port_data.(substructure{ha}).remnant_signal, 'voltage');
            elseif strcmp(substructure{ha}, 'power_port_mode')
                time_domain_analysed_data.port_data.(substructure{ha}).full_signal = port_analysis(raw_data.timebase, ...
                    raw_data.port_data.(substructure{ha}).data, 'power');
                time_domain_analysed_data.port_data.(substructure{ha}).bunch_only = port_analysis(raw_data.timebase, ...
                    raw_data.port_data.(substructure{ha}).bunch_signal, 'power');
                time_domain_analysed_data.port_data.(substructure{ha}).remnant_only = port_analysis(raw_data.timebase, ...
                    raw_data.port_data.(substructure{ha}).remnant_signal, 'power');
            end %if
            time_domain_analysed_data.port_data.(substructure{ha}).alpha =...
                raw_data.port_data.(substructure{ha}).alpha;
            time_domain_analysed_data.port_data.(substructure{ha}).beta = ...
                raw_data.port_data.(substructure{ha}).beta;
            time_domain_analysed_data.port_data.(substructure{ha}).frequency_cutoffs =...
                raw_data.port_data.(substructure{ha}).cutoff;
        end %if
    end %for
end %if
