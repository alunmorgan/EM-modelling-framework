function state = Blend_figs(report_input, sub_folder ,fig_nme, out_name, lg, lw, line_select, udcp)
% Take existing fig files and combine them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
% line_select is a regular expression search based on the display name of
% the line.
%
% If there is no data returns state == 0 otherwise state ==1
%
% Example: state = Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2, '\s*S\d\d\(1\)\s*');

state = 1;

if nargin <7
    line_select = 'all';
end
cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5],[0.5, 1, 0] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};

any_data = 0;
for hse = length(report_input.sources):-1 :1
    graph_name = fullfile(report_input.source_path, report_input.sources{hse}, sub_folder, [fig_nme, '.fig']);
    if exist(graph_name,'file')
        data_out(hse) = extract_from_graph(graph_name, line_select);
        if data_out(hse).state == 1
            any_data = 1;
            %             zdata{hse} = ones(length(data_out(1).xdata{1}),1) .* hse;
        end %if
    end %if
end %for
if any_data == 0
    state = 0;
    return
end
Zlab = report_input.swept_name;
xlims = data_out(1).xlims;
ylims = data_out(1).ylims;
for ew = 2:length(data_out);
    xlims = cat(1, xlims, data_out(ew).xlims);
    ylims = cat(1, ylims, data_out(ew).ylims);
end %for

% This section is to remove the levels and other straight line which may be
% on the graphs.
for hwc = length(data_out):-1:1
    if ~isempty(data_out(hwc).xdata)
        for wah = length(data_out(hwc).xdata):-1:1
            if ~isempty(data_out(hwc).xdata{wah})
                d_len(hwc, wah) = length(data_out(hwc).xdata{wah});
            else
                d_len(hwc, wah) = 0 ;
            end %if
        end %for
    else
        d_len(hwc,:) = 0;
    end %if
end %for

unwanted_lines = all(d_len <3, 1);
% Find first wanted line
fwl = find(unwanted_lines == 0,1, 'first');

%% Plot graphs
%         Generate 2D graph with legend
h1 = figure('Position', [ 0 0 1000 400]);
ax1 = axes('Parent', h1);
hold(ax1, 'on')
for en = length(data_out):-1:1
    if isempty(data_out(en).xdata{1})
        plot(NaN, NaN,'linestyle',l_st{1},...
            'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax1);
    else
        plot(data_out(en).xdata{fwl}, data_out(en).ydata{fwl},'linestyle',l_st{1},...
            'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax1);
    end %if
    leg{en} = [report_input.swept_name{1},' = ',report_input.swept_vals{en}];
end %for
hold(ax1, 'off')
% add legend to 2D graph
setup_graph_for_display(ax1, xlims,...
                             ylims,...
                             [-1,0], [0,lg,0], ...
                             data_out(1).Xlab, data_out(1).Ylab,...
                             '',...
                             regexprep(report_input.base_name, '_', ' '));
legend(ax1, leg, 'Location', 'EastOutside', 'Box', 'off')
% save 2D graph
savemfmt(h1, report_input.output_loc, out_name)

if exist('udcp', 'var')
    xlim_old = get(gca,'XLim');
    xlim([xlim_old(1) udcp]);
    savemfmt(h1, report_input.output_loc, [out_name, '_zoom'])
end % if
close(h1)

% Generate 2D graph showing the difference to the first trace.
h4 = figure('Position', [ 0 0 1000 400]);
ax4 = axes('Parent', h4);
hold(ax4, 'on')
for en = 1:length(data_out)
    if isempty(data_out(en).xdata)
        plot(NaN, NaN,'linestyle',l_st{1},...
            'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax4);
    else
        if ~isempty(data_out(en).ydata{1})
            new_y = interp1(data_out(en).xdata{fwl}, data_out(en).ydata{fwl},data_out(1).xdata{fwl});
            plot(data_out(1).xdata{fwl}, new_y - data_out(1).ydata{fwl},'linestyle',l_st{1},...
                'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax4);
        else
            plot(NaN, NaN,'linestyle',l_st{1},...
                'Color',cols{rem(en-1,10)+1}, 'linewidth',lw, 'Parent', ax4);
        end %if
    end %if
    leg{en} = [report_input.swept_name{1},' = ',report_input.swept_vals{en}]; 
end %for
hold(ax4, 'off')
setup_graph_for_display(ax4, xlims, [-inf,inf], [-1,0], [0,lg,0],...
    data_out(1).Xlab, data_out(1).Ylab, '', regexprep(report_input.base_name, '_', ' '));
legend(ax4, leg, 'Location', 'EastOutside', 'Box', 'off')
% save 2D graph
savemfmt(h4, report_input.output_loc, [out_name, '_diff'])
close(h4)


%         Generate 3D graph with no legend
h2 = figure('Position', [ 0 0 1000 1000]);
ax2 = axes('Parent', h2);
hold(ax2, 'on')
for en = 1:length(data_out)
    if isempty(data_out(en).xdata{1})
        plot3(NaN, NaN, NaN, 'linestyle',l_st{1},...
            'Color',cols{rem(en-1,10)+1}, 'linewidth',lw,...
            'HandleVisibility','off', 'Parent', ax2);
    else
        plot3(data_out(en).xdata{fwl}, ...
            ones(length(data_out(en).xdata{fwl}),1) * en, ...
            data_out(en).ydata{fwl},'linestyle',l_st{1},...
            'Color',cols{rem(en-1,10)+1}, 'linewidth',lw,...
            'HandleVisibility','off', 'Parent', ax2);
    end %if
end %for
hold(ax2, 'off')
setup_graph_for_display(ax2, xlims, [1,length(data_out)], ylims, [0,0,lg], ...
    data_out(1).Xlab, Zlab, data_out(1).Ylab, '');
set(ax2, 'YTick',1:length(report_input.sources))
set(ax2, 'YTickLabel',report_input.swept_vals)
view(45,45)
grid on
savemfmt(h2, report_input.output_loc, [out_name, '_3D'])
close(h2)