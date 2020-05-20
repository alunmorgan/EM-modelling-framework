function generate_graphs(dataset, ppi, chosen_wake_length)

% location and size of the default figures.
fig_pos = [10000 678 560 420];
if isfield(dataset, 'wake')
    GdfidL_plot_wake(dataset.wake, ppi, 1E7, chosen_wake_length)
end %if
if isfield(dataset, 'eigenmode')
    GdfidL_plot_eigenmode(dataset.eigenmode, path_to_data)
end %if
if isfield(dataset, 'lossy_eigenmode')
    GdfidL_plot_eigenmode_lossy(dataset.lossy_eigenmode, path_to_data)
end %if
if isfield(dataset, 's_parameter')
    GdfidL_plot_s_parameters(dataset.s_parameter, fig_pos);
end %if
if isfield(dataset, 'shunt')
    GdfidL_plot_shunt(dataset.shunt)
end %if