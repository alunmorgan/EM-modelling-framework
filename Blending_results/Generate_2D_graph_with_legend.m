function Generate_2D_graph_with_legend(graph_metadata, data)

cols = {[0.5, 1, 0], 'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5]};
l_st ={'-.', '-', '--', ':'};

h1 = figure('Position', [ 0 0 1000 400]);
ax1 = axes('Parent', h1);
hold(ax1, 'on')

for en = 1:length(data)
    if ~isempty(data(en).ydata)
        plot(squeeze(data(en).xdata), squeeze(data(en).ydata),...
            'linestyle',l_st{rem(en,length(l_st))+1},...
            'Color',cols{rem(en,length(cols))+1},...
            'linewidth',data(en).linewidth,...
            'Parent', ax1,...
            'DisplayName', data(en).sweep_val);
        if ~exist('xlim_min', 'var')
            xlim_min = min(data(1).xdata);
            xlim_max = max(data(1).xdata);
            ylim_min = min(data(1).ydata);
            ylim_max = max(data(1).ydata);
        else
            xlim_min = min(xlim_min, min(data(en).xdata));
            xlim_max = max(xlim_max, max(data(en).xdata));
            ylim_min = min(ylim_min, min(data(en).ydata));
            ylim_max = max(ylim_max, max(data(en).ydata));
        end %if
    end %if
end %for

hold(ax1, 'off')
 if ~exist('xlim_min', 'var')
     % there was no valid data to plot.
     close(h1)
     return
 end %if
 
xlims = [xlim_min xlim_max];
ylims = [ylim_min ylim_max];
setup_graph_for_display(ax1, xlims,...
    ylims,...
    [-1,0], [0,data(1).islog,0], ...
    data(1).Xlab, data(1).Ylab,...
    '',...
    regexprep([graph_metadata.swept_name{1}, ' - sweep'], '_', ' '));
legend(ax1, 'Location', 'EastOutside', 'Box', 'off')
% save 2D graph
[~, model_name] = fileparts(graph_metadata.output_loc);
savemfmt(h1, graph_metadata.output_loc, [model_name, '-',graph_metadata.sweep_type,'-', data(1).out_name])
close(h1)