function post_process_setup(paths, modelling_inputs, type_selection)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: post_process_setup(paths, run_inputs, modelling_inputs, varargin)

data_path = fullfile(paths.data_loc, modelling_inputs.base_model_name, modelling_inputs.model_name);
output_path = fullfile(paths.results_loc, modelling_inputs.base_model_name, modelling_inputs.model_name, 'postprocessing');

if ~exist(output_path, 'dir')
    mkdir(output_path)
end

data_directory = fullfile(data_path, type_selection);
pp_directory = fullfile(output_path, type_selection);

if any(contains({'geometry'}, type_selection))
    % Converting any images from ps to png to reduce the file
    % size. For larger models keeping the ps files can break the
    % filesystem.
    convert_to_png(data_directory, pp_directory)
end %if
%% Post processing wakes, eigenmode and lossy eigenmode
if any(contains({'wake', 'eigenmode', 'lossy_eigenmode'}, type_selection))
    try
        if ~exist(fullfile(pp_directory, type_selection), "dir")
            mkdir(fullfile(pp_directory, type_selection))
        end %if
        % Move files to the post processing folder.
        copyfile(fullfile(data_directory, 'model.gdf'),...
            fullfile(pp_directory,type_selection, 'model.gdf'));
        copyfile(fullfile(data_directory, 'model_log'),...
            fullfile(pp_directory, type_selection, 'model_log'));
        % Reading logs
        run_logs = GdfidL_read_logs(fullfile(pp_directory,type_selection), type_selection);
        save(fullfile(pp_directory, type_selection, 'data_from_run_logs.mat'), 'run_logs')
        save(fullfile(pp_directory, type_selection, 'run_inputs.mat'), 'modelling_inputs')

        for lae = 1:length(run_logs.port_name)
            port_folder = fullfile(pp_directory, ['wake_post_processing_ports-', run_logs.port_name{lae}]);
            if ~exist(port_folder, "dir")
                mkdir(port_folder)
            end %if
        end %for
     

    catch W_ERR
        fprintf(['\n<strong>', type_selection, ' Error</strong>'])
        display_error_message(W_ERR)
    end %try
    %% Post processing S-parameters and shunt
elseif any(contains({'sparameter', 'shunt'}, type_selection))
    try
        % Reading logs and Running postprocessor
        if strcmp(type_selection, 'sparameter')
            if ~exist(data_directory, "dir")
                mkdir(data_directory)
            end %if
            [s_names, ~] = dir_list_gen(data_directory, 'dirs', 1);
            for osw = 1:length(s_names)
                s_parameter_data_directory = fullfile(data_directory, s_names{osw});
                s_parameter_output_directory = fullfile(pp_directory, s_names{osw});
                if ~exist(s_parameter_output_directory, 'dir')
                    mkdir(s_parameter_output_directory);
                end %if
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
            postprocess_shunt;
        end %if
    catch W_ERR
        fprintf( ['\n<strong>', type_selection, ' Error</strong>'])
        display_error_message(W_ERR)
    end %try
end %if
