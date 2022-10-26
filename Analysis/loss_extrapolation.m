function [diff_machine_conds] = loss_extrapolation(time_domain_data, log, ppi)
% calculates the change in wake loss factor and energy lost from the beam
% and into the ports as the bunch and bunch train is varied.
%
% time_domain_data is
% port_data is
% beam_data is
% raw_data is
% log is
% extrap_data is
%
% Example: [extrap_data] = loss_extrapolation(time_domain_data, port_data, beam_data, raw_data, log )
timebase = time_domain_data.timebase;
% port_frequency_cutoffs = time_domain_data.port_data.voltage_port_mode.frequency_cutoffs;
% hfoi = 5E10;

%% Find variation with different beam conditions.
rev = ppi.RF_freq/936;
gap = 1/ppi.RF_freq;
% rev_time = (1/ppi.RF_freq) * 936; %time of 1 revolution

for cur_ind = 1:length(ppi.current)
    cur  = ppi.current(cur_ind);
    for btl_ind = 1:length(ppi.bt_length)
        %TEMP until the input file is changed
        fill_pattern = zeros(936,1);
        fill_pattern(1:ppi.bt_length(btl_ind)) = 1;
        for rf_ind = 1:length(ppi.rf_volts)
            rf_val = ppi.rf_volts(rf_ind);
            
            % calculating the bunch charge and bunch length for the given current fill pattern and RF voltage.
            bunch_charge = cur ./ ((1./gap) .* (sum(fill_pattern) ./ length(fill_pattern)));
            bunch_length =...
                (3.87 + 2.41 * (cur * 1E3./sum(fill_pattern)) .^ 0.81) * sqrt(2.5/rf_val) * 1e-3./3E8; %in s
            
            % added gap/2 so that the peak of the pulse does not happen at 0. So
            % we get a complete first pulse.
            % Generating a pulse train of 1C bunches
            timestep = abs(timebase(2) - timebase(1));
            % using colon rather than linspace as it allow one to specify the
            % stepsize explicitly. With linspace numerical noise meant that you
            % would get a slightly different stepsize which would mess up later
            % comparisons
            pulse_timescale = 0:timestep:gap-timestep;
            new_pulse = ((1 ./ (sqrt(2 .* pi) .* bunch_length)) .* ...
                exp(-((pulse_timescale - gap ./ 2).^2) ./ (2 .* bunch_length.^2)));
            pulse = [];
            pulses_timescale = [];
            total_charge = 0;
            n_bunches_in_input_pattern = 0;
            for jawe = 1:length(fill_pattern)
                if fill_pattern(jawe) == 1
                    pulse = cat(2, pulse, new_pulse);
                    n_bunches_in_input_pattern = n_bunches_in_input_pattern +1;
                else
                    pulse = cat(2, pulse, zeros(1, length(pulse_timescale)));
                end %if
                pulses_timescale = cat(2, pulses_timescale, pulse_timescale * jawe);
                total_charge = total_charge + bunch_charge;
            end
%             pulse_timestep = (pulses_timescale(2) - pulses_timescale(1));
%             pulse_f_scale = (linspace(0,1,length(pulses_timescale)) / pulse_timestep);
%             bunch_spec_bc = fft(pulse);
            
            time_domain_data_bc = pad_time_domain_data(time_domain_data, length(pulses_timescale));
            % Regenerate the frequency domain data.
            frequency_domain_data_bc = frequency_domain_analysis(time_domain_data_bc, total_charge, n_bunches_in_input_pattern);
%             [f_raw_bc,~, wakeimpedance_bc,~, port_impedances_bc] = ...
%                 regenerate_f_data(port_frequency_cutoffs, time_domain_data_bc,...
%                 port_data_bc, '', hfoi);
%             cut_ind = find(pulse_f_scale < hfoi, 1, 'last');
%             bunch_spec_bc = bunch_spec_bc(1:cut_ind);
%             pulse_f_scale = pulse_f_scale(1:cut_ind);
            
%             [wake_loss_factor, ...
%                 Bunch_loss_energy_spectrum, Total_bunch_energy_loss] = ...
%                 find_wlf_and_power_loss(total_charge, pulses_timescale, bunch_spec_bc', ...
%                 wakeimpedance_bc, n_bunches_in_input_pattern);
%             
%             for ehs = 1:size(port_impedances_bc,2)
%                 single_port_impedance = port_impedances_bc(:,ehs);
%                 [~, ...
%                     port_loss_energy_spectrum(:,ehs), port_energy_loss(ehs)] = ...
%                     find_wlf_and_power_loss(total_charge, pulses_timescale, bunch_spec_bc', ...
%                     single_port_impedance, n_bunches_in_input_pattern);
%             end %for
%             Total_energy_from_beam_ports = sum(port_energy_loss(1:2));
%             Total_energy_from_signal_ports = sum(port_energy_loss(3:end));
%             
            diff_machine_conds.port_labels{cur_ind, btl_ind, rf_ind} = time_domain_data.port_lables;
            diff_machine_conds.bunch_spec{cur_ind, btl_ind, rf_ind} = frequency_domain_data_bc.bunch_spectra;
            diff_machine_conds.wlf(cur_ind, btl_ind, rf_ind) = frequency_domain_data_bc.wlf;
            diff_machine_conds.power_loss(cur_ind, btl_ind, rf_ind) = frequency_domain_data_bc.Total_bunch_energy_loss .* rev; % CHECK this assumes pattern is one revolution
            diff_machine_conds.bunch_charge(cur_ind, btl_ind, rf_ind)= bunch_charge;
            diff_machine_conds.bunch_length(cur_ind, btl_ind, rf_ind)= bunch_length;
            diff_machine_conds.port_loss_energy_spectrum(cur_ind, btl_ind, rf_ind, :, :) = frequency_domain_data_bc.Total_port_spectrum;
            diff_machine_conds.f_scale(cur_ind, btl_ind, rf_ind, :) = frequency_domain_data_bc.f_raw;
            diff_machine_conds.Bunch_loss_energy_spectrum(cur_ind, btl_ind, rf_ind, :) = frequency_domain_data_bc.Bunch_loss_energy_spectrum;
            diff_machine_conds. Total_energy_from_beam_ports(cur_ind, btl_ind, rf_ind) = sum(frequency_domain_data_bc.beam_port_spectrum);
            diff_machine_conds.Total_bunch_energy_loss(cur_ind, btl_ind, rf_ind) = frequency_domain_data_bc.Total_bunch_energy_loss;
            diff_machine_conds.Total_energy_from_signal_ports(cur_ind, btl_ind, rf_ind) =  sum(frequency_domain_data_bc.signal_port_spectrum);
            diff_machine_conds.port_energy_loss(cur_ind, btl_ind, rf_ind) = diff_machine_conds.Total_energy_from_signal_ports(cur_ind, btl_ind, rf_ind) + ...
                diff_machine_conds. Total_energy_from_beam_ports(cur_ind, btl_ind, rf_ind);
            diff_machine_conds.loss_beam_pipe(cur_ind, btl_ind, rf_ind) = Total_energy_from_beam_ports ./diff_machine_conds.Total_bunch_energy_loss(cur_ind, btl_ind, rf_ind);
            diff_machine_conds.loss_signal_ports(cur_ind, btl_ind, rf_ind) = Total_energy_from_signal_ports ./ diff_machine_conds.Total_bunch_energy_loss(cur_ind, btl_ind, rf_ind);
            diff_machine_conds.loss_structure(cur_ind, btl_ind, rf_ind) = 1 - ( diff_machine_conds.port_energy_loss(cur_ind, btl_ind, rf_ind))./ diff_machine_conds.Total_bunch_energy_loss(cur_ind, btl_ind, rf_ind);
            clear time_domain_data_bc  frequency_domain_data_bc pulse pulses_timescale total_charge
        end %for
    end %for
end %for