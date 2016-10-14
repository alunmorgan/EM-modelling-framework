function report_plot_frequency_graphs(fig_pos, pth, y_lev, x_axis, y_data, cut_ind, power_dist_ind, cut_off_freqs, lw, name, graph_freq_lim, cols, leg)
% Plot all the frequency domain graphs.
%
%fig_pos
% pth
% y_lev
% x_axis
% y_data
% cut_ind
% power_dist_ind
% cut_off_freqs
% lw
% name
% graph_freq_lim
% cols
% leg
%
% Example: report_plot_frequency_graphs(fig_pos, pth, y_lev, x_axis, y_data, cut_ind, power_dist_ind, cut_off_freqs, lw, name, graph_freq_lim, cols, leg)

% full frequency range
report_frequency_graphs_core(fig_pos, pth, y_lev, x_axis, y_data,...
    cut_ind, cut_off_freqs, lw, name, graph_freq_lim, cols, leg)

% reduced frequency range
report_frequency_graphs_core(fig_pos, pth, y_lev, x_axis, y_data,...
    power_dist_ind, cut_off_freqs, lw, [name,'_f_zoom'], 5, cols, leg)

function report_frequency_graphs_core(fig_pos, pth, y_lev, x_axis, y_data,...
    cut_ind, cut_off_freqs, lw, name, graph_freq_lim, cols, leg)
%
%fig_pos
% pth
% y_lev
% x_axis
% y_data
% cut_ind
% power_dist_ind
% cut_off_freqs
% lw
% name
% graph_freq_lim
% cols
% leg
%
% Example: report_frequency_graphs_core(fig_pos, pth, y_lev, x_axis, y_data,...
%     cut_ind, cut_off_freqs, lw, name, graph_freq_lim, cols, leg)

h(1) = figure('Position',fig_pos);
if iscell(y_data)
    hold on
    for ues = 1:length(y_data)
        plot(x_axis(1:cut_ind), y_data{ues}(1:cut_ind),cols{ues},'LineWidth',lw)
    end
    hold off
else
    plot(x_axis(1:cut_ind), y_data(1:cut_ind),'b','LineWidth',lw)
end
graph_add_vertical_lines(cut_off_freqs)
if isempty(strfind(name, '_f_zoom'))
    title(regexprep(name,'_',' '))
else
    title(regexprep(name(1:end-7),'_',' '))
end
xlabel('Frequency (GHz)')
ylabel('Energy (nJ)')
xlim([0 graph_freq_lim])
if isempty(leg) == 0
    legend(leg, 'Location', 'Best')
end
name = regexprep(name,' |,','_');
savemfmt(h(1), pth, name)
close(h(1))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(2) = figure('Position',fig_pos);
if iscell(y_data)
    hold on
    for ues = 1:length(y_data)
        plot(x_axis(1:cut_ind), cumsum(y_data{ues}(1:cut_ind)),cols{ues},'LineWidth',lw)
    end
    hold off
else
    plot(x_axis(1:cut_ind), cumsum(y_data(1:cut_ind)),'b','LineWidth',lw)
end
graph_add_horizontal_lines(y_lev)
graph_add_vertical_lines(cut_off_freqs)
if isempty(strfind(name, '_f_zoom'))
    title(regexprep(name,'_',' '))
else
    title(regexprep(name(1:end-7),'_',' '))
end
xlabel('Frequency (GHz)')
ylabel('Cumulative sum of Energy (nJ)')
xlim([0 graph_freq_lim])
if isempty(leg) == 0
    legend(leg, 'Location', 'SouthEast')
end
name = regexprep(name,' |,','_');
savemfmt(h(2), pth,['cumulative_',name])
close(h(2))