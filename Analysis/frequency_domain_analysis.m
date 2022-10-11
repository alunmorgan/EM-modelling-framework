function frequency_domain_data = frequency_domain_analysis(time_domain_data, log, n_bunches_in_input_pattern)
% Takes the time domain results and does additional frequency domain
% analysis on it.
%
% time_domain_data is a structure containing the time domain results.
% log a structure containing the setup information of the simulation.
% hfoi is the highest frequency of interest. The frequency analysis is only
% done below this frequency.
%
% Example: frequency_domain_data = frequency_domain_analysis(...
%      time_domain_data, log, hfoi)

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
    frequency_domain_data.port_mode_fft = NaN;
    frequency_domain_data.port_impedances = NaN;
    frequency_domain_data.port_fft = NaN;
    return
end


%%%%%%%%%%%%%%%%%

% All the impedance calculations use 1C as a reference.
[f_raw,bunch_spectra,...
    Wake_Impedance_data, Wake_Impedance_data_im] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential, time_domain_data.timebase);

[~,~, Wake_Impedance_data_X, Wake_Impedance_data_im_X] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential_trans_x, time_domain_data.timebase);

[~,~, Wake_Impedance_data_Y, Wake_Impedance_data_im_Y] = ...
    convert_wakepotential_to_wake_impedance(time_domain_data.charge_distribution, ...
    time_domain_data.wakepotential_trans_y, time_domain_data.timebase);

%% Port analysis
time_domain_data.port_data.power_port_mode.full_signal.port_mode_signals(isnan(time_domain_data.port_data.power_port_mode.full_signal.port_mode_signals)==1)=0;
port_mode_f_data = fft(time_domain_data.port_data.power_port_mode.full_signal.port_mode_signals,[],3);
bs = repmat(permute(bunch_spectra,[2,3,1]), size(port_mode_f_data,1), size(port_mode_f_data,2));
port_impedances = port_mode_f_data ./abs(bs).^2;
port_f_data = squeeze(sum(port_mode_f_data,2));

%% scaling for the bunch spectra
% Could either take the appropriate section from both the upper and lower
% side of the FFT, or just multiply by sqrt(2) as it is an amplitude.
% (and ignore the small error due to counting DC twice).
bunch_spectra = bunch_spectra .* sqrt(2);

% The outputs from this function are for the model charge.
% except for the wake loss factor which is V/C
[wlf, Bunch_loss_energy_spectrum, Total_bunch_energy_loss] = ...
    find_wlf_and_power_loss(log.charge, time_domain_data.timebase, bunch_spectra, ...
    Wake_Impedance_data, n_bunches_in_input_pattern);

[peaks, Q, bw] = find_Qs(f_raw, Bunch_loss_energy_spectrum, 25);

%% constructing the output data structure
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
frequency_domain_data.Total_port_spectrum = squeeze(sum(port_f_data,1));
frequency_domain_data.signal_port_spectrum = squeeze(sum(port_f_data(3:end,:),1));
frequency_domain_data.beam_port_spectrum = squeeze(sum(port_f_data(1:2,:),1));
frequency_domain_data.port_impedances = port_impedances;
frequency_domain_data.port_specatra = port_mode_f_data;
