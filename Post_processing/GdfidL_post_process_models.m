function pp_list = GdfidL_post_process_models(data_directory, pp_directory)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: GdfidL_post_process_models(paths, run_inputs, modelling_inputs, type_selection);
[stub, type_selection, ~] = fileparts(pp_directory);
[stub2, ~, ~] = fileparts(stub);
[~, model_name, ~] = fileparts(stub2);
fprintf(['\nWriting post processing input file for <strong>', model_name,'</strong> - ', type_selection])

pp_list = {};
% run_pp = will_pp_run(data_directory, pp_directory);
run_pp=1;
if run_pp == 1
    %% Post processing wakes, eigenmode and lossy eigenmode
    if any(contains({'wake', 'eigenmode', 'lossy_eigenmode'}, type_selection))
        try
            % Writing postprocessor input files
            if strcmp(type_selection, 'wake')
                pp_directory = fullfile(pp_directory, 'wake');
                run_logs = GdfidL_read_wake_log(fullfile(pp_directory, 'model_log'));
                [ip_files, scratch_locs] = GdfidL_write_pp_wake_input_file(run_logs, data_directory, pp_directory, fullfile('/scratch2',model_name, type_selection));
                for wh = 1:length(ip_files)
                    file_loc = write_single_postprocessing_batch_file(ip_files{wh}, scratch_locs{wh}, run_logs.ver);
                    pp_list = cat(1, pp_list, ['source "', file_loc, '"']);
                end %for
            elseif strcmp(type_selection, 'eigenmode')
                run_logs = GdfidL_read_eigenmode_log(fullfile(pp_directory, 'model_log'), 'eigenmode');
                e_scratch = fullfile('/scratch2',model_name, type_selection);
                e_file = GdfidL_write_pp_eigenmode_input_file(data_directory, pp_directory, run_logs, 'eigenmode', run_inputs.ppi, e_scratch);
                file_loc = write_single_postprocessing_batch_file(e_file, e_scratch, run_logs.ver);
                pp_list = cat(1, pp_list, ['source "', file_loc, '"']);
            elseif strcmp(type_selection, 'lossy_eigenmode')
                run_logs = GdfidL_read_eigenmode_log(fullfile(pp_directory, 'model_log'), 'lossy_eigenmode');
                le_scratch = fullfile('/scratch2',model_name, type_selection);
                le_file = GdfidL_write_pp_eigenmode_input_file(data_directory, pp_directory, run_logs, 'lossy_eigenmode', run_inputs.ppi, le_scratch);
                file_loc = write_single_postprocessing_batch_file(le_file, le_scratch, run_logs.ver);
                pp_list = cat(1, pp_list, ['source "', file_loc, '"']);

            end %if
        catch W_ERR
            fprintf(['\n<strong>', type_selection, ' Error</strong>'])
            display_error_message(W_ERR)
        end %try
        %% Post processing S-parameters and shunt
    elseif any(contains({'sparameter', 'shunt'}, type_selection))
        try
            % Reading logs and Running postprocessor
            if strcmp(type_selection, 'sparameter')
                [s_names, ~] = dir_list_gen(data_directory, 'dirs', 1);
                for osw = 1:length(s_names)
                    s_parameter_data_directory = fullfile(data_directory, s_names{osw});
                    s_parameter_output_directory = fullfile(pp_directory, s_names{osw});
                    if exist(fullfile(s_parameter_data_directory,'model_log'), 'file') ~= 2
                        fprintf(['\nMissing log file in ' s_parameter_data_directory]);
                        continue
                    end %if
                    run_logs = GdfidL_read_s_parameter_log(fullfile(s_parameter_output_directory, 'model_log'));
                    s_scratch = fullfile('/scratch2',model_name, type_selection);
                    s_file = GdfidL_write_pp_s_param_input_file(s_parameter_data_directory, s_parameter_output_directory, s_scratch);
                    file_loc = write_single_postprocessing_batch_file(s_file, s_scratch, run_logs.ver);
                    pp_list = cat(1, pp_list, ['source "', file_loc, '"']);
                end
            elseif strcmp(type_selection, 'shunt')
                %                 run_logs.(['f_', f_name]) = GdfidL_read_rshunt_log(freq_folders);
                postprocess_shunt;
            end %if
        catch W_ERR
            fprintf( ['\n<strong>', type_selection, ' Error</strong>'])
            display_error_message(W_ERR)
        end %try
    end %if
end %if
