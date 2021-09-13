function frequency_domain_data = frequency_domain_analysis(time_domain_data, port_frequency_data, log, hfoi)
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

%% Port analysis
% hfoi_ind = find(f_raw > hfoi,1,'first');
for hsw = 1:length(port_frequency_data)
    port_f_data_temp = interp1(port_frequency_data{hsw}(1:end-1,1), port_frequency_data{hsw}(1:end-1,2),f_raw ) ;
    port_f_data(hsw,:) = port_f_data_temp';
    port_impedances_temp = port_f_data(hsw,:) ./abs(bunch_spectra).^2;
    port_impedances_temp = trim_to_hfoi(port_impedances_temp', f_raw,  hfoi);
    port_impedances(hsw,:) = port_impedances_temp';
end %for
%     port_impedance_data = calculate_port_impedances(time_domain_data.port_data,...
%         port_frequency_data, f_raw, bunch_spectra);
    
   
%     substructure = fieldnames(port_impedance_data);
    
%     for hse = 1:length(substructure)
%         sub_substructure = fieldnames(port_impedance_data.(substructure{hse}));
%         for smw = 1:length(sub_substructure)
%             port_impedance_data.(substructure{hse}).(sub_substructure{smw}).port_impedances = port_impedances';
%             port_impedance_data.(substructure{hse}).(sub_substructure{smw}).port_mode_impedances(:,:,hfoi_ind:end) = 0;
%         end %for
%         port_energy_fft{hse} = abs(fft(time_domain_data.port_data.(substructure{hse}).port_mode_energy_time, length(f_raw),3));
%         port_energy_fft{hse}(:, :, hfoi_ind:end) = 0;
%     end %for

%% scaling for the bunch spectra
% Could either take the appropriate section from both the upper and lower
% side of the FFT, or just multiply by sqrt(2) as it is an amplitude.
% (and ignore the small error due to counting DC twice).
bunch_spectra = bunch_spectra .* sqrt(2);

%% Remove all data above the highest frequency of interest (hfoi).
Wake_Impedance_data = trim_to_hfoi(Wake_Impedance_data, f_raw,  hfoi);
Wake_Impedance_data_im = trim_to_hfoi(Wake_Impedance_data_im, f_raw,  hfoi);
Wake_Impedance_data_quad_X = trim_to_hfoi(Wake_Impedance_data_quad_X, f_raw,  hfoi);
Wake_Impedance_data_im_quad_X = trim_to_hfoi(Wake_Impedance_data_im_quad_X, f_raw,  hfoi);
Wake_Impedance_data_quad_Y = trim_to_hfoi(Wake_Impedance_data_quad_Y, f_raw,  hfoi);
Wake_Impedance_data_im_quad_Y = trim_to_hfoi(Wake_Impedance_data_im_quad_Y, f_raw,  hfoi);
Wake_Impedance_data_dipole_X = trim_to_hfoi(Wake_Impedance_data_dipole_X, f_raw,  hfoi);
Wake_Impedance_data_im_dipole_X = trim_to_hfoi(Wake_Impedance_data_im_dipole_X, f_raw,  hfoi);
Wake_Impedance_data_dipole_Y = trim_to_hfoi(Wake_Impedance_data_dipole_Y, f_raw,  hfoi);
Wake_Impedance_data_im_dipole_Y = trim_to_hfoi(Wake_Impedance_data_im_dipole_Y, f_raw,  hfoi);
bunch_spectra = trim_to_hfoi(bunch_spectra, f_raw,  hfoi);

% The outputs from this function are for the model charge.
% except for the wake loss factor which is V/C
[wlf, Bunch_loss_energy_spectrum, Total_bunch_energy_loss] = ...
    find_wlf_and_power_loss(log.charge, time_domain_data.timebase, bunch_spectra, ...
    Wake_Impedance_data);
% [beam_port_spectrum, Total_energy_from_beam_ports,...
%     signal_port_spectrum, Total_energy_from_signal_ports,...
%     Total_port_spectrum, Total_energy_from_all_ports] = ...
%     find_port_power_loss(port_energy_fft);
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
% if exist('port_data','var')
    frequency_domain_data.Total_port_spectrum = sum(port_f_data,1);
    frequency_domain_data.signal_port_spectrum = sum(port_f_data(1:2,:),1);
    frequency_domain_data.beam_port_spectrum = sum(port_f_data(3:end,:),1);
    frequency_domain_data.port_impedances = port_impedances;
    frequency_domain_data.port_specatra = port_f_data;
% end