function pp_list = GdfidL_post_process_models(input_settings, model_set, model_varient)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: GdfidL_post_process_models(paths, run_inputs, modelling_inputs, type_selection);

data_directory = fullfile(input_settings.paths.data_loc, ...
    input_settings.sets{model_set}, model_varient);
pp_directory = fullfile(input_settings.paths.results_loc,...
    input_settings.sets{model_set}, model_varient,...
    'postprocessing');

pp_inputs = input_settings.ppi;
fprintf(['\nWriting post processing input files for <strong>', input_settings.sets{model_set},'</strong>'])
fprintf(['\n',model_varient])
pp_list = {};
% mkdirtree(pp_directory)
try
    if any(contains('geometry', input_settings.sim_types))
        geometry_file_loc = GdfidL_write_pp_geometry_bash_file(...
            fullfile(data_directory, 'geometry'), ...
            fullfile(pp_directory, 'geometry'));
        pp_list = cat(1, pp_list, ['source "', geometry_file_loc, '"']);
        fprintf('\nGeometry... done')
    end %if
catch W_ERR
    fprintf('\n<strong>Geometry Error</strong>')
    display_error_message(W_ERR)
end %try
try
    if any(contains('wake', input_settings.sim_types))
        wake_model_log_loc = fullfile(data_directory, 'wake','model_log');
        wake_data_dir = fullfile(data_directory, 'wake');
        wake_pp_dir = fullfile(pp_directory, 'wake');
        wake_run_logs = GdfidL_read_wake_log(wake_model_log_loc);
        wake_ip_file = GdfidL_write_pp_wake_input_file(wake_run_logs, wake_data_dir, wake_pp_dir );
        wake_file_loc = write_single_postprocessing_batch_file(wake_data_dir, wake_ip_file, wake_run_logs.ver);
        pp_list = cat(1, pp_list, ['source "', wake_file_loc, '"']);
        fprintf('\nWake... done')
    end %if
catch W_ERR
    fprintf('\n<strong>Wake Error</strong>')
    display_error_message(W_ERR)
end %try
try
    if any(contains('eigenmode', input_settings.sim_types))
        eigenmode_model_log_loc = fullfile(data_directory, 'eigenmode','model_log');
        eigenmode_data_dir = fullfile(data_directory, 'eigenmode');
        eigenmode_pp_dir = fullfile(pp_directory, 'eigenmode');
        eigenmode_run_logs = GdfidL_read_eigenmode_log(eigenmode_model_log_loc, 'eigenmode');
        e_file = GdfidL_write_pp_eigenmode_input_file(eigenmode_run_logs, eigenmode_data_dir, eigenmode_pp_dir, 'eigenmode', pp_inputs);
        eigenmode_file_loc = write_single_postprocessing_batch_file(eigenmode_data_dir, e_file, eigenmode_run_logs.ver);
        pp_list = cat(1, pp_list, ['source "', eigenmode_file_loc, '"']);
        fprintf('\nEigenmode... done')
    end %if
catch W_ERR
    fprintf('\n<strong>Eigenmode Error</strong>')
    display_error_message(W_ERR)
end %try
try
    if any(contains('lossy_eigenmode', input_settings.sim_types))
        lossy_eigenmode_model_log_loc = fullfile(data_directory, 'lossy_eigenmode','model_log');
        lossy_eigenmode_data_dir = fullfile(data_directory, 'lossy_eigenmode');
        lossy_eigenmode_pp_dir = fullfile(pp_directory, 'lossy_eigenmode');
        lossy_eigenmode_run_logs = GdfidL_read_eigenmode_log(lossy_eigenmode_model_log_loc, 'lossy_eigenmode');
        le_file = GdfidL_write_pp_eigenmode_input_file(lossy_eigenmode_run_logs, lossy_eigenmode_data_dir, lossy_eigenmode_pp_dir, 'lossy_eigenmode', pp_inputs);
        lossy_eigenmode_file_loc = write_single_postprocessing_batch_file(lossy_eigenmode_data_dir, le_file, lossy_eigenmode_run_logs.ver);
        pp_list = cat(1, pp_list, ['source "', lossy_eigenmode_file_loc, '"']);
        fprintf('\nLossy_eigenmode... done')
    end %if
catch W_ERR
    fprintf('\n<strong>Lossy_eigenmode Error</strong>')
    display_error_message(W_ERR)
end %try

try
    if any(contains('sparameter', input_settings.sim_types))
        [s_names, ~] = dir_list_gen(data_directory, 'dirs', 1);
        for osw = 1:length(s_names)
            s_parameter_data_directory = fullfile(data_directory, s_names{osw});
            s_parameter_output_directory = fullfile(pp_directory, s_names{osw});
            mkdirtree(s_parameter_output_directory)
            if exist(fullfile(s_parameter_data_directory,'model_log'), 'file') ~= 2
                fprintf(['\nMissing log file in ' s_parameter_data_directory]);
                continue
            end %if
            run_logs = GdfidL_read_s_parameter_log(fullfile(s_parameter_data_directory, 'model_log'));
            s_file = GdfidL_write_pp_s_param_input_file(s_parameter_data_directory, s_parameter_output_directory);
            file_loc = write_single_postprocessing_batch_file(s_parameter_data_directory, s_file, run_logs.ver);
            pp_list = cat(1, pp_list, ['source "', file_loc, '"']);
        end
    end %if
catch W_ERR
    fprintf( '\n<strong>Sparameter Error</strong>')
    display_error_message(W_ERR)
end %try

try
    if any(contains('shunt', input_settings.sim_types))
        %                 run_logs.(['f_', f_name]) = GdfidL_read_rshunt_log(freq_folders);
        postprocess_shunt;
    end %if
catch W_ERR
    fprintf( '\n<strong>Shunt Error</strong>')
    display_error_message(W_ERR)
end %try

