function [cut_ind, first_peak_amplitude] = separate_bunch_from_remenent_field(timescale, data, bunch_sigma, n_sigmas)
% find the location of the first peak in the signal. 
%   Args:
%       timescale (vector of floats): 
%       data (vector of floats):
%       bunch_sigma (str): The length of the bunch in m
%       n_sigmas (int): the number of sigmas after the peak to set the cut point. 
%   Returns:
%       The cut index n_sigmas after the first peak.
%
% Example: cut_ind = separate_bunch_from_remenent_field(timescale, data, bunch_sigma, n_sigmas)

flips = sign(diff(data));
noise_blanking = find(abs(data) >1E-9,1,'first');
flips(1:noise_blanking) = 0;
shifted_flips = circshift(flips,1,1);
crossings_down = find(flips == 1 & shifted_flips == -1);
crossings_up = find(flips == -1 & shifted_flips == 1);
crossings = union(crossings_up, crossings_down);
if isempty(crossings)
    first_peak_ind = 1;
else
    first_peak_ind = crossings(1);
end %if
first_peak_amplitude = data(first_peak_ind);
time_of_first_peak = timescale(first_peak_ind);
cut_time = time_of_first_peak + n_sigmas * str2double(bunch_sigma) / 3E8;
cut_ind = find(timescale > cut_time, 1, 'first');
if isempty(cut_ind)
    % there is no remnent data
    cut_ind = length(timescale);
end %if

