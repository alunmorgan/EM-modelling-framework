function GdfidL_plot_s_parameters(path_to_data, fig_pos)
% plots the s parameter results.
%
% Example: GdfidL_plot_s_parameters(s, ppi, fig_pos, pth)

 [pth, ~,~] = fileparts(path_to_data);
load(fullfile(fullfile(pth,'data_postprocessed.mat')), 'pp_data'); % contains pp_data

lines = {'--',':','-.','-'};
cols_sep = {'y','k','r','b','g','c','m'};
lower_cutoff = -80;
linewidth = 2;

plot_s_param_graph(pp_data, cols_sep, fig_pos, pth, lower_cutoff, linewidth)

if size(pp_data.all_ports,1) > 3
    % Only generate the transmission graphs if there is more than 1 signal port.
    plot_s_param_transmission_graphs_modes(pp_data, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth)
end %if

if size(pp_data.all_ports,1) > 3
    % Only generate the transmission graphs if there is more than 1 signal port.
 plot_s_parameter_transmission_graphs_port(pp_data, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth)
end %if

plot_s_parameter_reflection_graph(pp_data, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth)
