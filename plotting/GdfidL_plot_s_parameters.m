function GdfidL_plot_s_parameters(run_inputs_loc, analysis_loc, output_folder)
% plots the s parameter results.
%
% Example: GdfidL_plot_s_parameters(s, ppi, fig_pos, pth)
% [pth, ~,~] = fileparts(path_to_data);


[temp, ~, ~] = fileparts(run_inputs_loc);
[temp, ~, ~] = fileparts(temp);
[temp, ~, ~] = fileparts(temp);
[temp, ~, ~] = fileparts(temp);
[~, prefix, ~] = fileparts(temp);

fig_width = 800;
fig_height = 600;
fig_left = 10560 - fig_width;
fig_bottom = 1098 - fig_height;
fig_pos = [fig_left fig_bottom fig_width fig_height];

lines = {'--',':','-.','-'};
cols_sep = {'y','k','r','b','g','c','m'};
lower_cutoff = -120;
linewidth = 2;

files_to_load = {run_inputs_loc, 'modelling_inputs';...
    analysis_loc, 'sparameter_data'};

for rnf = 1:size(files_to_load,1)
    if exist(files_to_load{rnf,1}, 'file') == 2
        load(files_to_load{rnf,1}, files_to_load{rnf,2});
    else
        disp(['Unable to load ', files_to_load{rnf,1}])
        return
    end %if
end %for

% 

% for nes = 1:length(analysis_loc)
%     if exist(input_list{1}, 'file') == 2
%         load(analysis_list{nes})
        plot_s_param_graph(sparameter_data, modelling_inputs.beam, cols_sep, fig_pos, output_folder, prefix, lower_cutoff, linewidth)
        plot_s_parameter_reflection_graph(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_folder, prefix, lower_cutoff, linewidth)
        receivers = unique(sparameter_data.reciever_list);
        % Only generate the transmission graphs if there is more than 1 signal port.
        if strcmp(modelling_inputs.beam, 'yes') && length(receivers) > 2
            plot_s_parameter_transmission_graphs_port(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_folder, prefix, lower_cutoff, linewidth)
            plot_s_param_transmission_graphs_modes(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_folder, prefix, lower_cutoff, linewidth)
        elseif strcmp(modelling_inputs.beam, 'no')&& length(receivers) > 0
            plot_s_parameter_transmission_graphs_port(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_folder, prefix, lower_cutoff, linewidth)
            plot_s_param_transmission_graphs_modes(sparameter_data, modelling_inputs.beam, cols_sep, lines, fig_pos, output_folder, prefix, lower_cutoff, linewidth)
        end %if
%     else
%         disp(['Unable to load ', analysis_loc{nes}])
%         continue
%     end %if
% end %for

