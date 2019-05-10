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
% Calculating the bunch spectra for a 1C charge.
bunch_spectra = fft(Charge_distribution)/n_freq_points;
fft_wp = fft(wakepotential)/n_freq_points;
% In order to get the proper impedence you need divide the fft of
%the wake potential by the bunch spectrum. We take the real as this
%corresponds to resistive losses.
wakeimpedance =  - real(fft_wp ./ bunch_spectra);
wakeimpedance_IM =  - imag(fft_wp ./ bunch_spectra);

% Remove all data above the highest frequency of interest (hfoi).
% Could either take the appropriate section from both the upper and lowver
% side of the FFT, or just multiply by sqrt(2) as it is an amplitude.
% (and ignore the small error due to counting DC twice).
hf_ind = find(f_raw > hfoi, 1, 'first');
f_raw = f_raw(1:hf_ind);
bunch_spectra = bunch_spectra(1:hf_ind) .*sqrt(2);
wakeimpedance = wakeimpedance(1:hf_ind);
wakeimpedance_IM = wakeimpedance_IM(1:hf_ind);


if iscell(port_data)
    for nsf = length(port_data):-1:1% number of ports
        if sum(isnan(port_data{nsf})) > 0
            port_impedances = NaN;
            port_mode_fft{nsf} = NaN;
        else
            port_data{nsf} = cat(1,port_data{nsf},zeros(length(timescale) - ...
                size(port_data{nsf},1), size(port_data{nsf},2)));
            % Calculating the fft of the port signals
            port_mode_fft_temp = fft(port_data{nsf},[],1)./n_freq_points;
            % truncating to below the higest frequency of interest.
            port_mode_fft{nsf} = port_mode_fft_temp(1:hf_ind,:);
            clear port_mode_fft_temp
            if isempty(cut_off_freqs) == 0
                % setting all values below the cutoff frequency for each port and mode to
                % zero.
                for esns = length(cut_off_freqs{nsf}):-1:1 % number of modes
                    tmp_ind = find(f_raw < cut_off_freqs{nsf}(esns),1,'last');
                    % TEST
                    % move the index n samples above cutoff to reduce the effect of
                    % phase runaway. (set to zero now as I think that the error
                    % committed doing this is larger than the error I am trying to
                    % remove. If it is a gibbs like phenomina then the integral will be
                    % correct so the energy losses and power will be correct even if
                    % the cumulative sum graphs show some drops.)
%                     n = 0;
%                     tmp_ind = tmp_ind +n;
                    if tmp_ind < length(f_raw)
                        %end_ind = length(f_raw);
                        port_mode_fft{nsf}(1:tmp_ind,  esns) = 0;
                        %port_mode_fft{nsf}(end_ind - tmp_ind+2:end_ind,  esns) = 0;
                    end %if
                    clear tmp_ind
                end %for
                clear esns n
            end %if
            % The transfer impedance at the ports is found using P = I^2 * Z. So the
            % impedance is the power seen at the ports divided by the bunch spectra squared.
            %     We take the real part as this corresponds to resistive losses.
            % take the abs because.....not quite sure if that is correct,however the
            % port impedance is oscillating around 0 otherwise.????
            port_impedances(:,nsf) = real(sum(abs(port_mode_fft{nsf}).^2,2)) ./...
                abs(bunch_spectra).^2;
        end %if
    end %for
%     if sum(size(port_impedances) == [1, 1]) == 0
%         port_impedances = port_impedances(1:hf_ind,:);
%     end
else
     port_impedances = NaN;
end %if


