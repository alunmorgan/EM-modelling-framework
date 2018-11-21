function frequency_domain_data = frequency_domain_analysis(...
    cut_off_freqs, time_domain_data, port_data, log, hfoi, mode_overrides)
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
    frequency_domain_data.Wake_Impedance_trans_X = NaN;
    frequency_domain_data.Wake_Impedance_trans_Y = NaN;
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

% Zero pad the data to improve the shape representation.
[timebase, Charge_distribution] = ...
    pad_data(time_domain_data.timebase, 14, 'points', ...
    time_domain_data.charge_distribution);
[~, WakePotential] = ...
    pad_data(time_domain_data.timebase, 14, 'points', ...
    time_domain_data.wakepotential);
[~, WakePotential_X] = ...
    pad_data(time_domain_data.timebase, 14, 'points', ...
    time_domain_data.wakepotential_trans_x);
[~, WakePotential_Y] = ...
    pad_data(time_domain_data.timebase, 14, 'points', ...
    time_domain_data.wakepotential_trans_y);

if isstruct(port_data)
    % This puts the time domain port signals on the same timebase as the rest
    % of the time domain signals.
    [ port_signals] = put_on_reference_timebase(time_domain_data.timebase, port_data);
    [~, port_signals] = ...
        pad_data(time_domain_data.timebase, 14, 'points', port_signals);
else
    port_signals = NaN;
end

% All the impedance calculations use 1C as a reference.
[f_raw,bunch_spectra,...
    Wake_Impedance_data, Wake_Impedance_data_im] = ...
    convert_wakepotential_to_wake_impedance(Charge_distribution, ...
    WakePotential, timebase);
[~,~, Wake_Impedance_data_X, Wake_Impedance_data_im_X] = ...
    convert_wakepotential_to_wake_impedance(Charge_distribution, ...
    WakePotential_X, timebase);
[~,~, Wake_Impedance_data_Y, Wake_Impedance_data_im_Y] = ...
    convert_wakepotential_to_wake_impedance(Charge_distribution, ...
    WakePotential_Y, timebase);

if ~iscell(port_signals)
    port_impedances = NaN;
else
    port_impedances = calculate_port_impedances(port_signals, cut_off_freqs,...
        timebase, f_raw, bunch_spectra);
end

% Remove all data above the highest frequency of interest (hfoi).

% scaling for the bunch spectra
% Could either take the appropriate section from both the upper and lowver
% side of the FFT, or just multiply by sqrt(2) as it is an amplitude.
% (and ignore the small error due to counting DC twice).
bunch_spectra = bunch_spectra .* sqrt(2);

[bunch_spectra, f_raw] = trim_to_hfoi(bunch_spectra, f_raw,  hfoi);
[Wake_Impedance_data, ~] = trim_to_hfoi(Wake_Impedance_data, f_raw,  hfoi);
[Wake_Impedance_data_im, ~] = trim_to_hfoi(Wake_Impedance_data_im, f_raw,  hfoi);
[Wake_Impedance_data_X, ~] = trim_to_hfoi(Wake_Impedance_data_X, f_raw,  hfoi);
[Wake_Impedance_data_im_X, ~] = trim_to_hfoi(Wake_Impedance_data_im_X, f_raw,  hfoi);
[Wake_Impedance_data_Y, ~] = trim_to_hfoi(Wake_Impedance_data_Y, f_raw,  hfoi);
[Wake_Impedance_data_im_Y, ~] = trim_to_hfoi(Wake_Impedance_data_im_Y, f_raw,  hfoi);

if ~isnan(port_impedances)
    if  sum(size(port_impedances) == [1, 1]) == 0
        [port_impedances, ~] = trim_to_hfoi(port_impedances, f_raw,  hfoi);
    end
end

%
% [f_raw,bunch_spectra,...
%     Wake_Impedance_data,...
%     Wake_Impedance_data_im,...
%     port_impedances] = ...
%     regenerate_f_data(Charge_distribution, ...
%     WakePotential, ...
%     port_signals, cut_off_freqs,...
%     timebase, hfoi);

% The outputs from this function are for the model charge.
% except for the wake loss factor which is V/C
[wlf, ...
    Bunch_loss_energy_spectrum, Total_bunch_energy_loss,...
    beam_port_spectrum, Total_energy_from_beam_ports,...
    signal_port_spectrum, Total_energy_from_signal_ports,...
    Total_port_spectrum, Total_energy_from_all_ports,...
    raw_port_energy_spectrum] = ...
    find_wlf_and_power_loss(log.charge, timebase, bunch_spectra, ...
    Wake_Impedance_data, port_impedances);
%%%%%%%%%%%
[peaks, Q, bw] = find_Qs(f_raw, Bunch_loss_energy_spectrum, 25);

frequency_domain_data.f_raw = f_raw;
frequency_domain_data.Wake_Impedance_data = Wake_Impedance_data;
frequency_domain_data.Wake_Impedance_data_im = Wake_Impedance_data_im;
frequency_domain_data.Wake_Impedance_trans_X = Wake_Impedance_data_X;
frequency_domain_data.Wake_Impedance_trans_im_X = Wake_Impedance_data_im_X;
frequency_domain_data.Wake_Impedance_trans_Y = Wake_Impedance_data_Y;
frequency_domain_data.Wake_Impedance_trans_im_Y = Wake_Impedance_data_im_Y;
frequency_domain_data.wlf = wlf;
frequency_domain_data.bunch_spectra = bunch_spectra;
frequency_domain_data.Bunch_loss_energy_spectrum = Bunch_loss_energy_spectrum;
frequency_domain_data.BLPS_peaks = peaks;
frequency_domain_data.BLPS_Qs = Q;
frequency_domain_data.BLPS_bw = bw;
frequency_domain_data.Total_bunch_energy_loss = Total_bunch_energy_loss;
if exist('port_signals','var')
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
    frequency_domain_data.raw_port_energy_spectrum = raw_port_energy_spectrum;
end