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


graph_data = data.(field_dir);
[X,Y,Z] = meshgrid(data.data.coord_y*1E3,data.data.coord_x*1E3,data.data.coord_z*1E3);
graph_data = abs(graph_data(:)).*1E-3;
X = X(:);
Y = Y(:);
Z = Z(:);
inds = find(graph_data <1);
graph_data(inds) = [];
X(inds) = [];
Y(inds) = [];
Z(inds) = [];
figure(fig_h)
scatter3(Z, Y, X, 3, round(graph_data), "filled", 'MarkerEdgeAlpha', 0.5, 'MarkerFaceAlpha', 0.5)
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
