function pp_logs = GdfidL_read_pp_logs(sim_type)
if strcmp(sim_type, 'wake')
    pp_logs = GdfidL_read_pp_wake_log(...
        fullfile('pp_link', sim_type, ['model_',sim_type,'_post_processing_log']));
% elseif strcmp(sim_type, 'eigenmode')
%     run_logs = GdfidL_read_pp_eigenmode_log(...
%         fullfile('pp_link', sim_type, 'model_log'), 'eigenmode');
% elseif strcmp(sim_type, 'lossy_eigenmode')
%     run_logs = GdfidL_read_pp_eigenmode_log(...
%         fullfile('pp_link', sim_type, 'model_log'), 'lossy_eigenmode');
end %if