function generate_graphs(path_to_data, chosen_wake_length)
load(fullfile(path_to_data, 'wake', 'run_inputs.mat'),'modelling_inputs');
if contains(modelling_inputs.sim_select, 'w')
    GdfidL_plot_wake(path_to_data, 1E7, chosen_wake_length)
end %if
if contains(modelling_inputs.sim_select, 'e')
    GdfidL_plot_eigenmode(pp_data, path_to_data)
end %if
if contains(modelling_inputs.sim_select, 'l')
    GdfidL_plot_eigenmode_lossy(pp_data, path_to_data)
end %if
if contains(modelling_inputs.sim_select, 's')
    GdfidL_plot_s_parameters(path_to_data, fig_pos);
end %if
if contains(modelling_inputs.sim_select, 't')
    GdfidL_plot_shunt(pp_data, path_to_data)
end %if