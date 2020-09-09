function GdfidL_post_process_models(paths, model_name, varargin)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: pp_log = GdfidL_post_process_models(paths, model_name, 'ow_behaviour','skip', 'input_data_location', '/home');

p = inputParser;
p.StructExpand = false;
validate_is_char = @(x) ischar(x);
validate_is_cell = @(x) iscell(x);
validate_is_structure = @(x) isstruct(x);
addRequired(p,'paths', validate_is_structure);
addRequired(p,'model_name', validate_is_char);
addParameter(p,'ow_behaviour','skip', validate_is_char);
addParameter(p,'input_data_location',{''}, validate_is_cell);
addParameter(p,'type_selection',{'all'}, validate_is_cell);
parse(p, paths, model_name, varargin{:});

results_path = p.Results.paths.results_path;
if ~isempty(p.Results.input_data_location{1})
    storage_path = p.Results.input_data_location;
else
    storage_path = p.Results.paths.storage_path;
end %if
% storing the original location so that  we can return there at the end.
[old_loc, tmp_name] =move_into_tempororary_folder(paths.scratch_path);

if ~exist(fullfile(results_path, model_name), 'dir')
    mkdir(fullfile(results_path, model_name))
end
% make soft links to the data folder and output folder into /scratch.
% this is because the post processor does not handle long paths well.
% this makes things more controlled.
if exist('data_link','dir') ~= 0
    delete('data_link')
end
if exist('pp_link','dir') ~= 0
    delete('pp_link')
end
[~]=system(['ln -s -T ',fullfile(storage_path, model_name), ' data_link']);
[~]=system(['ln -s -T ',fullfile(results_path, model_name), ' pp_link']);

disp(['GdfidL_post_process_models: Started post processing of ', model_name])
pp_data = struct;
%% Post processing wakes, eigenmode and lossy eigenmode
sim_types = {'wake', 'eigenmode', 'eigenmode_lossy'};
for oef = 1:length(sim_types)
    if any(contains(p.Results.type_selection, sim_types{oef})) || any(contains(p.Results.type_selection, 'all'))
        if exist(fullfile('data_link', [sim_types{oef},'/']), 'dir')
            run_pp = will_pp_run(sim_types{oef}, p.Results.ow_behaviour);
            if run_pp == 1
                try
                    data_directory = fullfile('data_link', sim_types{oef});
                    pp_directory = fullfile('pp_link', sim_types{oef});
                    creating_space_for_postprocessing(pp_directory, sim_types{oef}, model_name);
                    % Move files to the post processing folder.
                    copyfile(fullfile(data_directory, 'model.gdf'),...
                        fullfile(pp_directory, 'model.gdf'));
                    copyfile(fullfile(data_directory, 'model_log'),...
                        fullfile(pp_directory, 'model_log'));
                    copyfile(fullfile(data_directory, 'run_inputs.mat'),...
                        fullfile(pp_directory ,'run_inputs.mat'));
                    
                    % Reading logs
                    run_logs = GdfidL_read_logs(sim_types{oef});
                    save(fullfile(pp_directory, 'data_from_run_logs.mat'), 'run_logs')
                    
                    % Load up the original model input parameters.
                    load(fullfile(pp_directory, 'run_inputs.mat'), 'modelling_inputs')
                    
                    % Running postprocessor
                    if strcmp(sim_types{oef}, 'wake')
                        pp_data = postprocess_wakes(modelling_inputs, run_logs);
                    elseif strcmp(sim_types{oef}, 'eigenmode')
                        pp_data = postprocess_eigenmode(modelling_inputs, run_logs);
                    elseif strcmp(sim_types{oef}, 'eigenmode_lossy')
                        pp_data = postprocess_eigenmode_lossy(modelling_inputs, run_logs);
                    end %if
                    save(fullfile('pp_link', sim_types{oef}, 'data_postprocessed.mat'), 'pp_data','-v7.3')
                catch W_ERR
                    display_postprocessing_error(W_ERR, sim_types{oef})
                end %try
            else
                disp(['Skipping ', sim_types{oef}, ' postprocessing for ',model_name, ' data already exists'])
            end %if
        end %if
    end %if
    clear run_logs orig_ver pp_data modelling_inputs
end %for

%% Post processing S-parameters and shunt
sim_types = {'s_parameter', 'shunt'};
for heb = 1:length(sim_types)
    if any(contains(p.Results.type_selection, sim_types{heb})) || any(contains(p.Results.type_selection, 'all'))
        if exist(fullfile('data_link', sim_types{heb}), 'dir')
            run_pp = will_pp_run(sim_types{heb}, p.Results.ow_behaviour);
            if run_pp == 1
                %             try
                %                 [freq_folders] = dir_list_gen(fullfile('data_link', sim_types{heb}),'dirs', 1);
                %                 data_directory = freq_folders{1};
                %                 pp_directory = fullfile('pp_link', sim_types{heb});
                %                  creating_space_for_postprocessing(pp_directory, sim_types{heb}, model_name);
                %                 % Move files to the post processing folder.
                %
                %                 copyfile(fullfile(data_directory,'model.gdf'),...
                %                     fullfile(pp_directory, 'model.gdf'));
                %                 copyfile(fullfile(data_directory,'model_log'), ...
                %                     fullfile(pp_directory, 'model_log'));
                %                 copyfile(fullfile(data_directory, 'run_inputs.mat'),...
                %                     fullfile(pp_directory, 'run_inputs.mat'));
                %                                % Load up the original model input parameters.
                %                 load(fullfile(pp_directory, 'run_inputs.mat'), 'modelling_inputs')
                
                disp(['GdfidL_post_process_models: Post processing ', sim_types{heb}, ' data.'])
                % Reading logs and Running postprocessor
                if strcmp(sim_types{heb}, 's_parameter')
                    [freq_folders] = dir_list_gen(fullfile('data_link', sim_types{heb}),'dirs', 1);
                    run_logs= GdfidL_read_s_parameter_log(freq_folders);
                    pp_data = postprocess_s_parameters(model_name);
                elseif strcmp(sim_types{heb}, 'shunt')
                    run_logs.(['f_', f_name]) = GdfidL_read_rshunt_log(freq_folders);
                    pp_data = postprocess_shunt;
                    
                end %if
                save(fullfile('pp_link', sim_types{heb}, 'data_from_run_logs.mat'), 'run_logs')
                save(fullfile('pp_link', sim_types{heb}, 'data_postprocessed.mat'), 'pp_data','-v7.3')
                %             catch ERR
                %                 display_postprocessing_error(ERR, sim_types{heb})
                %             end %try
            else
                disp(['Skipping ', sim_types{heb}, ' postprocessing for ',model_name, ' data already exists'])
            end %if
        end %if
    end %if
    clear run_logs orig_ver pp_data modelling_inputs
end %for

%% Remove the links and move back to the original directory.
delete('pp_link')
delete('data_link')
cd(old_loc)
rmdir(fullfile(tmp_name),'s');
