function frequency_domain_data = frequency_domain_analysis(...
    cut_off_freqs, time_domain_data, port_data, log, hfoi)
% Takes the time domain results and does additional frequency domain
% analysis on it.
%
% cut_off_freqs is a list of the port cut off frequecies
% time_domain_data is a structure containing the time domain results.
% port_data is a structure contianing the time domain port results.
% log a structure containing the setup information of the simulation.
% hfoi is the highest frequency of interest. The frequency analysis is only
% done below this frequency.
%
% Example: frequency_domain_data = frequency_domain_analysis(...
%     cut_off_freqs, time_domain_data, port_data,log, hfoi)

if length(time_domain_data.timebase) <2
    % Not enough data
    frequency_domain_data.f_raw = NaN;
    frequency_domain_data.Wake_Impedance_data = NaN;
    frequency_domain_data.Wake_Impedance_trans_quad_X = NaN;
    frequency_domain_data.Wake_Impedance_trans_quad_Y = NaN;
    frequency_domain_data.Wake_Impedance_trans_dipole_X = NaN;
    frequency_domain_data.Wake_Impedance_trans_dipole_Y = NaN;
    frequency_domain_data.Wake_Impedance_trans_im_quad_X = NaN;
    frequency_domain_data.Wake_Impedance_trans_im_quad_Y = NaN;
    frequency_domain_data.Wake_Impedance_trans_im_dipole_X = NaN;
    frequency_domain_data.Wake_Impedance_trans_im_dipole_Y = NaN;
    frequency_domain_data.wlf = NaN;
    frequency_domain_data.bunch_spectra = NaN;
    frequency_domain_data.Total_power_spectrum = NaN;
    frequency_domain_data.signal_port_spectrum = NaN;
    frequency_domain_data.beam_port_spectrum = NaN;
    frequency_domain_data.Bunch_loss_power_spectrum = NaN;
    frequency_domain_data.BLPS_peaks = NaN;
    frequency_domain_data.BLPS_Qs = NaN;
    frequency_domain_data.BLPS_bw = NaN;
    frequency_domain_data.Total_power_from_ports = NaN;
    frequency_domain_data.Total_power_from_signal_ports = NaN;
    frequency_domain_data.Total_power_from_beam_ports = NaN;
    frequency_domain_data.Total_bunch_power_loss = NaN;
    frequency_domain_data.fractional_loss_beam_ports = NaN;
    frequency_domain_data.fractional_loss_signal_ports = NaN;
    frequency_domain_data.fractional_loss_structure = NaN;
    frequency_domain_data.port_mode_fft = NaN;
    frequency_domain_data.port_impedances = NaN;
    frequency_domain_data.port_fft = NaN;
    frequency_domain_data.raw_port_power_spectrum = NaN;
    %     frequency_domain_data.raw_port_power_from_all_ports = NaN;
    return
end


%%%%%%%%%%%%%%%%%
% In order to easily compare and do mathematical operations in frequency
% space it is necessary to put all the time data on the same timebase
% before converting with the FFT.
if nargin >5 % There are overrides to the number of port modes to be used.
    for dl = 1:length(overrides)
        port_data.data{dl} = port_data.data{dl}(:,1:overrides(dl));
    end %for
end %if

% finding where the index of the "end" of the charge is
% [max_charge, max_charge_index] = max(time_domain_data.charge_distribution);
% charge_end_index_temp = find(time_domain_data.charge_distribution(max_charge_index:end) < max_charge ./1E4, 1,'first');
% charge_end_index = charge_end_index_temp + max_charge_index;
% wakepotential_temp = time_domain_data.wakepotential;
% wakepotential_tqx_temp = time_domain_data.wakepotential_trans_quad_x;
% wakepotential_tqy_temp = time_domain_data.wakepotential_trans_quad_y;
% wakepotential_tdx_temp = time_domain_data.wakepotential_trans_dipole_x;
% wakepotential_tdy_temp = time_domain_data.wakepotential_trans_dipole_y;
% %Taking away the mean value to reduce the DC component -- IS this valid?
% % If there is a large DC offset then padding with zeros causes strong
% % ringing in the impedance data.
% % this should not be required for on axis measurements.
% wakepotential_temp = time_domain_data.wakepotential - mean(time_domain_data.wakepotential);
% wakepotential_tqx_temp = time_domain_data.wakepotential_trans_quad_x - mean(time_domain_data.wakepotential_trans_quad_x(charge_end_index:end));
% wakepotential_tqy_temp = time_domain_data.wakepotential_trans_quad_y - mean(time_domain_data.wakepotential_trans_quad_y(charge_end_index:end));
% wakepotential_tdx_temp = time_domain_data.wakepotential_trans_dipole_x - mean(time_domain_data.wakepotential_trans_dipole_x(charge_end_index:end));
% wakepotential_tdy_temp = time_domain_data.wakepotential_trans_dipole_y - mean(time_domain_data.wakepotential_trans_dipole_y(charge_end_index:end));

% % blanking out the period where the bunch is in the structure
% % for the wake we are more interested in the response after the bunch has
% % left.
% wakepotential_temp(1:charge_end_index) = 0;
% wakepotential_tqx_temp(1:charge_end_index) = 0;
% wakepotential_tqy_temp(1:charge_end_index) = 0;
% wakepotential_tdx_temp(1:charge_end_index) = 0;
% wakepotential_tdy_temp(1:charge_end_index) = 0;

% % in order to reduce artifacts we want to end the blanking at a zero
% % crossing point.
% wakepotential_temp = blank_to_first_zero_crossing(wakepotential_temp);
% wakepotential_tqx_temp = blank_to_first_zero_crossing(wakepotential_tqx_temp);
% wakepotential_tqy_temp = blank_to_first_zero_crossing(wakepotential_tqy_temp);
% wakepotential_tdx_temp = blank_to_first_zero_crossing(wakepotential_tdx_temp);
% wakepotential_tdy_temp = blank_to_first_zero_crossing(wakepotential_tdy_temp);

%FIXME
% % Zero pad the data to improve the shape representation.
% [timebase, Charge_distribution] = ...
%     pad_data(time_domain_data.timebase, 14, 'points', ...
%     time_domain_data.charge_distribution);
% [~, WakePotential] = ...
%     pad_data(time_domain_data.timebase, 14, 'points', wakepotential_temp);
% [~, WakePotential_quad_X] = ...
%     pad_data(time_domain_data.timebase, 14, 'points', wakepotential_tqx_temp);
% [~, WakePotential_quad_Y] = ...
%     pad_data(time_domain_data.timebase, 14, 'points', wakepotential_tqy_temp);
% [~, WakePotential_dipole_X] = ...
%     pad_data(time_domain_data.timebase, 14, 'points', wakepotential_tdx_temp);
% [~, WakePotential_dipole_Y] = ...
%     pad_data(time_domain_data.timebase, 14, 'points', wakepotential_tdy_temp);

% if isstruct(port_data)
%     % This puts the time domain port signals on the same timebase as the rest
%     % of the time domain signals.
%     [ port_signals] = put_on_reference_timebase(time_domain_data.timebase, port_data);
%     [~, port_signals] = ...
%         pad_data(time_domain_data.timebase, 14, 'points', port_signals);
% else
%     port_signals = NaN;
% end

% All the impedance calculations use 1C as a reference.
[f_raw,bunch_spectra,...
    Wake_Impedance_data, Wake_Impedance_data_im] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential, time_domain_data.timebase);

[~,~, Wake_Impedance_data_quad_X, Wake_Impedance_data_im_quad_X] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential_trans_quad_x, time_domain_data.timebase);

[~,~, Wake_Impedance_data_quad_Y, Wake_Impedance_data_im_quad_Y] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential_trans_quad_y, time_domain_data.timebase);

[~,~, Wake_Impedance_data_dipole_X, Wake_Impedance_data_im_dipole_X] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential_trans_dipole_x, time_domain_data.timebase);

[~,~, Wake_Impedance_data_dipole_Y, Wake_Impedance_data_im_dipole_Y] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential_trans_dipole_y, time_domain_data.timebase);

% if isstruct(port_data)
% port_signals = NaN;
% end %if
if ~iscell(port_data)
    port_impedances = NaN;
else
    [port_impedances, port_fft] = calculate_port_impedances(port_data, cut_off_freqs,...
        time_domain_data.timebase, f_raw, bunch_spectra);
end

% Remove all data above the highest frequency of interest (hfoi).

% scaling for the bunch spectra
% Could either take the appropriate section from both the upper and lower
% side of the FFT, or just multiply by sqrt(2) as it is an amplitude.
% (and ignore the small error due to counting DC twice).
bunch_spectra = bunch_spectra .* sqrt(2);


[Wake_Impedance_data, ~] = trim_to_hfoi(Wake_Impedance_data, f_raw,  hfoi);
[Wake_Impedance_data_im, ~] = trim_to_hfoi(Wake_Impedance_data_im, f_raw,  hfoi);
[Wake_Impedance_data_quad_X, ~] = trim_to_hfoi(Wake_Impedance_data_quad_X, f_raw,  hfoi);
[Wake_Impedance_data_im_quad_X, ~] = trim_to_hfoi(Wake_Impedance_data_im_quad_X, f_raw,  hfoi);
[Wake_Impedance_data_quad_Y, ~] = trim_to_hfoi(Wake_Impedance_data_quad_Y, f_raw,  hfoi);
[Wake_Impedance_data_im_quad_Y, ~] = trim_to_hfoi(Wake_Impedance_data_im_quad_Y, f_raw,  hfoi);
[Wake_Impedance_data_dipole_X, ~] = trim_to_hfoi(Wake_Impedance_data_dipole_X, f_raw,  hfoi);
[Wake_Impedance_data_im_dipole_X, ~] = trim_to_hfoi(Wake_Impedance_data_im_dipole_X, f_raw,  hfoi);
[Wake_Impedance_data_dipole_Y, ~] = trim_to_hfoi(Wake_Impedance_data_dipole_Y, f_raw,  hfoi);
[Wake_Impedance_data_im_dipole_Y, ~] = trim_to_hfoi(Wake_Impedance_data_im_dipole_Y, f_raw,  hfoi);
if ~isnan(port_impedances)
    if  sum(size(port_impedances) == [1, 1]) == 0
        [port_impedances, ~] = trim_to_hfoi(port_impedances, f_raw,  hfoi);
        [port_fft, ~] = trim_to_hfoi(port_fft, f_raw,  hfoi);
    end
end
[bunch_spectra, f_raw] = trim_to_hfoi(bunch_spectra, f_raw,  hfoi);

% The outputs from this function are for the model charge.
% except for the wake loss factor which is V/C
[wlf, ...
    Bunch_loss_energy_spectrum, Total_bunch_energy_loss,...
    beam_port_spectrum, Total_energy_from_beam_ports,...
    signal_port_spectrum, Total_energy_from_signal_ports,...
    Total_port_spectrum, Total_energy_from_all_ports,...
    raw_port_energy_spectrum] = ...
    find_wlf_and_power_loss(log.charge, time_domain_data.timebase, bunch_spectra, ...
    Wake_Impedance_data, port_impedances, port_fft);
%%%%%%%%%%%
[peaks, Q, bw] = find_Qs(f_raw, Bunch_loss_energy_spectrum, 25);

frequency_domain_data.f_raw = f_raw;
frequency_domain_data.Wake_Impedance_data = Wake_Impedance_data;
frequency_domain_data.Wake_Impedance_data_im = Wake_Impedance_data_im;
frequency_domain_data.Wake_Impedance_trans_quad_X = Wake_Impedance_data_quad_X;
frequency_domain_data.Wake_Impedance_trans_im_quad_X = Wake_Impedance_data_im_quad_X;
frequency_domain_data.Wake_Impedance_trans_quad_Y = Wake_Impedance_data_quad_Y;
frequency_domain_data.Wake_Impedance_trans_im_quad_Y = Wake_Impedance_data_im_quad_Y;
frequency_domain_data.Wake_Impedance_trans_dipole_X = Wake_Impedance_data_dipole_X;
frequency_domain_data.Wake_Impedance_trans_im_dipole_X = Wake_Impedance_data_im_dipole_X;
frequency_domain_data.Wake_Impedance_trans_dipole_Y = Wake_Impedance_data_dipole_Y;
frequency_domain_data.Wake_Impedance_trans_im_dipole_Y = Wake_Impedance_data_im_dipole_Y;
frequency_domain_data.wlf = wlf;
frequency_domain_data.bunch_spectra = bunch_spectra;
frequency_domain_data.Bunch_loss_energy_spectrum = Bunch_loss_energy_spectrum;
frequency_domain_data.BLPS_peaks = peaks;
frequency_domain_data.BLPS_Qs = Q;
frequency_domain_data.BLPS_bw = bw;
frequency_domain_data.Total_bunch_energy_loss = Total_bunch_energy_loss;
if exist('port_data','var')
    frequency_domain_data.Total_port_spectrum = Total_port_spectrum;
    frequency_domain_data.signal_port_spectrum = signal_port_spectrum;
    frequency_domain_data.beam_port_spectrum = beam_port_spectrum;
    frequency_domain_data.Total_energy_from_ports = Total_energy_from_all_ports;
    frequency_domain_data.Total_energy_from_signal_ports = Total_energy_from_signal_ports;
    frequency_domain_data.Total_energy_from_beam_ports = Total_energy_from_beam_ports;
    frequency_domain_data.fractional_loss_beam_ports = Total_energy_from_beam_ports ./Total_bunch_energy_loss;
    frequency_domain_data.fractional_loss_signal_ports = Total_energy_from_signal_ports ./Total_bunch_energy_loss;
    frequency_domain_data.fractional_loss_structure = 1 - frequency_domain_data.fractional_loss_beam_ports - frequency_domain_data.fractional_loss_signal_ports;
    frequency_domain_data.port_impedances = port_impedances;
    frequency_domain_data.port_fft = port_fft;
    frequency_domain_data.raw_port_energy_spectrum = raw_port_energy_spectrum;
end