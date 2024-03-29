function [time_domain_analysed_data] = time_domain_analysis(raw_data, log, mode_overrides)
% Takes the raw time domain data and calculates the wake loss factor
% and port losses from it.
%
% example: [time_domain_analysis, port_data] = time_domain_analysis(raw_data, beam_data)

% The wake potential needs to be scaled from V/charge to V/C
wake_potential = raw_data.time_series_data.Wake_potential ./ log.charge;
wake_potential_trans_x = raw_data.time_series_data.Wake_potential_trans_X ./ log.charge;
wake_potential_trans_y = raw_data.time_series_data.Wake_potential_trans_Y ./ log.charge;

% Scale the charge distribution to have the normalised integral value of 1C.
time_step = abs(raw_data.time_series_data.timescale_common(2) - raw_data.time_series_data.timescale_common(1));
cd_scaling = sum(raw_data.time_series_data.Charge_distribution .* time_step, 'omitnan');
charge_distribution = raw_data.time_series_data.Charge_distribution ./ cd_scaling;

% Calculate the wake loss distribution
wake_loss_dist = charge_distribution .* wake_potential; %(V\C)

% Calculate the wake loss factor (V\C)
wake_loss_factor = -sum(wake_loss_dist, 'omitnan') .* time_step; %(V\C)

% Calculate the energy lost from the beam (J)
loss_from_beam = wake_loss_factor * log.charge.^2 ;

time_domain_analysed_data.charge_distribution = charge_distribution;
time_domain_analysed_data.wakepotential = wake_potential;
time_domain_analysed_data.wakepotential_trans_x = wake_potential_trans_x;
time_domain_analysed_data.wakepotential_trans_y = wake_potential_trans_y;
time_domain_analysed_data.timebase = raw_data.time_series_data.timescale_common;
time_domain_analysed_data.wake_loss_dist = wake_loss_dist;
time_domain_analysed_data.wake_loss_factor = wake_loss_factor;
time_domain_analysed_data.loss_from_beam = loss_from_beam;


if isempty(raw_data.time_series_data.port_data)
    time_domain_analysed_data.port_data.total_energy = 0;
else
    %% Port calculations
    time_domain_analysed_data.port_lables = raw_data.time_series_data.port_data.labels;
    substructure = fieldnames(raw_data.time_series_data.port_data.data.time);
    for ha = 1:length(substructure)
        if strcmp(substructure{ha}, 'voltage_port_mode') || strcmp(substructure{ha}, 'power_port_mode')
            if strcmp(substructure{ha}, 'voltage_port_mode')
                time_domain_analysed_data.port_data.(substructure{ha}).full_signal = port_analysis(raw_data.time_series_data.timescale_common, ...
                    raw_data.time_series_data.port_data.data.time.(substructure{ha}).data, mode_overrides, 'voltage');
                time_domain_analysed_data.port_data.(substructure{ha}).bunch_only = port_analysis(raw_data.time_series_data.timescale_common, ...
                    raw_data.time_series_data.port_data.data.time.(substructure{ha}).bunch_signal, mode_overrides, 'voltage');
                time_domain_analysed_data.port_data.(substructure{ha}).remnant_only = port_analysis(raw_data.time_series_data.timescale_common, ...
                    raw_data.time_series_data.port_data.data.time.(substructure{ha}).remnant_signal, mode_overrides, 'voltage');
            elseif strcmp(substructure{ha}, 'power_port_mode')
                time_domain_analysed_data.port_data.(substructure{ha}).full_signal = port_analysis(raw_data.time_series_data.timescale_common, ...
                    raw_data.time_series_data.port_data.data.time.(substructure{ha}).data, mode_overrides, 'power');
                time_domain_analysed_data.port_data.(substructure{ha}).bunch_only = port_analysis(raw_data.time_series_data.timescale_common, ...
                    raw_data.time_series_data.port_data.data.time.(substructure{ha}).bunch_signal, mode_overrides, 'power');
                time_domain_analysed_data.port_data.(substructure{ha}).remnant_only = port_analysis(raw_data.time_series_data.timescale_common, ...
                    raw_data.time_series_data.port_data.data.time.(substructure{ha}).remnant_signal, mode_overrides, 'power');
            end %if
            time_domain_analysed_data.port_data.(substructure{ha}).alpha = cell(1,1);
            time_domain_analysed_data.port_data.(substructure{ha}).beta = cell(1,1);
            time_domain_analysed_data.port_data.(substructure{ha}).frequency_cutoffs = cell(1,1);
            for lse = 1:length(mode_overrides)
                if length(raw_data.time_series_data.port_data.data.time.(substructure{ha}).alpha{lse}) < mode_overrides(lse)
                    time_domain_analysed_data.port_data.(substructure{ha}).alpha{lse} =...
                        raw_data.time_series_data.port_data.data.time.(substructure{ha}).alpha{lse};
                else
                    time_domain_analysed_data.port_data.(substructure{ha}).alpha{lse} =...
                        raw_data.time_series_data.port_data.data.time.(substructure{ha}).alpha{lse}(1:mode_overrides(lse));
                end %if
                if length(raw_data.time_series_data.port_data.data.time.(substructure{ha}).beta{lse}) < mode_overrides(lse)
                    time_domain_analysed_data.port_data.(substructure{ha}).beta{lse} = ...
                        raw_data.time_series_data.port_data.data.time.(substructure{ha}).beta{lse};
                else
                    time_domain_analysed_data.port_data.(substructure{ha}).beta{lse} = ...
                        raw_data.time_series_data.port_data.data.time.(substructure{ha}).beta{lse}(1:mode_overrides(lse));
                end %if
                if length(raw_data.time_series_data.port_data.data.time.(substructure{ha}).cutoff{lse}) < mode_overrides(lse)
                    time_domain_analysed_data.port_data.(substructure{ha}).frequency_cutoffs{lse} =...
                        raw_data.time_series_data.port_data.data.time.(substructure{ha}).cutoff{lse};
                else
                    time_domain_analysed_data.port_data.(substructure{ha}).frequency_cutoffs{lse} =...
                        raw_data.time_series_data.port_data.data.time.(substructure{ha}).cutoff{lse}(1:mode_overrides(lse));
                end %if
            end %for
        end %if
    end %for
end %if
