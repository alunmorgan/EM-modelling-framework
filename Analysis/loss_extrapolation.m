function [diff_machine_conds] = loss_extrapolation(time_domain_data, ppi)
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
%removing some parts of the time domain data due to memory contraints
time_domain_data.port_data = rmfield(time_domain_data.port_data, 'voltage_port_mode');
time_domain_data.port_data.power_port_mode = rmfield(time_domain_data.port_data.power_port_mode, 'remnant_only');
time_domain_data.port_data.power_port_mode = rmfield(time_domain_data.port_data.power_port_mode, 'bunch_only');
time_domain_data.port_data.power_port_mode.full_signal = rmfield(time_domain_data.port_data.power_port_mode.full_signal, 'port_mode_energy_cumsum');
time_domain_data.port_data.power_port_mode.full_signal = rmfield(time_domain_data.port_data.power_port_mode.full_signal, 'total_energy_cumsum');
time_domain_data.port_data.power_port_mode.full_signal = rmfield(time_domain_data.port_data.power_port_mode.full_signal, 'port_energy_cumsum');
time_domain_data.port_data.power_port_mode.full_signal = rmfield(time_domain_data.port_data.power_port_mode.full_signal, 'port_mode_energy');
time_domain_data.port_data.power_port_mode.full_signal = rmfield(time_domain_data.port_data.power_port_mode.full_signal, 'port_mode_energy_time');

time_domain_data.port_data.power_port_mode.full_signal.port_signals = squeeze(sum(time_domain_data.port_data.power_port_mode.full_signal.port_mode_signals,2));
time_domain_data.port_data.power_port_mode.full_signal = rmfield(time_domain_data.port_data.power_port_mode.full_signal, 'port_mode_signals');
%% Find variation with different beam conditions.
gap = 1/ppi.RF_freq;

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
            timestep = abs(timebase(2) - timebase(1));
            % using colon rather than linspace as it allow one to specify the
            % stepsize explicitly. With linspace numerical noise meant that you
            % would get a slightly different stepsize which would mess up later
            % comparisons
            pulse_timescale = 0:timestep:gap-timestep;
            new_pulse = 1 .* exp(-((pulse_timescale - gap ./ 2).^2) ./ (2 .* bunch_length.^2));
            % scale pulse to desired bunch charge.
            pulse_charge = sum(new_pulse) * timestep;
            new_pulse = new_pulse ./ pulse_charge .* bunch_charge;
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
                        
            time_domain_data_bc = pad_time_domain_data(time_domain_data, length(pulses_timescale));
            time_domain_data_bc.pulse_total_charge = total_charge;
            time_domain_data_bc.pulse_for_reconstruction = pulse';
            
            clear pulse pulses_timescale new_pulse
            
            frequency_domain_data_bc = frequency_domain_analysis(time_domain_data_bc, total_charge, n_bunches_in_input_pattern);
           
            clear total_charge n_bunches_in_input_pattern
            
            diff_machine_conds.bunch_charge(cur_ind, btl_ind, rf_ind)= bunch_charge;
            diff_machine_conds.bunch_length(cur_ind, btl_ind, rf_ind)= bunch_length;
            
            clear bunch_charge bunch_length
            
            fn_time = fieldnames(time_domain_data_bc);
            for nse = 1:length(fn_time)
            diff_machine_conds.time.(fn_time{nse}){cur_ind, btl_ind, rf_ind} = time_domain_data_bc.(fn_time{nse});
            end %for
            fn_freq = fieldnames(frequency_domain_data_bc);
            for nre = 1:length(fn_freq)
            diff_machine_conds.freq.(fn_freq{nre}){cur_ind, btl_ind, rf_ind} = frequency_domain_data_bc.(fn_freq{nre});
            end %for
            
            clear time_domain_data_bc  frequency_domain_data_bc
        end %for
    end %for
end %for