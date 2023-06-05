function GdfidL_post_process_models(data_directory_base, pp_directory_base, model_name, varargin)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: GdfidL_post_process_models(paths, model_name, 'input_data_location', '/home');

p = inputParser;
p.StructExpand = false;
validate_is_char = @(x) ischar(x);
validate_is_cell = @(x) iscell(x);
% validate_is_structure = @(x) isstruct(x);
% addRequired(p,'paths', validate_is_structure);
addRequired(p,'data_directory_base');
addRequired(p,'pp_directory_base');
addRequired(p,'model_name', validate_is_char);
addParameter(p,'input_data_location',{''}, validate_is_cell);
addParameter(p,'type_selection','wake', validate_is_char);
parse(p, data_directory_base, pp_directory_base, model_name, varargin{:});

fprinf(['\nStarted post processing of <strong>', model_name,'</strong> - ', p.Results.type_selection])

data_directory = fullfile(data_directory_base, p.Results.type_selection);
pp_directory = fullfile(pp_directory_base, p.Results.type_selection);

run_pp = will_pp_run(data_directory, pp_directory);

if run_pp == 1
%     creating_space_for_postprocessing(pp_directory, p.Results.type_selection, model_name);
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
            run_logs = GdfidL_read_logs(pp_directory, p.Results.type_selection);
            save(fullfile(pp_directory, 'data_from_run_logs.mat'), 'run_logs')
            
            % Load up the original model input parameters.
            load(fullfile(pp_directory, 'run_inputs.mat'), 'modelling_inputs')
            
            % Running postprocessor
            if strcmp(p.Results.type_selection, 'wake')
                postprocess_wakes(modelling_inputs, run_logs, data_directory, pp_directory);
            elseif strcmp(p.Results.type_selection, 'eigenmode')
                postprocess_eigenmode(modelling_inputs, run_logs, 'eigenmode');
            elseif strcmp(p.Results.type_selection, 'lossy_eigenmode')
                postprocess_eigenmode(modelling_inputs, run_logs, 'lossy_eigenmode');
            end %if
        catch W_ERR
            fprinf(['\n<strong>', p.Results.type_selection, ' Error</strong>'])
            display_error_message(W_ERR)
        end %try
        %% Post processing S-parameters and shunt
    elseif any(contains({'sparameter', 'shunt'}, p.Results.type_selection))
        try
            % Reading logs and Running postprocessor
%             [freq_folders] = dir_list_gen(data_directory, 'dirs', 1);
            if strcmp(p.Results.type_selection, 'sparameter')
%                 run_logs= GdfidL_read_s_parameter_log(freq_folders);
                postprocess_s_parameters(data_directory, pp_directory);
            elseif strcmp(p.Results.type_selection, 'shunt')
%                 run_logs.(['f_', f_name]) = GdfidL_read_rshunt_log(freq_folders);
                postprocess_shunt;     
            end %if
        catch W_ERR
            fprinf( ['\n<strong>', p.Results.type_selection, ' Error</strong>'])
            display_error_message(W_ERR)
        end %try
    end %if
end %if

