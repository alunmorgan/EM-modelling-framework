function GdfidL_plot_s_parameters(path_to_data, fig_pos)
% plots the s parameter results.
%
% Example: GdfidL_plot_s_parameters(s, ppi, fig_pos, pth)
% [pth, ~,~] = fileparts(path_to_data);
input_list = path_to_data(contains(path_to_data, 'run_inputs.mat'));
analysis_list = path_to_data(contains(path_to_data, 'data_analysed_sparameter.mat'));
if exist(input_list{1}, 'file') == 2
    load(input_list{1}, 'modelling_inputs');
else
    disp(['Unable to load ', input_list{1}])
    return
end %if

lines = {'--',':','-.','-'};
cols_sep = {'y','k','r','b','g','c','m'};
lower_cutoff = -120;
linewidth = 2;

for nes = 1:length(analysis_list)
    output_path = fileparts(analysis_list{nes});
    if exist(input_list{1}, 'file') == 2
        load(analysis_list{nes})
        plot_s_param_graph(sparameter_data, modelling_inputs.beam, cols_sep, fig_pos, output_path, lower_cutoff, linewidth)
        plot_s_parameter_reflection_graph(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_path, lower_cutoff, linewidth)
        receivers = unique(sparameter_data.reciever_list);
        % Only generate the transmission graphs if there is more than 1 signal port.
        if strcmp(modelling_inputs.beam, 'yes') && length(receivers) > 2
            plot_s_parameter_transmission_graphs_port(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_path, lower_cutoff, linewidth)
            plot_s_param_transmission_graphs_modes(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_path, lower_cutoff, linewidth)
        elseif strcmp(modelling_inputs.beam, 'no')&& length(receivers) > 0
            plot_s_parameter_transmission_graphs_port(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_path, lower_cutoff, linewidth)
            plot_s_param_transmission_graphs_modes(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_path, lower_cutoff, linewidth)
        end %if
    else
        disp(['Unable to load ', analysis_list{nes}])
        continue
    end %if
end %for

