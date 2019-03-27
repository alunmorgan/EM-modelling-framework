function [frequency_scale, spectra, peaks, n_slices, slice_length, slice_timestep] = extract_time_slice_results_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%

n_slices = wake_data.frequency_domain_data.time_slices.n_slices;
frequency_scale = wake_data.frequency_domain_data.time_slices.fscale * 1e-9; %ns
spectra = wake_data.frequency_domain_data.time_slices.ffts;
peaks = wake_data.frequency_domain_data.time_slices.peaks; %J
if ~isempty(peaks)
    peaks(:,1) = peaks(:,1) * 1E-9; %nJ
end %if

slice_length = wake_data.frequency_domain_data.time_slices.slice_length;
slice_timestep = wake_data.frequency_domain_data.time_slices.timestep;