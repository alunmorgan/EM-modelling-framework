function [fig_pos, lw, graph_freq_lim, cut_ind,  power_dist_ind, y_lev] =...
    report_global_graph_settings(graph_freq_lim, frequency_domain_data)
% Set the global settings for the look of the graphs.
%
% INPUTS
% graph_freq_lim
% frequency_domain_data
%
% OUTPUTS
% fig_pos
% lw
% graph_freq_lim
% cut_ind
% power_dist_ind
% y_lev
%
% Example: [fig_pos, lw, graph_freq_lim, cut_ind,  power_dist_ind, y_lev] =...
%     report_global_graph_settings(graph_freq_lim, frequency_domain_data)


%Line width of the graphs
lw = 2;
% limit to the horizontal axis.
graph_freq_lim = graph_freq_lim * 1e-9;
% find the coresponding index.
cut_ind = find(frequency_domain_data.f_raw*1E-9 < graph_freq_lim,1,'last');
% also find the index for 9GHz for zoomed graphs
power_dist_ind = find(frequency_domain_data.f_raw > 9E9, 1,'First');

% location and size of the default figures.
fig_pos = [10000 678 560 420];

% Set the level vector to show the total energy loss on graphs (nJ).
y_lev = [frequency_domain_data.Total_bunch_energy_loss *1e9,frequency_domain_data.Total_bunch_energy_loss * 1e9];