function post_process_setup(paths, modelling_inputs, type_selection)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: post_process_setup(paths, modelling_inputs, varargin)

data_path = fullfile(paths.data_loc, modelling_inputs.base_model_name, modelling_inputs.model_name);
output_path = fullfile(paths.results_loc, modelling_inputs.base_model_name, modelling_inputs.model_name, 'postprocessing');
data_directory = fullfile(data_path, type_selection);
pp_directory = fullfile(output_path, type_selection);

%% Post processing wakes, eigenmode and lossy eigenmode
if any(contains({'wake', 'eigenmode', 'lossy_eigenmode'}, type_selection))
            old = pwd;
    try
            mkdirtree(fullfile(pp_directory, type_selection))
        % Move files to the post processing folder.
        copyfile(fullfile(paths.inputfile_location, ...
            modelling_inputs.base_model_name, ...
            [modelling_inputs.base_model_name, '.m']), ...
            fullfile(pp_directory,type_selection, ...
            [modelling_inputs.base_model_name, '.m']))
        cd(fullfile(pp_directory, type_selection))
        temp = feval(modelling_inputs.base_model_name);
        cd(old)
        pp_input = temp.ppi;
        save(fullfile(pp_directory, type_selection, 'pp_inputs.mat'), "pp_input")
        copyfile(fullfile(data_directory, 'model.gdf'),...
            fullfile(pp_directory, type_selection, 'model.gdf'));
        copyfile(fullfile(data_directory, 'model_log'),...
            fullfile(pp_directory, type_selection, 'model_log'));
        % Reading logs
        run_logs = GdfidL_read_logs(fullfile(pp_directory,type_selection), type_selection);
        save(fullfile(pp_directory, type_selection, 'data_from_run_logs.mat'), 'run_logs')
        save(fullfile(pp_directory, type_selection, 'run_inputs.mat'), 'modelling_inputs')

    catch W_ERR
                cd(old)
        fprintf(['\n<strong>', type_selection, ' Error</strong>'])
        display_error_message(W_ERR)
    end %try
    %% Post processing S-parameters and shunt
elseif any(contains({'sparameter', 'shunt'}, type_selection))
    try
        % Reading logs and Running postprocessor
        if strcmp(type_selection, 'sparameter')
            if ~exist(data_directory, "dir")
                fprintf(['\nMissing directory ', data_directory])
            end %if
            [s_names, ~] = dir_list_gen(data_directory, 'dirs', 1);
            for osw = 1:length(s_names)
                s_parameter_data_directory = fullfile(data_directory, s_names{osw});
                s_parameter_output_directory = fullfile(pp_directory, s_names{osw});
                    mkdirtree(s_parameter_output_directory);
                if exist(fullfile(s_parameter_data_directory,'model_log'), 'file') ~= 2
                    fprintf(['\nMissing log file in ' s_parameter_data_directory]);
                    continue
                end %if
                copyfile(fullfile(s_parameter_data_directory,'model.gdf'),...
                    fullfile(s_parameter_output_directory, 'model.gdf'));
                copyfile(fullfile(s_parameter_data_directory,'model_log'), ...
                    fullfile(s_parameter_output_directory, 'model_log'));
                copyfile(fullfile(s_parameter_data_directory, 'run_inputs.mat'),...
                    fullfile(s_parameter_output_directory, 'run_inputs.mat'));
            end %for
        elseif strcmp(type_selection, 'shunt')
%             postprocess_shunt;
        end %if
    catch W_ERR
        fprintf( ['\n<strong>', type_selection, ' Error</strong>'])
        display_error_message(W_ERR)
    end %try
end %if
