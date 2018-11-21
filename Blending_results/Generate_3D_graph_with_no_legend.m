function Generate_3D_graph_with_no_legend(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)
h2 = figure('Position', [ 0 0 1000 1000]);
ax2 = axes('Parent', h2);
hold(ax2, 'on')
for en = 1:length(data_out)
    if isfield(data_out(hwc), 'xdata')
        for ewh = fwl:length(data_out(en).xdata)
            if  ~isempty(data_out(en).xdata{ewh})
                plot3(data_out(en).xdata{ewh}, ...
                    ones(length(data_out(en).xdata{ewh}),1) * en, ...
                    data_out(en).ydata{ewh},'linestyle',l_st{1},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw,...
                    'HandleVisibility','off', 'Parent', ax2);
            else
                plot3(NaN, NaN, NaN, 'linestyle',l_st{1},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw,...
                    'HandleVisibility','off', 'Parent', ax2);
            end %if
        end %for
    end %if
end %for
hold(ax2, 'off')
xlims = data_out(1).xlims;
ylims = data_out(1).ylims;
for ew = 2:length(data_out);
    xlims = cat(1, xlims, data_out(ew).xlims);
    ylims = cat(1, ylims, data_out(ew).ylims);
end %for
setup_graph_for_display(ax2, xlims, [1,length(data_out)], ylims, [0,0,lg], ...
    data_out(1).Xlab, report_input.swept_name, data_out(1).Ylab, '');
set(ax2, 'YTick',1:length(report_input.sources))
set(ax2, 'YTickLabel',report_input.swept_vals)
view(45,45)
grid on
savemfmt(h2, report_input.output_loc, [out_name, '_3D'])
close(h2)