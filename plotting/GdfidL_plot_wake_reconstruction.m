function GdfidL_plot_wake_reconstruction(files_to_load, ppi, output_folder, prefix)
% Generate the graphs based on the wake simulation data.
% Graphs are saved in fig format and png, eps.
%
% output_folder is where the resulting files are saved to.
% range is to do with peak identification for Q values, and
% is the separation peaks have to have to be counted as separate.
%
% Example GdfidL_plot_wake_reconstruction(files_to_load, ppi, output_folder, prefix)

for rnf = 1:size(files_to_load,1)
    if exist(files_to_load{rnf,1}, 'file') == 2
        load(files_to_load{rnf,1}, files_to_load{rnf,2}{:});
    else
        disp(['Unable to load ', files_to_load{rnf,1}])
        return
    end %if
end %for
%Line width of the graphs
lw = 2;
% limit to the horizontal axis.
graph_freq_lim = ppi.hfod * 1e-9;
% location and size of the default figures.
fig_width = 800;
fig_height = 600;
fig_left = 10560 - fig_width;
fig_bottom = 1098 - fig_height;
fig_pos = [fig_left fig_bottom fig_width fig_height];

prefix_wls = [prefix, '_reconstruction_wake_length_sweep_'];
plot_wake_sweep(wake_sweep_data, prefix_wls, fig_pos, graph_freq_lim, lw, output_folder)

prefix_bls = [prefix, '_reconstruction_bunch_length_sweep_'];
plot_bunch_length_sweep(bunch_length_sweep_data, prefix_bls, fig_pos, graph_freq_lim, lw, output_folder)

plot_timeslice_data(time_slice_data, prefix, fig_pos, output_folder)

%% machine parameter sweeps 
plot_machine_parameter_sweeps(bunch_charge_sweep_data, ppi, prefix, fig_pos, graph_freq_lim, lw, output_folder)

