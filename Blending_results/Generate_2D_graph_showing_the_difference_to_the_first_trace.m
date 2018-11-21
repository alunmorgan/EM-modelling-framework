function Generate_2D_graph_showing_the_difference_to_the_first_trace(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)
h4 = figure('Position', [ 0 0 1000 400]);
ax4 = axes('Parent', h4);
hold(ax4, 'on')
for en = 1:length(data_out)
    if isfield(data_out(hwc), 'ydata')
        for ewh = fwl:length(data_out(en).xdata)
            if  ~isempty(data_out(en).ydata{ewh})
                if isempty(data_out(1).xdata)
                    reference_x = zeros(1,length(data_out(en).xdata{ewh}));
                    reference_y = zeros(1,length(data_out(en).xdata{ewh}));
                elseif isempty(data_out(1).xdata{ewh})
                    reference_x = zeros(1,length(data_out(en).xdata{ewh}));
                    reference_y = zeros(1,length(data_out(en).xdata{ewh}));
                else
                    reference_x = data_out(1).xdata{ewh};
                    reference_y = data_out(1).ydata{ewh};
                end %if
                new_y = interp1(data_out(en).xdata{ewh}, data_out(en).ydata{ewh}, reference_x);
                plot(reference_x, new_y - reference_y ,'linestyle',l_st{1},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax4);
            else
                plot(NaN, NaN,'linestyle',l_st{1},...
                    'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax4);
            end %if
        end %for
    end %if
    leg{en} = [report_input.swept_name{1},' = ',report_input.swept_vals{en}];
end %for
hold(ax4, 'off')
xlims = data_out(1).xlims;
ylims = data_out(1).ylims;
for ew = 2:length(data_out);
    xlims = cat(1, xlims, data_out(ew).xlims);
    ylims = cat(1, ylims, data_out(ew).ylims);
end %for
setup_graph_for_display(ax4, xlims, [-inf,inf], [-1,0], [0,lg,0],...
    data_out(1).Xlab, data_out(1).Ylab, '', regexprep(report_input.base_name, '_', ' '));
legend(ax4, leg, 'Location', 'EastOutside', 'Box', 'off')
% save 2D graph
savemfmt(h4, report_input.output_loc, [out_name, '_diff'])
close(h4)
