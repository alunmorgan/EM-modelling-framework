function data_out = extract_from_graph(graph_name, line_select)
% extracts all the data from an existing matlab fig file.
%
% graph_name is the full path to the file.
% line select is the desired line to be extracted.
%
% Example: data_out = extract_from_graph(graph_name, line_select)
hn = open(graph_name);
% find the graph limits
axis_handle = findobj(hn,'Type', 'axes');
axis_handle = axis_handle(end);
data_out.xlims = get(axis_handle,'XLim');
data_out.ylims = get(axis_handle,'YLim');

% find the axis labels.
data_out.Xlab = get(get(gca,'Xlabel'), 'String');
data_out.Ylab = get(get(gca,'Ylabel'), 'String');

% find the handle of the axis
h_ax = findobj(hn,'XTickLabelMode', 'auto');

% find all the lines in the graph
a = findobj(hn,'Type', 'line');
if isempty(a)
    data_out.state = 0;
    data_out.xdata{1} = [];
    data_out.ydata{1} = [];
else
    for ove = length(a):-1:1
        display_names{ove} = get(a(ove), 'DisplayName');
        %     data_length(ove) = length(get(a(ove), 'XData'));
        parent(ove) = get(a(ove), 'Parent');
    end
    %          Select only the lines on the main axis.
    s1 = parent == h_ax;
    a = a(s1);
    display_names = display_names(s1);
    % If used then select the requested line using the display
    % name.
    if ~strcmp(line_select, 'all')
        locs = find_position_in_cell_lst(regexp(display_names, line_select));
        a = a(locs);
    end
    
    %% extract the data from the graphs
    
    data_out.state = 1;
    for en = 1:length(a)
        data_out.xdata{en} = get(a(en),'XData');
        data_out.ydata{en} = get(a(en),'YData');
    end %for
end %if
close(hn)

