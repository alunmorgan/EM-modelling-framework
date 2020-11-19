function Generate_2D_graph_with_legend(graph_metadata, data, cols, l_st)
h1 = figure('Position', [ 0 0 1000 400]);
ax1 = axes('Parent', h1);
hold(ax1, 'on')

variation_data = data(~contains(graph_metadata.sources, '_Base'));
swept_vals = graph_metadata.swept_vals(~contains(graph_metadata.sources, '_Base'));
ls_tk = 1;
for en = 1:length(variation_data)
    if isfield(variation_data(en), 'xdata') && ~isempty(variation_data(en).xdata)
        plot(variation_data(en).xdata, variation_data(en).ydata, 'linestyle',l_st{ls_tk},...
            'Color',cols{rem(en,length(cols))+1}, 'linewidth',data(en).linewidth, 'Parent', ax1,...
            'DisplayName', swept_vals{en});
        if rem(en,length(cols))+1 == 1
            ls_tk = ls_tk +1;
        end %if
    else
        plot(NaN, NaN, 'linestyle',l_st{1},...
            'Color',cols{rem(en,length(cols))+1}, 'linewidth',data(en).linewidth, 'Parent', ax1);
    end %if
    %     leg{en} = swept_vals{en};
end %for
base_data = data(contains(graph_metadata.sources, '_Base'));
base_vals = graph_metadata.swept_vals(contains(graph_metadata.sources, '_Base'));
if isfield(base_data, 'xdata') && ~isempty(base_data.xdata)
    plot(base_data.xdata, base_data.ydata,...%'linestyle',l_st{1},...
        'Color',cols{1}, 'linewidth',data(en).linewidth, 'Parent', ax1, 'DisplayName', base_vals{1});
else
    plot(NaN, NaN,...%'linestyle',l_st{1},...
        'Color',cols{1}, 'linewidth',data(en).linewidth, 'Parent', ax1);
end %if
% leg{end+1} = base_vals{1};

hold(ax1, 'off')

xlim_min = min(data(1).xdata);
xlim_max = max(data(1).xdata);
ylim_min = min(data(1).ydata);
ylim_max = max(data(1).ydata);
for ew = 2:length(data)
    xlim_min = min(xlim_min, min(data(ew).xdata));
    xlim_max = max(xlim_max, max(data(ew).xdata));
    ylim_min = min(ylim_min, min(data(ew).ydata));
    ylim_max = max(ylim_max, max(data(ew).ydata));
end %for
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
savemfmt(h1, graph_metadata.output_loc, [model_name, ' - ', data(1).out_name])
close(h1)