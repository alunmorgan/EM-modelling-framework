function GdfidL_post_process_models(paths, model_name, varargin)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: GdfidL_post_process_models(paths, model_name, 'input_data_location', '/home');

p = inputParser;
p.StructExpand = false;
validate_is_char = @(x) ischar(x);
validate_is_cell = @(x) iscell(x);
validate_is_structure = @(x) isstruct(x);
addRequired(p,'paths', validate_is_structure);
addRequired(p,'model_name', validate_is_char);
addParameter(p,'input_data_location',{''}, validate_is_cell);
addParameter(p,'type_selection','wake', validate_is_char);
parse(p, paths, model_name, varargin{:});

disp(['Started post processing of <strong>', model_name,'</strong> - ', p.Results.type_selection])
run_pp = will_pp_run(p.Results.type_selection);
if run_pp == 1
    data_directory = fullfile('data_link', p.Results.type_selection);
    pp_directory = fullfile('pp_link', p.Results.type_selection);
    creating_space_for_postprocessing(pp_directory, p.Results.type_selection, model_name);
    pp_data = struct;
    %% Post processing wakes, eigenmode and lossy eigenmode
    if any(contains({'wake', 'eigenmode', 'lossy_eigenmode'}, p.Results.type_selection))
        try
            % Move files to the post processing folder.
            copyfile(fullfile(data_directory, 'model.gdf'),...
                fullfile(pp_directory, 'model.gdf'));
            copyfile(fullfile(data_directory, 'model_log'),...
                fullfile(pp_directory, 'model_log'));
            copyfile(fullfile(data_directory, 'run_inputs.mat'),...
                fullfile(pp_directory ,'run_inputs.mat'));
            
            % Reading logs
            run_logs = GdfidL_read_logs(p.Results.type_selection);
            save(fullfile(pp_directory, 'data_from_run_logs.mat'), 'run_logs')
            
            % Load up the original model input parameters.
            load(fullfile(pp_directory, 'run_inputs.mat'), 'modelling_inputs')
            
            % Running postprocessor
            if strcmp(p.Results.type_selection, 'wake')
                postprocess_wakes(modelling_inputs, run_logs);
            elseif strcmp(p.Results.type_selection, 'eigenmode')
                pp_data = postprocess_eigenmode(modelling_inputs, run_logs, 'eigenmode');
            elseif strcmp(p.Results.type_selection, 'lossy_eigenmode')
                pp_data = postprocess_eigenmode(modelling_inputs, run_logs, 'lossy_eigenmode');
            end %if
            %                     save(fullfile('pp_link', sim_types{oef}, 'data_postprocessed.mat'), 'pp_data','-v7.3')
%             pp_logs = GdfidL_read_pp_logs(p.Results.type_selection);
%             save(fullfile(pp_directory, 'data_from_pp_logs.mat'), 'pp_logs')
        catch W_ERR
            disp( ['<strong>', p.Results.type_selection, ' Error</strong>'])
            display_error_message(W_ERR)
        end %try
        %% Post processing S-parameters and shunt
    elseif any(contains({'sparameter', 'shunt'}, p.Results.type_selection))
        try
            % Reading logs and Running postprocessor
                            [freq_folders] = dir_list_gen(data_directory, 'dirs', 1);
            if strcmp(p.Results.type_selection, 'sparameter')
                run_logs= GdfidL_read_s_parameter_log(freq_folders);
                postprocess_s_parameters(model_name);
            elseif strcmp(p.Results.type_selection, 'shunt')
                run_logs.(['f_', f_name]) = GdfidL_read_rshunt_log(freq_folders);
                pp_data = postprocess_shunt;
                
            end %if
%             save(fullfile(pp_directory, 'data_from_run_logs.mat'), 'run_logs')
%             save(fullfile(pp_directory, 'data_postprocessed.mat'), 'pp_data','-v7.3')
        catch W_ERR
            disp( ['<strong>', p.Results.type_selection, ' Error</strong>'])
            display_error_message(W_ERR)
        end %try
    end %if
end %if

