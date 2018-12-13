function graph_add_vertical_lines(x_locs, pattern, col, lw)
% Adds verticle lines on the current graph. (with no legend entries)
%
% x_locs is an array containing the locations of the lines on the x axis.
% pattern is the line style of the lines.
% col is the colour of the lines as an RGB array.
%
% Example: add_wg_cut_off_lines(x_locs)

if nargin ==1
    pattern  = ':';
    col = [0.7 0.7 0.7];
    lw = 2;
end

hold on
lims = ylim;
for jse = 1:length(x_locs)
        h = plot([x_locs(jse), x_locs(jse)],lims,pattern,'Color',col, 'LineWidth',lw);
        hAnnotation = get(h,'Annotation');
        hLegendEntry = get(hAnnotation,'LegendInformation');
        set(hLegendEntry,'IconDisplayStyle','off')
end
hold off