function plot_fexport_snapshots(data, field_type, mesh_step, limits, output_location, prefix)

if isfield(data, 'Fx')
    field_dir = 'Fx';
elseif isfield(data, 'Fy')
    field_dir = 'Fy';
elseif isfield(data, 'Fz')
    field_dir = 'Fz';
end %if

if strcmp(field_type, 'e')
    field_units = '(V/m)';
elseif strcmp(field_type, 'h')
    field_units = '(A/m)';
end %if

f1 = figure('Position',[30,30, 1500, 600]);
graph_timestamp = [num2str(round(data.data.timestamp * 1E9*10000)/10000), 'ns'];
save_timestamp = regexprep(graph_timestamp, '\.', 'p');
graph_data_temp = data.(field_dir);
graph_data = squeeze(sum(graph_data_temp, 3))' * mesh_step;
out_file_name = [prefix, '_snapshot_', save_timestamp, '_', field_dir];
disp('plot_fexport_snaphots: writing CSV')
writematrix(graph_data, fullfile(output_location, [out_file_name, '.csv']));
imagesc(data.data.coord_x*1E3, data.data.coord_y * 1E3, graph_data)
title_text = {['snapshot ',  graph_timestamp, ' ', field_dir];
    ['Integrated along beam direction ', field_units]};
title_text = regexprep(title_text, '_', ' ');
title(title_text)
colorbar
axis equal
xlabel('Horizontal (mm)')
ylabel('Vertical (mm)')
disp('plot_fexport_snaphots: saving graph0')
savemfmt(f1, output_location, out_file_name);
for hwsa = 1:length(limits)
    graph_data_zoom = graph_data;
    x_vals = data.data.coord_x*1E3;
    y_vals = data.data.coord_y * 1E3;
    x_low = find(x_vals < limits{hwsa}(1,1), 1, 'last');
    x_high = find(x_vals < limits{hwsa}(1,2), 1, 'last');
    y_low = find(y_vals < limits{hwsa}(2,1), 1, 'last');
    y_high = find(y_vals < limits{hwsa}(2,2), 1, 'last');
    imagesc(x_vals(x_low:x_high), y_vals(y_low:y_high), graph_data_zoom(y_low:y_high, x_low:x_high))
    title(title_text)
    colorbar
    axis equal
    xlabel('Horizontal (mm)')
    ylabel('Vertical (mm)')
    disp(['plot_fexport_snaphots: saving graph' num2str(hwsa)])
    savemfmt(f1, output_location, [prefix, '_snapshot_', save_timestamp, '_', field_dir, '_zoom', num2str(hwsa)]);
end %for
close(f1)
drawnow; pause(0.1);  % this innocent line prevents the Matlab hang
