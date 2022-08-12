function plot_fexport_snapshots(data, limits, output_location, prefix)

sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

f1 = figure('Position',[30,30, 1500, 600]);
for osd = 1:length (sets)
    for ahd = 1:length(data.(sets{osd}).timestamp)
        graph_timestamp = [num2str(round(data.(sets{osd}).timestamp(ahd) * 1E9*10000)/10000), 'ns'];
        save_timestamp = regexprep(graph_timestamp, '\.', 'p');
        for wnd = 1:length(field_dirs)
            graph_data_temp = squeeze(data.(sets{osd}).(field_dirs{wnd})(:,:,:,ahd));
            graph_data = squeeze(sum(graph_data_temp, 3))';
            out_file_name = [prefix, '_snapshot_', sets{osd}, save_timestamp, '_', field_dirs{wnd}];
            writematrix(graph_data, fullfile(output_location, [out_file_name, '.csv']));
            imagesc(data.(sets{osd}).coord_x*1E3, data.(sets{osd}).coord_y * 1E3, graph_data)
            title_text = ['snapshot ', sets{osd}, ' ', graph_timestamp, ' ', field_dirs{wnd}];
            title_text = regexprep(title_text, '_', ' ');
            title(title_text)
            colorbar
            axis equal
            xlabel('Horizontal (mm)')
            ylabel('Vertical (mm)')
            savemfmt(f1, output_location, out_file_name);
            for hwsa = 1:length(limits)
                graph_data_zoom = graph_data;
                x_vals = data.(sets{osd}).coord_x*1E3;
                y_vals = data.(sets{osd}).coord_y * 1E3;
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
                savemfmt(f1, output_location, [prefix, '_snapshot_', sets{osd}, save_timestamp, '_', field_dirs{wnd}, '_zoom', num2str(hwsa)]);
            end %for
            clf(f1)
        end %for
    end %for
end %for
close(f1)

