function GdfidL_post_process_models(ppi, ow_behaviour)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: pp_log = GdfidL_post_process_models(ui, ppi.range, 'w');

if nargin <2
    ow_behaviour = 'skip';
end %if

% storing the original location so that  we can return there at the end.
old_loc = pwd;
tmp_name =move_into_tempororary_folder(ppi.scratch_path);

if ~exist(fullfile(ppi.output_path, ppi.model_name), 'dir')
    mkdir(fullfile(ppi.output_path, ppi.model_name))
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
[~]=system(['ln -s -T ',fullfile(ppi.storage_path, ppi.model_name), ' data_link']);
[~]=system(['ln -s -T ',fullfile(ppi.output_path, ppi.model_name), ' pp_link']);

disp(['GdfidL_post_process_models: Started analysis of ', ppi.model_name])
pp_data = struct;
%% Post processing wakes, eigenmode and lossy eigenmode
sim_types = {'wake', 'eigenmode', 'eigenmode_lossy'};
for oef = 1:length(sim_types)
    if exist(fullfile('data_link', [sim_types{oef},'/']), 'dir')
        % Creating sub structure.
        try
            skip = creating_space_for_postprocessing(sim_types{oef}, ow_behaviour, ppi.model_name);
            if skip == 0;
                [~] = system(['mkdir ', fullfile('pp_link', sim_types{oef})]);
                % Save input structure
                save(fullfile('pp_link', sim_types{oef}, 'pp_inputs.mat'), 'ppi');
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
                    pp_data = postprocess_wakes(ppi, modelling_inputs, run_logs);
                elseif strcmp(sim_types{oef}, 'eigenmode')
                    pp_data = postprocess_eigenmode(modelling_inputs, run_logs);
                elseif strcmp(sim_types{oef}, 'eigenmode_lossy')
                    pp_data = postprocess_eigenmode_lossy(modelling_inputs, run_logs);
                end %if
                % restoring the original version.
                setenv('GDFIDL_VERSION',orig_ver)
                save(fullfile('pp_link', sim_types{oef}, 'data_postprocessed.mat'), 'pp_data','-v7.3')
                % Generate the plots.
                if strcmp(sim_types{oef}, 'wake')
                    GdfidL_plot_wake(pp_data, ppi, ...
                        modelling_inputs, run_logs,...
                        fullfile('pp_link', [sim_types{oef}, '/']), 1E7)
                elseif strcmp(sim_types{oef}, 'eigenmode')
                    GdfidL_plot_eigenmode(pp_data, fullfile('pp_link', [sim_types{oef}, '/']))
                elseif strcmp(sim_types{oef}, 'eigenmode_lossy')
                    GdfidL_plot_eigenmode_lossy(pp_data, fullfile('pp_link', [sim_types{oef}, '/']))
                end %if
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
            skip = creating_space_for_postprocessing(sim_types{heb}, ow_behaviour, ppi.model_name);
            if skip == 0
                [~] = system(['mkdir ', fullfile('pp_link', sim_types{heb})]);
                % Save input structure
                save(fullfile('pp_link', sim_types{heb}, 'pp_inputs.mat'), 'ppi');
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
                % location and size of the default figures.
                fig_pos = [10000 678 560 420];
                % Generate the plots for the report.
                if strcmp(sim_types{heb}, 's_parameters')
                    GdfidL_plot_s_parameters(pp_data, ppi, fig_pos, ...
                        fullfile('pp_link', [sim_types{heb}, '/']));
                elseif strcmp(sim_types{heb}, 'shunt')
                    GdfidL_plot_shunt(pp_data, fullfile('pp_link', sim_types{heb}))
                end %if
            end %if
        catch ERR
            display_postprocessing_error(ERR, sim_types{heb})
        end %try
    end %if
    clear run_logs orig_ver pp_data modelling_inputs
end %for

% %% Post processing shunt
% sim_type = 'shunt';
% if exist(fullfile('data_link', sim_type), 'dir')
%     try
%         % Creating sub structure.
%         skip = creating_space_for_postprocessing(sim_type, ow_behaviour, ppi.model_name);
%         if skip == 0
%             [~] = system(['mkdir ', fullfile('pp_link', sim_type)]);
%             % Save input structure
%             save(fullfile('pp_link', sim_type, 'pp_inputs.mat'), 'ppi');
%             [name_list, ~] =  dir_list_gen(fullfile('data_link', sim_type),'dirs', 1);
%             name_list = name_list(3:end);
%             for ufs = 1:length(name_list)
%                 copyfile(fullfile('data_link', sim_type, num2str(name_list{ufs}),'model_log'),...
%                     fullfile('pp_link', sim_type, [num2str(name_list{ufs}),'_model_log']));
%             end % for
%             % Reading logs
%             [out, ~] = dir_list_gen(fullfile('data_link', sim_type),'dirs', 1);
%             for ief = 1:length(out)
%                 run_logs.(['f_', out{ief}]) = GdfidL_read_rshunt_log(fullfile('data_link', sim_type, out{ief},'model_log'));
%             end %for
%
%             save(fullfile('pp_link', sim_type, 'data_from_run_logs.mat'), 'run_logs')
%             disp(['GdfidL_post_process_models: Post processing ', sim_type,' data.'])
%             % Running postprocessor
%             orig_ver = getenv('GDFIDL_VERSION');
%             setenv('GDFIDL_VERSION',run_logs.(['f_', out{1}]).ver);
%             pp_data.shunt_data = postprocess_shunt;
%             % restoring the original version.
%             setenv('GDFIDL_VERSION',orig_ver)
%             save(fullfile('pp_link', sim_type, 'data_postprocessed.mat'), 'pp_data','-v7.3')
%             GdfidL_plot_shunt(pp_data, fullfile('pp_link', sim_type))
%
%         end %if
%     catch ME
%         display_postprocessing_error(ME, sim_type)
%     end %try
% end %if
% clear run_logs orig_ver pp_data modelling_inputs
%% Remove the links and move back to the original directory.
delete('pp_link')
delete('data_link')
cd(old_loc)
rmdir(fullfile(tmp_name),'s');
end % function

function skip = creating_space_for_postprocessing(sim_type, ow_behaviour, model_name)
skip = 0;
if exist(fullfile('pp_link', sim_type), 'dir')
    if strcmp(ow_behaviour, 'no_skip')
        old_store = ['old_data', datestr(now,30)];
        mkdir('pp_link', old_store)
        movefile(fullfile('pp_link', sim_type), fullfile('pp_link', old_store))
    else
        disp(['Skipping ', sim_type, ' postprocessing for ',model_name, ' data already exists'])
        skip = 1;
    end %if
end %if
end %function