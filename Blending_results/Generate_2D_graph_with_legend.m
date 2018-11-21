function Generate_2D_graph_with_legend(report_input, data, fwl, cols, l_st, lw, lg, out_name)
h1 = figure('Position', [ 0 0 1000 400]);
ax1 = axes('Parent', h1);
hold(ax1, 'on')
for en = length(data):-1:1
    if isfield(data(en), 'xdata')
        chk = 0;
        ls_tk = 1;
        for ewh = fwl:length(data(en).xdata)
            if  ~isempty(data(en).xdata{ewh})
                if chk == 1
               h =  plot(data(en).xdata{ewh}, data(en).ydata{ewh},'linestyle',l_st{ls_tk},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax1);
                set(get(get(h,'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                else
                    plot(data(en).xdata{ewh}, data(en).ydata{ewh},'linestyle',l_st{ls_tk},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax1);
                chk = 1;  
                end %if
                ls_tk = ls_tk +1;
            else
                plot(NaN, NaN,'linestyle',l_st{1},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax1);
            end %if
        end %for
    end %if
    leg{en} = [report_input.swept_name{1},' = ',report_input.swept_vals{en}];
end %for
hold(ax1, 'off')
% add legend to 2D graph
xlims = data(1).xlims;
ylims = data(1).ylims;
for ew = 2:length(data);
    xlims = cat(1, xlims, data(ew).xlims);
    ylims = cat(1, ylims, data(ew).ylims);
end %for
setup_graph_for_display(ax1, xlims,...
    ylims,...
    [-1,0], [0,lg,0], ...
    data(1).Xlab, data(1).Ylab,...
    '',...
    regexprep(report_input.base_name, '_', ' '));
legend(ax1, leg, 'Location', 'EastOutside', 'Box', 'off')
% save 2D graph
savemfmt(h1, report_input.output_loc, out_name)
close(h1)