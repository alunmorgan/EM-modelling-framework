function plot_pp_mode_data_as_ribbon(fig_handle, data, save_location)

figure(fig_handle)
clf
temp_names = fieldnames(data);
for hsq = 1:length(temp_names)
    temp_modes = fieldnames(data.(temp_names{hsq}).x);
    n_modes = 1:length(temp_modes);
    for nse = 1:length(temp_modes)
        graph_data.(temp_modes{nse}) = data.(temp_names{hsq}).y.(temp_modes{nse});
    end %for
    if contains(data.(temp_names{hsq}).x_label{1}, 'time [s]')
        for nse = 1:length(temp_modes)
            x_data.(temp_modes{nse}) = data.(temp_names{hsq}).x.(temp_modes{nse}) .* 1E9;
        end %for
        x_label = regexprep(data.(temp_names{hsq}).x_label, '\[s\]', '\[ns\]');
        graph_title_start = 'Time';
    elseif contains(data.(temp_names{hsq}).x_label, 'frequency [Hz]')
        for nse = 1:length(temp_modes)
            x_data.(temp_modes{nse}) = data.(temp_names{hsq}).x.(temp_modes{nse}) .* 1E-9;
        end %for
        x_label = regexprep(data.(temp_names{hsq}).x_label, '\[Hz\]', '\[GHz\]');
        graph_title_start = 'Frequency';
    else
        for nse = 1:length(temp_modes)
            x_data.(temp_modes{nse}) = data.(temp_names{hsq}).x.(temp_modes{nse});
        end %for
        x_label = data.(temp_names{hsq}).x_label;
        graph_title_start = '';
    end %if
    % interploate to 1000 points to prevent crashing the graphics.
    temp_modes = fieldnames(graph_data);
    x_range = linspace(x_data.(temp_modes{1})(1), x_data.(temp_modes{1})(end), 1000);
    for lswe = 1:length(temp_modes)
        graph_data_temp(lswe,:) = interp1(x_data.(temp_modes{lswe}), graph_data.(temp_modes{lswe}), x_range)';
    end %for
    graph_data = graph_data_temp;

    w1 = waterfall(x_range, n_modes, graph_data);
    w1.EdgeAlpha = 0.5;
    w1.FaceAlpha = 0;
    ylabel('Mode')
    xlabel(x_label{1})
    zlabel(data.(temp_names{hsq}).y_label{1})
    graph_title = [graph_title_start, '_vs_Mode_for_port_',temp_names{hsq}];
    title(graph_title, 'Interpreter','none')
    savemfmt(fig_handle, save_location, graph_title)
    clear graph_data graph_data_temp x_data x_range n_modes x_label graph_title
end %for

