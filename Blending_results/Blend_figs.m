function varargout = Blend_figs(report_input, fig_nme, out_name, lg, lw, line_select)
% Take existing fig files and combine them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
% line_select is a regular expression search based on the display name of
% the line.
%
% Example: state = Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2, '\s*S\d\d\(1\)\s*');

if ispc == 0
      slh = '/';
else
       slh = '\';
end

if nargin <6
    line_select = 'all';
end
cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5],[0.5, 1, 0] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};
doc_root = report_input.doc_root;
source_reps =report_input.sources;
rep_title = report_input.report_name;

if length(report_input.param_names_varying) == 1
    swept_name = report_input.param_names_varying{1};
    swept_vals = report_input.param_vals_varying(1,:);
else
    swept_name = 'Model';
    for sn = 1:length(report_input.param_names_varying)
        swept_vals{sn} = num2str(sn);
    end
end

h1 = figure('Position', [ 0 0 1000 400]);
h2 = figure('Position', [ 0 0 1000 1000]);
h3 = figure('Position', [ 0 0 1000 400]);
h4 = figure('Position', [ 0 0 1000 400]);
hold on
ke =1;
bad_data = [];
zlims = [1;length(source_reps)];
ylev = 0;
ylev2 = 0;
ylev_diff = 0;
ylev2_diff = 0;
for hse = 1:length(source_reps)
    if exist([doc_root, slh, source_reps{hse}, slh, 'wake', slh, fig_nme, '.fig'],'file')
        hn = open([doc_root, slh, source_reps{hse}, slh, 'wake', slh,fig_nme, '.fig']);
        % find the graph limits
        axis_handle = findobj(hn,'Type', 'axes');
        axis_handle = axis_handle(end);
        xlims(:,hse) = get(axis_handle,'XLim');
        ylims(:,hse) = get(axis_handle,'YLim');
        
        % find the handle of the axis
        h_ax = findobj(hn,'XTickLabelMode', 'auto');
        
        % find all the lines in the graph
        a = findobj(hn,'Type', 'line');
        for ove = 1:length(a)
            display_names{ove} = get(a(ove), 'DisplayName');
            data_length(ove) = length(get(a(ove), 'XData'));
            parent(ove) = get(a(ove), 'Parent');
        end
        %          Select only the lines on the main axis.
        s1 = parent == h_ax;
        % Only select lines with 2 datapoints or more
        s2 = data_length > 1;
        
        selection = s1 & s2;
        a = a(selection);
        display_names = display_names(selection);
        % If used then select the requested line using the display
        % name.
        if ~strcmp(line_select, 'all')
            locs = find_position_in_cell_lst(regexp(display_names, line_select));
            a = a(locs);
        end
        
        ck = 1;
        for aww = 1:length(a)
            % Check that the line .... and belongs to the current axis.
            if length(get(a(aww),'XData')) > 1
                b(ck) = a(aww);
                ck = ck +1;
            end
        end
        if hse ==1
            Xlab = get(get(gca,'Xlabel'), 'String');
            Ylab = get(get(gca,'Ylabel'), 'String');
            Zlab = report_input.swept_name;
        end
        %% extract the data from the graphs
        if ~exist('b', 'var')
            varargout{1} = 1;
            return
        end
        len_b = length(b);
        for en = 1:len_b
            xdata{en} = get(b(en),'XData');
            ydata{en} = get(b(en),'YData');
            zdata{en} = ones(length(xdata{en}),1) .* hse;
        end
        close(hn)
        clear a b h_ax
        if hse == 1
            ref_data = ydata;
        end
        %% Plot graphs
        %         Generate 2D graph with legend
        figure(h1)
        figure_setup_bounding_box
        for en = 1:len_b
            hold on
            if en ==1
                plot(xdata{en}, ydata{en},'linestyle',l_st{rem(en-1,9)+1},...
                    'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw);
            else
                plot(xdata{en}, ydata{en},'linestyle',l_st{rem(en-1,9)+1},...
                    'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw,'HandleVisibility','off');
            end
            hold off
            
        end
        
        if strfind(Xlab, 'Frequency')
            % Generate 2D graph with legend fixed 0 - 9GHz frequency scale
            figure(h3)
            figure_setup_bounding_box
            for en = 1:len_b
                hold on
                cut_point = find(xdata{en}>9,1, 'first');
                ylev = min(ylev, min(ydata{en}(1:cut_point)));
                ylev2 = max(ylev2, max(ydata{en}(1:cut_point)));
                if en ==1
                    plot(xdata{en}(1:cut_point), ydata{en}(1:cut_point),'linestyle',l_st{rem(en-1,9)+1},...
                        'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw);
                else
                    plot(xdata{en}(1:cut_point), ydata{en}(1:cut_point),'linestyle',l_st{rem(en-1,9)+1},...
                        'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw,'HandleVisibility','off');
                end
                hold off
            end
            % Generate 2D graph showing the difference to the first trace.
            if hse >1
                figure(h4)
                figure_setup_bounding_box
                for en = 1:len_b
                    % TEMP truncating the ref data or the ydata as matlab seems to loose
                    % a data point depending on whether it is running on
                    % linux or windows.
                    ydata2  = ydata{en};
                    xdata2 = xdata{en};
                    if length(ref_data{en}) > length(ydata2)
                        df = length(ref_data{en}) - length(ydata2);
                        sz = size(ydata2);
                        if sz(1) == 1
                            ydata2 = cat(2,ydata2,NaN(1,df));
                            xdata2 = cat(2,xdata2,NaN(1,df));
                        elseif sz(2) == 1
                            ydata2 = cat(1,ydata2,NaN(df,1));
                            xdata2 = cat(1,xdata2,NaN(df,1));
                        end
                    elseif length(ref_data{en}) < length(ydata2)
                        ydata2 = ydata2(1:length(ref_data));
                        xdata2 = xdata2(1:length(ref_data));
                    end
                    plot_data = ydata2 - ref_data{en};
                    ylev_diff = min(ylev_diff, min(plot_data));
                    ylev2_diff = max(ylev2_diff, max(plot_data));
                    hold on
                    if en ==1
                        plot(xdata2, plot_data,'linestyle',l_st{rem(en-1,9)+1},...
                            'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw);
                    else
                        plot(xdata2, plot_data,'linestyle',l_st{rem(en-1,9)+1},...
                            'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw,'HandleVisibility','off');
                    end
                    hold off
                end
            end
        end
        %         Generate 3D graph with no legend
        figure(h2)
        figure_setup_bounding_box
        for en = 1:len_b
            hold on
            plot3(xdata{en}, zdata{en}, ydata{en},'linestyle',l_st{rem(en-1,9)+1},...
                'Color',cols{rem(hse-1,10)+1}, 'linewidth',lw,'HandleVisibility','off');
            hold off
        end
    else
        bad_data(ke) = hse;
        ke = ke +1;
    end
end

if length(bad_data) == length(source_reps)
    % there is no data so mark the output as empty and do not plot the
    % graph.
    varargout{1} = 1;
    close(h1)
    close(h2)
    close(h3)
else
    varargout{1} = 0;
    % add legend to 2D graph
    figure(h1)
    setup_graph_for_display(xlims, ylims, [-1;0], [0,lg,0], ...
        Xlab, Ylab, '', report_input.model_name);
    vals = report_input.swept_vals;
    for whs = 1:length(vals)
        leg{whs} = [report_input.swept_name,' = ',vals{whs}];
    end
    vals(bad_data) = [];
    leg(bad_data) = [];
    legend(leg, 'Location', 'EastOutside')
    legend('boxoff')
    % save 2D graph
    savemfmt(report_input.output_loc, out_name)
    close(h1)
    
    % save 3D graph.
    figure(h2)
    setup_graph_for_display(xlims, zlims, ylims, [0,0,lg], ...
        Xlab, Zlab, Ylab, '');
    set(gca, 'YTick',1:length(source_reps))
    set(gca, 'YTickLabel',report_input.swept_vals)
    view(45,45)
    grid on
    savemfmt(report_input.output_loc, [out_name, '_3D'])
    close(h2)
    
    % Save zoomed in frequency graph.
    if strfind(Xlab, 'Frequency')
        figure(h3)
        setup_graph_for_display([0;9], [ylev;ylev2], [-1;0], [0,lg,0],...
            Xlab, Ylab, '', report_input.model_name);
        vals = report_input.swept_vals;
        for whs = 1:length(vals)
            leg{whs} = [report_input.swept_name,' = ',vals{whs}];
        end
        vals(bad_data) = [];
        leg(bad_data) = [];
        legend(leg, 'Location', 'EastOutside')
        legend('boxoff')
        % save 2D graph
        savemfmt(report_input.output_loc, [out_name, '_zoom'])
        close(h3)
        
        figure(h4)
        setup_graph_for_display(xlims, [ylev_diff;ylev2_diff], [-1;0], [0,lg,0],...
            Xlab, Ylab, '', report_input.model_name);
        vals = report_input.swept_vals;
        for whs = 1:length(vals)
            leg{whs} = [report_input.swept_name,' = ',vals{whs}];
        end
        vals(bad_data) = [];
        leg(bad_data) = [];
        legend(leg, 'Location', 'EastOutside')
        legend('boxoff')
        % save 2D graph
        savemfmt(report_input.output_loc, [out_name, '_diff'])
        close(h4)
    end
    drawnow
end
close all