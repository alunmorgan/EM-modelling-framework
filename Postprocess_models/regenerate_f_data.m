function [f_raw,bunch_spectra,...
    wakeimpedance, wakeimpedance_IM,...
    port_impedances] = ...
    regenerate_f_data(Charge_distribution, ...
    wakepotential, ...
    port_data, cut_off_freqs,...
    timescale, hfoi)
% Takes the time domain data and converts it into frequency domain data.
%
% INPUTS
% Charge_distribution is the time domain distribution of the bunch.
% wakepotential is the wake potential.
% port_data is the time signals from the ports. each cell is a port
% containing several modes.
% cut_off_freqs
% timescale is the timescale all the time domain data is based on.
% hfoi is the highest frequency of interest
%
% OUTPUTS
% f_raw
% bunch_spectra
% wakeimpedance
% wakeimpedance_IM is imaginary wake impedance.
% port_impedances
%
% Example: [f_raw,bunch_spectra,...
%     wakeimpedance, wakeimpedance_IM,...
%     port_impedances] = ...
%     regenerate_f_data(Charge_distribution, ...
%     wakepotential, ...
%     port_data, cut_off_freqs,...
%     timescale, hfoi)


% Find the step size (this should not change).
time_stepsize = abs(timescale(2) - timescale(1));
%% Regenerate the frequency domain data
% Create the corresponding frequency scale.
n_freq_points = length(timescale);
f_raw = (linspace(0,1,n_freq_points) / time_stepsize)';
% Remove all data above the highest frequency of interest (hfoi).
% Could either take the appropriate section from both the upper and lowver
% side of the FFT, or just multiply by sqrt(2) as it is an amplitude.
% (and ignore the small error due to counting DC twice).
% Doing the truncation after each variable is created in order to reduce
% the maximum memory footprint.
hf_ind = find(f_raw > hfoi, 1, 'first');
f_raw = f_raw(1:hf_ind);

% Calculating the bunch spectra for a 1C charge.
bunch_spectra = fft(Charge_distribution)/n_freq_points;
Charge_distribution = []; % Cannot use clear in a parfor loop but I need to reduce the size.
bunch_spectra = bunch_spectra(1:hf_ind) .*sqrt(2);

fft_wp = fft(wakepotential)/n_freq_points;
wakepotential = [];% Cannot use clear in a parfor loop but I need to reduce the size.
fft_wp = fft_wp(1:hf_ind);
% In order to get the proper impedence you need divide the fft of
%the wake potential by the bunch spectrum. We take the real as this
%corresponds to resistive losses.
wakeimpedance =  - real(fft_wp ./ bunch_spectra);
wakeimpedance_IM =  - imag(fft_wp ./ bunch_spectra);

fft_wp = []; % Cannot use clear in a parfor loop but I need to reduce the size.

if iscell(port_data)
    for nsf = 1:length(port_data)% number of ports
        single_port = port_data{nsf};
        if sum(isnan(single_port)) > 0
            port_impedances_one_mode = NaN;
            %             port_mode_fft = NaN;
        else
            single_port = cat(1,single_port,zeros(length(timescale) - ...
                size(single_port,1), size(single_port,2)));
            % Calculating the fft of the port signals
            for kef = 1:size(single_port, 2) % number of modes
                port_mode_fft_temp = fft(single_port(:,kef))./n_freq_points;
                % truncating to below the higest frequency of interest.
                port_mode_fft_temp = port_mode_fft_temp(1:hf_ind);
                if isempty(cut_off_freqs) == 0
                    % setting all values below the cutoff frequency for each port and mode to
                    % zero.
                    tmp_ind = find(f_raw < cut_off_freqs{nsf}(kef),1,'last');
                    % TEST
                    % move the index n samples above cutoff to reduce the effect of
                    % phase runaway. (set to zero now as I think that the error
                    % committed doing this is larger than the error I am trying to
                    % remove. If it is a gibbs like phenomina then the integral will be
                    % correct so the energy losses and power will be correct even if
                    % the cumulative sum graphs show some drops.)
                    if tmp_ind < length(f_raw)
                        port_mode_fft_temp(1:tmp_ind) = 0;
                    end %if
                end %if
                port_mode_fft(:,kef) = port_mode_fft_temp;
                port_mode_fft_temp= []; % Cannot use clear in a parfor loop but I need to reduce the size.
%                 single_port(:,kef) = [];% Cannot use clear in a parfor loop but I need to reduce the size.
            end
            
            % The transfer impedance at the ports is found using P = I^2 * Z. So the
            % impedance is the power seen at the ports divided by the bunch spectra squared.
            %     We take the real part as this corresponds to resistive losses.
            % take the abs because.....not quite sure if that is correct,however the
            % port impedance is oscillating around 0 otherwise.????
            port_impedances_one_mode = real(sum(abs(port_mode_fft).^2,2)) ./...
                abs(bunch_spectra).^2;
        end %if
        port_impedances(:,nsf) = port_impedances_one_mode;
        port_impedances_one_mode = [];% Cannot use clear in a parfor loop but I need to reduce the size.
    end %parfor
else
    port_impedances = NaN;
end %if


