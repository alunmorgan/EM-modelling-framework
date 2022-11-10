function run_logs = GdfidL_read_logs(pp_directory, sim_type)
if strcmp(sim_type, 'wake')
    run_logs = GdfidL_read_wake_log(...
        fullfile(pp_directory, 'model_log'));
elseif strcmp(sim_type, 'eigenmode')
    run_logs = GdfidL_read_eigenmode_log(...
        fullfile(pp_directory, 'model_log'), 'eigenmode');
elseif strcmp(sim_type, 'lossy_eigenmode')
    run_logs = GdfidL_read_eigenmode_log(...
        fullfile(pp_directory, 'model_log'), 'lossy_eigenmode');
end %if