function graph_add_background_patch(x_start, x_end, col)
% Places a background patch covering x_start to x_end on the current figure.
%
% x_start is the x axis value at which the patch starts.
% x_end is the x axis value at which the patch ends.
% col is the colour of the lines as an RGB array.
% Example: show_integration_zone(t_start)

ys = ylim;
xs = xlim;

if nargin == 1
    x_end = xs(2);
    col = [0.95,0.95,0.95];
end
patch([x_start, x_end,x_end,x_start],[ys(1),ys(1),ys(2),ys(2)],...
    [-1,-1,-1,-1],col, 'EdgeColor', 'none');