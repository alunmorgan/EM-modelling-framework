function time_slices = time_slices(timebase, wakepotential, hfoi)
% Slice the time domain wakepotential into sections. FFT each section
% independently and track the evolution of the peaks across sections.
% This allows us to see the decay of resonances over time, and get a Q
% value for them.
%
% Example time_slices = time_slices(time_domain_data)


n_slices = 10;
slice_length = floor(length(timebase)/n_slices);
stepsize = timebase(3) - timebase(2);
% construct the frequency scale corresponding to one slice.
fscale = (linspace(0,1,slice_length) / stepsize);
fscale = fscale(1:floor(slice_length./2));
ind = find(fscale > hfoi,1,'first');
time_slices.fscale = fscale(1:ind);
time_slices.n_slices = n_slices;
time_slices.slice_length = slice_length;
tmp = wakepotential;
tmp = tmp(1:n_slices * slice_length); % trimming to fit slices exactly.
tmp = reshape(tmp,slice_length,n_slices);
tmp_fft = fft(tmp);
tmp_fft = tmp_fft(1:ind,:);
time_slices.ffts = tmp_fft;
time_slices.timestep = stepsize;
if isempty(tmp_fft)
    % usually this happens when the wakepotential is so short that
    % each slice contains only one point.
    time_slices.peaks_start = [];
    time_slices.peaks_end = [];
else
    if size(tmp,1) <5
        time_slices.peaks_start = [];
        time_slices.peaks_end = [];
    else
        tmp_peaks_start = findpeaks_n_point(time_slices.fscale,abs(tmp_fft(:,1)),5,5);
        if isempty(tmp_peaks_start)
            time_slices.peaks_start = [];
        else
            time_slices.peaks_start = ...
                tmp_peaks_start(tmp_peaks_start(:,2)> max(tmp_peaks_start(:,2)) .* 0.05,:);
        end
        tmp_peaks_end = findpeaks_n_point(time_slices.fscale,abs(tmp_fft(:,end)),5,5);
        if isempty(tmp_peaks_end)
            time_slices.peaks_end = [];
        else
            time_slices.peaks_end = ...
                tmp_peaks_end(tmp_peaks_end(:,2)> max(tmp_peaks_end(:,2)) .* 0.05,:);
        end
    end
end


