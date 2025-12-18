function h = plot_mtv_data(mtv_data, save_location)

h = figure(3982);
if contains(mtv_data.metadata.xlabel, 'time [s]')
    x_data = mtv_data.x_data .* 1E9;
    x_label = regexprep(mtv_data.metadata.xlabel, '\[s\]', '\[ns\]');
elseif contains(mtv_data.metadata.xlabel, 'frequency [Hz]')
    x_data = mtv_data.x_data .* 1E-9;
    x_label = regexprep(mtv_data.metadata.xlabel, '\[Hz\]', '\[GHz\]');
else
    x_data = mtv_data.x_data;
    x_label = mtv_data.metadata.xlabel;
end %if

if contains(mtv_data.metadata.subtitle, 'voltage')
    mtv_data.metadata.ylabel = 'Voltage [V]';
    graph_title = [mtv_data.metadata.subtitle];
elseif contains(mtv_data.metadata.subtitle, 'integrated') && contains(x_label, 'frequency')
    graph_title = [mtv_data.metadata.subtitle, ' frequency ', mtv_data.metadata.ports];
elseif contains(mtv_data.metadata.subtitle, 'integrated') && contains(x_label, 'time')
    graph_title = [mtv_data.metadata.subtitle, ' time ', mtv_data.metadata.ports];
elseif contains(mtv_data.metadata.subtitle, 'field')
    graph_title = [mtv_data.metadata.subtitle, ' ', mtv_data.metadata.ylabel(1),...
        ' Time:' num2str(round(str2double(mtv_data.metadata.t) * 1E9*10)/10), 'ns'];
elseif isfield(mtv_data.metadata, 'Port') && isfield(mtv_data.metadata, 'e_amp_of_mode')
    graph_title = ['Field in ',mtv_data.metadata.subtitle, ' ', mtv_data.metadata.Port,...
        ' mode ', mtv_data.metadata.e_amp_of_mode];
elseif isfield(mtv_data.metadata, 'Port') && isfield(mtv_data.metadata, 'exh_amp_of_mode')
    graph_title = ['Power in ',mtv_data.metadata.subtitle, ' ', mtv_data.metadata.Port,...
        ' mode ', mtv_data.metadata.exh_amp_of_mode];
elseif contains(mtv_data.metadata.ylabel, '|sqrt(power)/Hz|')
    graph_title = ['Power density in', mtv_data.metadata.subtitle];
    graph_title = regexprep(graph_title, '\s+out\s+(\d+)', ' mode $1');
elseif contains(mtv_data.metadata.subtitle, 'power') && contains(mtv_data.metadata.modes, 'all') &&  contains(x_label, 'frequency')
    graph_title = ['Power over frequency in all modes at', mtv_data.metadata.ports];
elseif contains(mtv_data.metadata.subtitle, 'power') && contains(mtv_data.metadata.modes, 'all') &&  contains(x_label, 'time')
    graph_title = ['Power over time in all modes at', mtv_data.metadata.ports];
elseif contains(mtv_data.metadata.subtitle, 'TEIS')
    graph_title = 'Total energy in structure';
elseif contains(mtv_data.metadata.subtitle, 'TEC')
    graph_title = 'Total energy ... (TEC)';
else
    graph_title = [mtv_data.metadata.subtitle];
end %if

plot(x_data, mtv_data.y_data)
xlabel(x_label)
ylabel(mtv_data.metadata.ylabel)
title(graph_title)

save_name = regexprep(graph_title, '\.', 'p');
save_name = regexprep(save_name, ' ', '_');
savemfmt(h, save_location, save_name)
clf(h)