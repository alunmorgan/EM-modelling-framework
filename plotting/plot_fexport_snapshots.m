function plot_fexport_snapshots(fig_h, data, field_type, output_location, prefix)

if isfield(data, 'Fx')
    field_dir = 'Fx';
elseif isfield(data, 'Fy')
    field_dir = 'Fy';
elseif isfield(data, 'Fz')
    field_dir = 'Fz';
end %if

if strcmpi(field_type, 'E')
    field_units = '(V/m)';
elseif strcmpi(field_type, 'H')
    field_units = '(A/m)';
end %if

graph_timestamp = [num2str(round(data.data.timestamp * 1E9*100)/100), 'ns'];
save_timestamp = regexprep(graph_timestamp, '\.', 'p');
out_file_name = [prefix, '_snapshot_', save_timestamp, '_', field_dir];


graph_data = data.(field_dir).*1E-3;

[X,Y,Z] = meshgrid(data.data.coord_y*1E3,data.data.coord_x*1E3,data.data.coord_z*1E3);

reduction_factor = 4;
y_reduced = data.data.coord_y(1)*1E3:((data.data.coord_y(2)*1E3- data.data.coord_y(1)*1E3)) * reduction_factor:data.data.coord_y(end)*1E3;
x_reduced = data.data.coord_x(1)*1E3:((data.data.coord_x(2)*1E3- data.data.coord_x(1)*1E3)) * reduction_factor:data.data.coord_x(end)*1E3;
z_reduced = data.data.coord_z(1)*1E3:((data.data.coord_z(2)*1E3- data.data.coord_z(1)*1E3)) * reduction_factor:data.data.coord_z(end)*1E3;

[Xq,Yq,Zq] = meshgrid(y_reduced, x_reduced, z_reduced);
graph_data_reduced = interp3(X, Y, Z, graph_data, Xq, Yq, Zq,"linear");
graph_data_reduced = abs(graph_data_reduced(:));
Xq = Xq(:);
Yq = Yq(:);
Zq = Zq(:);
inds = find(graph_data_reduced <1);
graph_data_reduced(inds) = [];
Xq(inds) = [];
Yq(inds) = [];
Zq(inds) = [];
set(0,'CurrentFigure',fig_h) % grab figure window to make plots in it WITHOUT stealing focus.
scatter3(Zq, Yq, Xq, 3, round(graph_data_reduced), "filled", 'MarkerEdgeAlpha', 0.5, 'MarkerFaceAlpha', 0.5)
title_text = ['snapshot ',  graph_timestamp, ' ', field_dir, field_units];
title_text = regexprep(title_text, '_', ' ');
title(title_text)
axis equal
ylabel('Horizontal (mm)')
zlabel('Vertical (mm)')
xlabel('Longitudinal (mm)')
xlim([min(data.data.coord_z*1E3), max(data.data.coord_z*1E3)])
ylim([min(data.data.coord_x*1E3), max(data.data.coord_x*1E3)])
zlim([min(data.data.coord_y*1E3), max(data.data.coord_y*1E3)])
drawnow; pause(0.1);  % this innocent line prevents the Matlab hang
savemfmt(fig_h, output_location, out_file_name);
