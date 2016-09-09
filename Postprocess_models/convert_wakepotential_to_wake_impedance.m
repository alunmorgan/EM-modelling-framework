function [f_raw,bunch_spectra,...
    wakeimpedance, wakeimpedance_IM] = ...
    convert_wakepotential_to_wake_impedance(Charge_distribution, ...
    wakepotential, timescale)
% This function takes in the Wake potential and the charge distribution and
% returns the wake impedance.
%
% INPUTS
% Charge_distribution is the shape of the bunch used in the simulation.
% wakepotential is the wake potential
% timescale is the timescale.
%
% OUTPUTS
% f_raw is the frequecy scale in Hz.
% bunch_spectra is the bunch spectrum
% wakeimpedance is the real part of the wake impedance.
% wakeimpedance_IM is the imaginary part of the wake impedance.
%
% Example: [f_raw,bunch_spectra, wakeimpedance, wakeimpedance_IM] = 
%    convert_wakepotential_to_wake_impedance(Charge_distribution, 
%    wakepotential, timescale)

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
