function GdfidL_plot_s_parameters(path_to_data, fig_pos)
% plots the s parameter results.
%
% Example: GdfidL_plot_s_parameters(s, ppi, fig_pos, pth)
trim_fraction = 0; % NEEDS TO MOVE HIGHER IN THE STACK.
 [pth, ~,~] = fileparts(path_to_data);
 set_dirs = dir_list_gen(pth, 'dirs', 1);
 if exist(fullfile(set_dirs{1}, 'run_inputs.mat'), 'file') == 2
    load(fullfile(set_dirs{1}, 'run_inputs.mat'), 'modelling_inputs');
else
    disp(['Unable to load ', fullfile(set_dirs{1}, 'run_inputs.mat')])
    return
end %if
load(fullfile(fullfile(pth,'data_postprocessed.mat')), 'pp_data'); % contains pp_data

lines = {'--',':','-.','-'};
cols_sep = {'y','k','r','b','g','c','m'};
lower_cutoff = -120;
linewidth = 2;

plot_s_param_graph(pp_data, modelling_inputs.beam, cols_sep, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)
plot_s_parameter_reflection_graph(pp_data, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)

% Only generate the transmission graphs if there is more than 1 signal port.
if strcmp(modelling_inputs.beam, 'yes') && size(pp_data.all_ports,1) > 2
    plot_s_parameter_transmission_graphs_port(pp_data, modelling_inputs.beam, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)
    plot_s_param_transmission_graphs_modes(pp_data, modelling_inputs.beam, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)
elseif strcmp(modelling_inputs.beam, 'no')&& size(pp_data.all_ports,1) > 0
    plot_s_parameter_transmission_graphs_port(pp_data, modelling_inputs.beam, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)
    plot_s_param_transmission_graphs_modes(pp_data, modelling_inputs.beam, cols_sep, lines, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)
end %if

