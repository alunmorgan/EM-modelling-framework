function [frequency_scale, spectra, peaks_start, peaks_end, n_slices, slice_length, slice_timestep] = ...
    extract_time_slice_results_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%

n_slices = wake_data.frequency_domain_data.time_slices.n_slices;
frequency_scale = wake_data.frequency_domain_data.time_slices.fscale * 1e-9; %ns
spectra = wake_data.frequency_domain_data.time_slices.ffts;
peaks_end = wake_data.frequency_domain_data.time_slices.peaks_end; %J
if ~isempty(peaks_end)
    peaks_end(:,1) = peaks_end(:,1) * 1E-9; %nJ
end %if

peaks_start = wake_data.frequency_domain_data.time_slices.peaks_end; %J
if ~isempty(peaks_start)
    peaks_start(:,1) = peaks_start(:,1) * 1E-9; %nJ
end %if

slice_length = wake_data.frequency_domain_data.time_slices.slice_length;
slice_timestep = wake_data.frequency_domain_data.time_slices.timestep;
