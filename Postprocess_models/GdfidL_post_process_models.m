function GdfidL_post_process_models(paths, model_name, ow_behaviour)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: pp_log = GdfidL_post_process_models(ppi);

if nargin <2
    ow_behaviour = 'skip';
end %if

% storing the original location so that  we can return there at the end.
old_loc = pwd;
tmp_name =move_into_tempororary_folder(paths.scratch_path);

if ~exist(fullfile(paths.results_path, model_name), 'dir')
    mkdir(fullfile(paths.results_path, model_name))
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
[~]=system(['ln -s -T ',fullfile(paths.storage_path, model_name), ' data_link']);
[~]=system(['ln -s -T ',fullfile(paths.results_path, model_name), ' pp_link']);

disp(['GdfidL_post_process_models: Started analysis of ', model_name])
pp_data = struct;
%% Post processing wakes, eigenmode and lossy eigenmode
sim_types = {'wake', 'eigenmode', 'eigenmode_lossy'};
for oef = 1:length(sim_types)
    if exist(fullfile('data_link', [sim_types{oef},'/']), 'dir')
        % Creating sub structure.
        try
            skip = creating_space_for_postprocessing(sim_types{oef}, ow_behaviour, model_name);
            if skip == 0
                [~] = system(['mkdir ', fullfile('pp_link', sim_types{oef})]);
                % Save input structure
%                 save(fullfile('pp_link', sim_types{oef}, 'pp_inputs.mat'), 'ppi');
                % Move files to the post processing folder.
                copyfile(fullfile('data_link', sim_types{oef}, 'model.gdf'),...
                    fullfile('pp_link', sim_types{oef}, 'model.gdf'));
                copyfile(fullfile('data_link', sim_types{oef}, 'model_log'),...
                    fullfile('pp_link', sim_types{oef}, 'model_log'));
                copyfile(fullfile('data_link', sim_types{oef}, 'run_inputs.mat'),...
                    fullfile('pp_link', [sim_types{oef} ,'/']));
                
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
        % Creating sub structure.
        try
            skip = creating_space_for_postprocessing(sim_types{heb}, ow_behaviour, model_name);
            if skip == 0
                [~] = system(['mkdir ', fullfile('pp_link', sim_types{heb})]);
                % Save input structure
%                 save(fullfile('pp_link', sim_types{heb}, 'pp_inputs.mat'), 'ppi');
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
