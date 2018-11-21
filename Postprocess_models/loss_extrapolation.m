function [extrap_data] = loss_extrapolation(time_domain_data, port_data, mi, ppi, raw_data, log )
% calculates the change in wake loss factor and energy lost from the beam
% and into the ports as the bunch and bunch train is varied.
%
% time_domain_data is 
% port_data is
% beam_data is
% raw_data is
% hfoi is
% log is 
% extrap_data is 
%
% Example: [extrap_data] = loss_extrapolation(time_domain_data, port_data, beam_data, raw_data, hfoi, log )

[ raw_port_data] = put_on_reference_timebase(time_domain_data.timebase, port_data);

%% Pad the time domain data.

[timescale_sig, Charge_distribution_sig] = ...
    pad_data(time_domain_data.timebase, 14, 'points',...
    time_domain_data.charge_distribution);
[~, wakepotential_sig] = ...
    pad_data(time_domain_data.timebase, 14, 'points',...
    time_domain_data.wakepotential);

if iscell(raw_port_data)
    [~, port_data_sig] = ...
    pad_data(time_domain_data.timebase, 14, 'points', raw_port_data);
else
    port_data_sig = NaN;
end %if

%% Regenerate the frequency domain data.
[~,~, wakeimpedance_sig,~, port_impedances_sig] = ...
    regenerate_f_data(Charge_distribution_sig, ...
    wakepotential_sig,...
    port_data_sig, raw_data.port.frequency_cutoffs,...
    timescale_sig, ppi.hfoi);

%% Find the variation with increasing beam sigma.
for odf = 1:55
    pulse_sig = str2num(mi.beam_sigma) ./ 3E8 + (odf-1) * 1E-12;
    % generate the time domain signal
    pulse = (1/(sqrt(2*pi)*pulse_sig)) * ...
        exp(-(timescale_sig.^2)/(2*pulse_sig^2));

    bunch_spec_sig = fft(pulse)/length(timescale_sig);
    % truncate the new bunch sigma in the same way as all the other
    % frequency data.
        % the sqrt(2) it to account for the fact that realy you should fold
        % over the signal and combine the overlapping signals to preserve
        % the power.
    bunch_spec_sig = bunch_spec_sig(1:length(wakeimpedance_sig)) .* sqrt(2);
    [extrap_data.beam_sigma_sweep.wlf(odf),~, ~, ~, ~, ~, ~, ~, ~, ~] = ...
        find_wlf_and_power_loss(log.charge, timescale_sig, bunch_spec_sig, ...
        wakeimpedance_sig, port_impedances_sig);
    extrap_data.beam_sigma_sweep.sig_time(odf) = pulse_sig;
    clear pulse pulse_sig
end

%% Find variation with different beam conditions.
rev = ppi.RF_freq/936;
gap = 1/ppi.RF_freq;
rev_time = (1/ppi.RF_freq) * 936; %time of 1 revolution
% Pad the time domain data to one revolution length.
[ timescale_bc_1_turn, Charge_distribution_bc] = ...
    pad_data(time_domain_data.timebase, rev_time, 'time',...
    time_domain_data.charge_distribution);
[~, wakepotential_bc] = ...
    pad_data(time_domain_data.timebase, rev_time, 'time',...
    time_domain_data.wakepotential);

if iscell(raw_port_data)
    [ ~, port_data_bc] = ...
        pad_data(time_domain_data.timebase, rev_time, 'time', raw_port_data);
else
    port_data_bc = NaN;
end %if

timescale_bc = timescale_bc_1_turn;
% Regenerate the frequency domain data.
% Note: replicating the longditudinal wake data for the transverse for the
% moment as the transverse data is not used and this garentees the data is
% the correct length.

[f_raw_bc,bunch_spec_bc,...
    wakeimpedance_bc,~,...
    port_impedances_bc] = ...
    regenerate_f_data(Charge_distribution_bc, ...
    wakepotential_bc, port_data_bc, raw_data.port.frequency_cutoffs,...
    timescale_bc, ppi.hfoi);

% When both bunch_spectra_model and
% fft_t_wp are 0 this gives a NaN, but that poisons
% all the following calculations. In this case it is OK to set
% it to 0.
wakeimpedance_bc(bunch_spec_bc == 0) = 0;
port_impedances_bc(bunch_spec_bc == 0,:) = 0;
for cur_ind = 1:length(ppi.current)
    cur  = ppi.current(cur_ind);
    for btl_ind = 1:length(ppi.bt_length)
        fill_pattern = ppi.bt_length(btl_ind);
        for rf_ind = 1:length(ppi.rf_volts)
            rf_val = ppi.rf_volts(rf_ind);
            
            % calculating the bunch charge and bunch length for the given current fill pattern and RF voltage.
            bunch_charge = cur.*1e-3 ./ ((1./gap) .* (fill_pattern ./ 936));
            bunch_length =...
                (3.87 + 2.41 * (cur./fill_pattern) .^ 0.81) * sqrt(2.5/rf_val) * 1e-3./3E8; %in s
            
            pulse = zeros(length(timescale_bc_1_turn),1);
            % added gap/2 so that the peak of the pulse does not happen at 0. So
            % we get a complete first pulse.
            parfor jawe = 1:fill_pattern
                new_pulse = ((1 ./ (sqrt(2 .* pi) .* bunch_length)) .* ...
                    exp(-((timescale_bc_1_turn - (gap .* (jawe - 1)) - gap ./ 2).^2) ./ (2 .* bunch_length.^2)) .* ...
                    bunch_charge);
                pulse = pulse + new_pulse;
            end
            bunch_spec_bc = fft(pulse./bunch_charge)/length(timescale_bc);
            %             This outputs the powers
                % truncate the new bunch sigma in the same way as all the other
    % frequency data.
    bunch_spec_bc = bunch_spec_bc(1:length(wakeimpedance_bc));
            [wake_loss_factor, ...
                Bunch_loss_energy_spectrum, Total_bunch_energy_loss, beam_port_spectrum, ~,...
                signal_port_spectrum, ~, ~, ~, ~] = ...
                find_wlf_and_power_loss(bunch_charge, timescale_bc, bunch_spec_bc, ...
                wakeimpedance_bc, port_impedances_bc);
            % setting any powers which are larger than the loss for that frequency
            % to zero. This means that the power into the structure is an over
            % estimate.
            tmp = find(beam_port_spectrum > Bunch_loss_energy_spectrum);
            beam_port_spectrum(tmp) = 0;
            Total_energy_from_beam_ports = sum(beam_port_spectrum);
            tmp2 = find(signal_port_spectrum > Bunch_loss_energy_spectrum);
            signal_port_spectrum(tmp2) = 0;
            Total_energy_from_signal_ports = sum(signal_port_spectrum);
            extrap_data.diff_machine_conds.bunch_spec{cur_ind, btl_ind, rf_ind} = bunch_spec_bc;
            extrap_data.diff_machine_conds.wlf(cur_ind, btl_ind, rf_ind) = wake_loss_factor;
            extrap_data.diff_machine_conds.power_loss(cur_ind, btl_ind, rf_ind) = Total_bunch_energy_loss .* rev;
            extrap_data.diff_machine_conds.bunch_charge(cur_ind, btl_ind, rf_ind)= bunch_charge;
            extrap_data.diff_machine_conds.bunch_length(cur_ind, btl_ind, rf_ind)= bunch_length;
            
            if ~iscell(port_data_bc) && isnan(port_data_bc)
                extrap_data.diff_machine_conds.loss_beam_pipe(cur_ind, btl_ind, rf_ind) = 0;
                extrap_data.diff_machine_conds.loss_signal_ports(cur_ind, btl_ind, rf_ind) = 0;
                extrap_data.diff_machine_conds.loss_structure(cur_ind, btl_ind, rf_ind) = 0;
            else
                extrap_data.diff_machine_conds.loss_beam_pipe(cur_ind, btl_ind, rf_ind) = Total_energy_from_beam_ports ./ Total_bunch_energy_loss;
                extrap_data.diff_machine_conds.loss_signal_ports(cur_ind, btl_ind, rf_ind) = Total_energy_from_signal_ports ./ Total_bunch_energy_loss;
                extrap_data.diff_machine_conds.loss_structure(cur_ind, btl_ind, rf_ind) = 1 - ((Total_energy_from_beam_ports+ Total_energy_from_signal_ports)./ Total_bunch_energy_loss);
            end
            clear elpt wlf elpb_ports wake_loss_factor bunch_charge bunch_length pulse power_loss pwr tmp bunch_spec
        end
    end
end
extrap_data.diff_machine_conds.f_raw = f_raw_bc;
extrap_data.diff_machine_conds.wake_impedance = wakeimpedance_bc;
if port_data.total_energy >0
    extrap_data.diff_machine_conds.port_impedances = port_impedances_bc;
end