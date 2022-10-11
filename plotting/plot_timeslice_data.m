function plot_timeslice_data(time_slice_data, prefix, fig_pos, output_folder)

h_wake = figure('Position',fig_pos);
slice_length = round(time_slice_data.timestep*time_slice_data.slice_length*1e9*10)/10;
clf(h_wake)
ax = axes('Parent', h_wake);
imagesc(1:time_slice_data.n_slices, time_slice_data.fscale * 1E-9, abs(time_slice_data.ffts))
title(['Time sliced spectrum (', num2str(slice_length), 'ns slice length)'], 'Parent', ax)
ylabel('Frequency (GHz)', 'Parent', ax)
xlabel('Slice', 'Parent', ax)
savemfmt(h_wake, output_folder, [prefix, 'Time_slices'])
close(h_wake)