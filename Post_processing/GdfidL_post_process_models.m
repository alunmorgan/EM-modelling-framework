function GdfidL_post_process_models(paths, model_name, varargin)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: pp_log = GdfidL_post_process_models(ppi);

p = inputParser;
p.StructExpand = false;
   addRequired(p,'paths');
   addRequired(p,'model_name',@isstring);
   addOptional(p,'ow_behaviour','skip',@isstring);
   addParameter(p,'input_data_location',{''},@iscell);
   parse(paths, model_name, varargin{:});

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

disp(['GdfidL_post_process_models: Started analysis of ', model_name])
pp_data = struct;
%% Post processing wakes, eigenmode and lossy eigenmode
sim_types = {'wake', 'eigenmode', 'eigenmode_lossy'};
for oef = 1:length(sim_types)
    if exist(fullfile('data_link', [sim_types{oef},'/']), 'dir')
        if strcmp(ow_behaviour, 'skip') && exist(fullfile('pp_link', sim_types{oef}), 'dir') == 7
            run_pp = 0;
        elseif strcmp(ow_behaviour, 'skip') && exist(fullfile('pp_link', sim_types{oef}), 'dir') == 0
            run_pp = 1;
        elseif strcmp(ow_behaviour, 'no_skip')
            run_pp = 1;
        else
            error('Please select skip or no_skip for the postprocessing')
        end %if
        % Creating sub structure.
        try
            
            if run_pp == 1
                creating_space_for_postprocessing(sim_types{oef}, model_name);
                % Move files to the post processing folder.
                copyfile(fullfile('data_link', sim_types{oef}, 'model.gdf'),...
                    fullfile('pp_link', sim_types{oef}, 'model.gdf'));
                copyfile(fullfile('data_link', sim_types{oef}, 'model_log'),...
                    fullfile('pp_link', sim_types{oef}, 'model_log'));
                copyfile(fullfile('data_link', sim_types{oef}, 'run_inputs.mat'),...
                    fullfile('pp_link', sim_types{oef} ,'run_inputs.mat'));
                
                % Load up the original model input parameters.
                % This contains modelling_inputs.
                load(fullfile('pp_link', sim_types{oef}, 'run_inputs.mat'))
                % Reading logs
                if strcmp(sim_types{oef}, 'wake')
                    run_logs = GdfidL_read_wake_log(...
                        fullfile('pp_link', sim_types{oef}, 'model_log'));
                elseif strcmp(sim_types{oef}, 'eigenmode') || ...
                        strcmp(sim_types{oef}, 'eigenmode_lossy')
                    run_logs = GdfidL_read_eigenmode_log(...
                        fullfile('pp_link', sim_types{oef}, 'model_log'));
                end %if
                save(fullfile('pp_link', sim_types{oef}, 'data_from_run_logs.mat'), 'run_logs')
                disp(['GdfidL_post_process_models: Post processing ', sim_types{oef}, ' data.'])
                % Running postprocessor
                orig_ver = getenv('GDFIDL_VERSION');
                setenv('GDFIDL_VERSION',run_logs.ver);
                if strcmp(sim_types{oef}, 'wake')
                    pp_data = postprocess_wakes(modelling_inputs, run_logs);
                elseif strcmp(sim_types{oef}, 'eigenmode')
                    pp_data = postprocess_eigenmode(modelling_inputs, run_logs);
                elseif strcmp(sim_types{oef}, 'eigenmode_lossy')
                    pp_data = postprocess_eigenmode_lossy(modelling_inputs, run_logs);
                end %if
                % restoring the original version.
                setenv('GDFIDL_VERSION',orig_ver)
                save(fullfile('pp_link', sim_types{oef}, 'data_postprocessed.mat'), 'pp_data','-v7.3')
            else
    disp(['Skipping ', sim_types{oef}, ' postprocessing for ',model_name, ' data already exists'])
            end %if
        catch W_ERR
            display_postprocessing_error(W_ERR, sim_types{oef})
        end %try
    end %if
    clear run_logs orig_ver pp_data modelling_inputs
end %for

%% Post processing S-parameters and shunt
sim_types = {'s_parameters', 'shunt'};
for heb = 1:length(sim_types)
    if exist(fullfile('data_link', sim_types{heb}), 'dir')
        if strcmp(ow_behaviour, 'skip') && exist(fullfile('pp_link', sim_types{heb}), 'dir') == 7
            run_pp = 0;
        elseif strcmp(ow_behaviour, 'skip') && exist(fullfile('pp_link', sim_types{heb}), 'dir') == 0
            run_pp = 1;
        elseif strcmp(ow_behaviour, 'no_skip')
            run_pp = 1;
        else
            error('Please select skip or no_skip for the postprocessing')
        end %if
        % Creating sub structure.
        try
            creating_space_for_postprocessing(sim_types{heb}, run_pp, model_name);
            if run_pp == 0
                % Move files to the post processing folder.
                copyfile(fullfile('data_link', sim_types{heb}, 'run_inputs.mat'),...
                    fullfile('pp_link', [sim_types{heb}, '/']));
                [d_list, pth] = dir_list_gen(fullfile('data_link', sim_types{heb}),'dirs', 1);
                %             d_list = d_list(3:end);
                copyfile(fullfile(pth, d_list{1},'model.gdf'),...
                    fullfile('pp_link', sim_types{heb}, 'model.gdf'));
                if exist(fullfile(pth, d_list{1},'model_log'), 'file')
                    copyfile(fullfile(pth, d_list{1},'model_log'), ...
                        fullfile('pp_link', sim_types{heb}, 'model_log'));
                end
                % Reading logs
                for js = 1:length(d_list)
                    if strcmp(sim_types{heb}, 's_parameters')
                        run_logs.(d_list{js}) = ...
                            GdfidL_read_s_parameter_log(...
                            fullfile('data_link', sim_types{heb}, d_list{js},'model_log'));
                    elseif strcmp(sim_types{heb}, 'shunt')
                        run_logs.(['f_', d_list{js}]) = ...
                            GdfidL_read_rshunt_log(fullfile('data_link', ...
                            sim_types{heb}, d_list{js},'model_log'));
                    end %if
                end
                save(fullfile('pp_link', sim_types{heb}, 'data_from_run_logs.mat'), 'run_logs')
                
                disp(['GdfidL_post_process_models: Post processing ', sim_types{heb}, ' data.'])
                % Running postprocessor
                orig_ver = getenv('GDFIDL_VERSION');
                setenv('GDFIDL_VERSION',run_logs.(d_list{1}).ver);
                if strcmp(sim_types{heb}, 's_parameters')
                    pp_data = postprocess_s_parameters;
                elseif strcmp(sim_types{heb}, 'shunt')
                    pp_data = postprocess_shunt;
                end %if
                % restoring the original version.
                setenv('GDFIDL_VERSION',orig_ver)
                save(fullfile('pp_link', sim_types{heb}, 'data_postprocessed.mat'), 'pp_data','-v7.3')
            end %if
        catch ERR
            display_postprocessing_error(ERR, sim_types{heb})
        end %try
    end %if
    clear run_logs orig_ver pp_data modelling_inputs
end %for

%% Remove the links and move back to the original directory.
delete('pp_link')
delete('data_link')
cd(old_loc)
rmdir(fullfile(tmp_name),'s');
