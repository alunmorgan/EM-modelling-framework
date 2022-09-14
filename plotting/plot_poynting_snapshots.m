function plot_poynting_snapshots(data, mesh_step, limits, output_location, prefix)

field_dirs = {'Fx','Fy','Fz'};

f1 = figure('Position',[30,30, 1500, 600]);
field_units = '';
for wnd = 1:length(field_dirs)
    graph_data_temp = data.(field_dirs{wnd});
    graph_data_temp1 = data.(field_dirs{rem(wnd,length(field_dirs))+1});
    graph_data = squeeze(sum(graph_data_temp, 3))' * mesh_step;
    graph_data1 = squeeze(sum(graph_data_temp1, 3))' * mesh_step;
    out_file_name = [prefix, '_snapshot_', '_', field_dirs{wnd},field_dirs{rem(wnd,length(field_dirs))+1}];
    writematrix(graph_data, fullfile(output_location, [out_file_name, '.csv']));
    [X,Y] = meshgrid(data.coord_x*1E3,data.coord_y * 1E3);
    quiver(X, Y, graph_data, graph_data1)
    title_text = {['snapshot ', 'Poyniting vectors ',  field_dirs{wnd},field_dirs{rem(wnd,length(field_dirs))+1}];
        ['Integrated along beam direction ', field_units]};
    title_text = regexprep(title_text, '_', ' ');
    title(title_text)
    colorbar
    axis equal
    xlabel('Horizontal (mm)')
    ylabel('Vertical (mm)')
    savemfmt(f1, output_location, out_file_name);
    for hwsa = 1:length(limits)
        x_vals = data.coord_x*1E3;
        y_vals = data.coord_y * 1E3;
        x_low = find(x_vals < limits{hwsa}(1,1), 1, 'last');
        x_high = find(x_vals < limits{hwsa}(1,2), 1, 'last');
        y_low = find(y_vals < limits{hwsa}(2,1), 1, 'last');
        y_high = find(y_vals < limits{hwsa}(2,2), 1, 'last');
                graph_data_zoom = graph_data(y_low:y_high, x_low:x_high);
         graph_data1_zoom = graph_data1(y_low:y_high, x_low:x_high);
         X_zoom = X(y_low:y_high, x_low:x_high);
         Y_zoom = Y(y_low:y_high, x_low:x_high);
        quiver(X_zoom, Y_zoom, graph_data_zoom, graph_data1_zoom)
        title(title_text)
        colorbar
        axis equal
        xlabel('Horizontal (mm)')
        ylabel('Vertical (mm)')
        savemfmt(f1, output_location, [prefix, '_snapshot_',  field_dirs{wnd}, '_zoom', num2str(hwsa)]);
    end %for
    clf(f1)
end %for
close(f1)

