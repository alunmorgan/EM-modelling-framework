function graph_add_horizontal_lines(y_locs, pattern, col)
% Plot the total energy loss level on the current graph.
%
% y_locs is an array containing the locations of the lines on the x axis.
% pattern is the line style of the lines.
% col is the colour of the lines as an RGB array.
%
% Example: graph_add_horizontal_lines(y_locs, pattern, col)

if nargin ==1
    pattern  = ':';
    col = [1 0 0];
end

hold on
lims = xlim;
for jse = 1:length(y_locs)
        h = plot(lims,[y_locs(jse), y_locs(jse)],pattern,'Color',col);
        hAnnotation = get(h,'Annotation');
        hLegendEntry = get(hAnnotation,'LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off')
end
hold off