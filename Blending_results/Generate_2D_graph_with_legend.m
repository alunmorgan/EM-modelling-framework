function Generate_2D_graph_with_legend(report_input, data, cols, l_st)
h1 = figure('Position', [ 0 0 1000 400]);
ax1 = axes('Parent', h1);
hold(ax1, 'on')
for en = length(data):-1:1
    if isfield(data(en), 'xdata')
        chk = 0;
        ls_tk = 1;
        %         for ewh = fwl:length(data(en).xdata)
        if  ~isempty(data(en).xdata)
            if chk == 1
                h =  plot(data(en).xdata{ewh}, data(en).ydata{ewh},'linestyle',l_st{ls_tk},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',data(en).linewidth, 'Parent', ax1);
                set(get(get(h,'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
            else
                plot(data(en).xdata, data(en).ydata,'linestyle',l_st{ls_tk},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',data(en).linewidth, 'Parent', ax1);
                chk = 1;
            end %if
            ls_tk = ls_tk +1;
        else
            plot(NaN, NaN,'linestyle',l_st{1},...
                'Color',cols{rem(en-1,10)+1}, 'linewidth',data(en).linewidth, 'Parent', ax1);
        end %if
        %         end %for
    end %if
    leg{en} = [report_input.swept_name{1},' = ',report_input.swept_vals{en}];
end %for
hold(ax1, 'off')
% add legend to 2D graph
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
    regexprep(report_input.base_name, '_', ' '));
legend(ax1, leg, 'Location', 'EastOutside', 'Box', 'off')
% save 2D graph
savemfmt(h1, report_input.output_loc, data(1).out_name)
close(h1)