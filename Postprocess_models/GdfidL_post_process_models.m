function GdfidL_post_process_models(ppi)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: pp_log = GdfidL_post_process_models(ui, ppi.range, 'w');

% storing the original location so that  we can return there at the end.
old_loc = pwd;
move_into_tempororary_folder(ppi.scratch_path);

if ~exist(fullfile(ppi.output_path, ppi.model_name, ppi.arc_date), 'dir')
    mkdir(fullfile(ppi.output_path, ppi.model_name, ppi.arc_date))
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
[~]=system(['ln -s -T ',fullfile(ppi.storage_path, ppi.model_name, ppi.arc_date), ' data_link']);
[~]=system(['ln -s -T ',fullfile(ppi.output_path, ppi.model_name, ppi.arc_date), ' pp_link']);

%% Save input structure
save(fullfile('pp_link', 'pp_inputs.mat'), 'ppi')

disp(['GdfidL_post_process_models: Started analysis of ', ppi.model_name])
pp_data = struct;
%% Post processing wakes
if exist(fullfile('data_link', 'wake/'), 'dir')
    % Creating sub structure.
    try
        if  ~exist(fullfile('pp_link', 'wake'), 'dir')
            [~] = system(['mkdir ', fullfile('pp_link', 'wake')]);
        end
        % Move files to the post processing folder.
        copyfile(fullfile('data_link', 'wake', 'model.gdf'),...
            fullfile('pp_link', 'wake', 'model.gdf'));
        copyfile(fullfile('data_link', 'wake', 'model_log'),...
            fullfile('pp_link', 'wake', 'model_log'));
        copyfile(fullfile('data_link', 'wake', 'run_inputs.mat'),...
            fullfile('pp_link', 'wake/'));
        
        % Load up the original model input parameters.
        % This contains modelling_inputs.
        load(fullfile('pp_link', 'wake', 'run_inputs.mat'))
        % Reading logs
        run_logs.wake = GdfidL_read_wake_log(...
            fullfile('pp_link', 'wake', 'model_log'));
        save(fullfile('pp_link', 'data_from_run_logs.mat'), 'run_logs')
        
        disp('GdfidL_post_process_models: Post processing wake data.')
        % Running postprocessor
        orig_ver = getenv('GDFIDL_VERSION');
        setenv('GDFIDL_VERSION',run_logs.wake.ver);
        pp_data.wake_data = postprocess_wakes(ppi, modelling_inputs, run_logs.wake);
        % restoring the original version.
        setenv('GDFIDL_VERSION',orig_ver)
        save('pp_link/data_postprocessed.mat', 'pp_data','-v7.3')
        % Generate the plots.
        GdfidL_plot_wake(pp_data.wake_data, ppi, ...
            modelling_inputs, run_logs.wake,...
            fullfile('pp_link', 'wake/'), 1E7)
    catch W_ERR
        display_postprocessing_error(W_ERR, 'wake')
    end
end
%% Post processing S-parameters
if exist(fullfile('data_link', 's_parameters'), 'dir')
    % Creating sub structure.
    try
        if ~exist(fullfile('pp_link', 's_parameter'), 'dir')
            [~] = system(['mkdir ', fullfile('pp_link', 's_parameter')]);
        end
        % Move files to the post processing folder.
        copyfile(fullfile('data_link', 's_parameters', 'run_inputs.mat'),...
            fullfile('pp_link', 's_parameter/'));
        [d_list, pth] = dir_list_gen(fullfile('data_link', 's_parameters'),'dirs', 1);
        d_list = d_list(3:end);
        copyfile(fullfile(pth, d_list{1},'model.gdf'),...
            fullfile('pp_link', 's_parameter', 'model.gdf'));
        if exist(fullfile(pth, d_list{1},'model_log'), 'file')
            copyfile(fullfile(pth, d_list{1},'model_log'), ...
                fullfile('pp_link', 's_parameter', 'model_log'));
        end
        % Reading logs
        for js = 1:length(d_list)
            run_logs.s_parameter.(d_list{js}) = ...
                GdfidL_read_s_parameter_log(...
                fullfile('data_link', 's_parameters',d_list{js},'model_log'));
        end
        save(fullfile('pp_link', 'data_from_run_logs.mat'), 'run_logs')
        
        disp('GdfidL_post_process_models: Post processing S parameter data.')
        % Running postprocessor
        orig_ver = getenv('GDFIDL_VERSION');
        setenv('GDFIDL_VERSION',run_logs.s_parameter.(d_list{1}).ver);
        pp_data.s_parameter_data = postprocess_s_parameters;
        % restoring the original version.
        setenv('GDFIDL_VERSION',orig_ver)
        save(fullfile('pp_link', 'data_postprocessed.mat'), 'pp_data')
        % location and size of the default figures.
        fig_pos = [10000 678 560 420];
        % Generate the plots for the report.
        GdfidL_plot_s_parameters(pp_data.s_parameter_data, ppi, fig_pos, ...
            fullfile('pp_link', 's_parameter/'));
    catch ERR
        display_postprocessing_error(ERR, 'S-parameter')
    end
end
%% Post processing eigenmode
if exist(fullfile('data_link', 'eigenmode/'), 'dir')
    % Creating sub structure.
    if ~exist(fullfile('pp_link', 'eigenmode'), 'dir')
        [~] = system(['mkdir ', fullfile('pp_link', 'eigenmode')]);
    end
    % Move files to the post processing folder.
    copyfile(fullfile('data_link', 'eigenmode/model.gdf'),...
        fullfile('pp_link', 'eigenmode/model.gdf'));
    copyfile(fullfile('data_link', 'eigenmode/model_log'),...
        fullfile('pp_link', 'eigenmode/model_log'));
    % Reading logs
    run_logs.eigenmode = GdfidL_read_eigenmode_log(...
        fullfile('pp_link', 'eigenmode', 'model_log'));
    save(fullfile('pp_link', 'data_from_run_logs.mat'), 'run_logs')
    
    % Running postprocessor
    disp('GdfidL_post_process_models: Post processing eigenmode data.')
    orig_ver = getenv('GDFIDL_VERSION');
    pp_data.eigenmode_data = postprocess_eigenmode(ppi);
    % restoring the original version.
    setenv('GDFIDL_VERSION',orig_ver)
    save(fullfile('pp_link', 'data_postprocessed.mat'), 'pp_data')
    GdfidL_plot_eigenmode(pp_data.eigenmode_data, fullfile('pp_link', 'eigenmode/'))
end
%% Post processing lossy eigenmode
if exist(fullfile('data_link', 'lossy_eigenmode/'), 'dir')
    % Creating sub structure.
    if ~exist(fullfile('pp_link', 'lossy_eigenmode'), 'dir')
        [~] = system(['mkdir ', fullfile('pp_link', 'lossy_eigenmode')]);
    end
    % Move files to the post processing folder.
    copyfile(fullfile('data_link', 'eigenmode_lossy', 'model.gdf'),...
        fullfile('pp_link', 'lossy_eigenmode', 'model.gdf'));
    copyfile(fullfile('data_link', 'eigenmode_lossy', 'model_log'),...
        fullfile('pp_link', 'lossy_eigenmode', 'model_log'));
    % Reading logs
    run_logs.eigenmode_lossy = GdfidL_read_eigenmode_log(...
        fullfile('pp_link', 'lossy_eigenmode', 'model_log'));
    save(fullfile('pp_link', 'data_from_run_logs.mat'), 'run_logs')
    disp('GdfidL_post_process_models: Post processing lossy eigenmode data.')
    
    % Running postprocessor
    orig_ver = getenv('GDFIDL_VERSION');
    pp_data.eigenmode_lossy_data = postprocess_eigenmode_lossy(ppi);
    % restoring the original version.
    setenv('GDFIDL_VERSION',orig_ver)
    save(fullfile('pp_link', 'data_postprocessed.mat'), 'pp_data')
    GdfidL_plot_eigenmode_lossy(pp_data.eigenmode_lossy_data, ...
        fullfile('pp_link', 'lossy_eigenmode/'))
end
%% Post processing shunt
if exist(fullfile('data_link', 'shunt'), 'dir')
    try
        % Creating sub structure.
        if ~exist(fullfile('pp_link', 'shunt'), 'dir')
            [~] = system(['mkdir ', fullfile('pp_link', 'shunt')]);
        end
        [name_list, ~] =  dir_list_gen(fullfile('data_link', 'shunt'),'dirs', 1);
        name_list = name_list(3:end);
        for ufs = 1:length(name_list)
            copyfile(fullfile('data_link', 'shunt', num2str(name_list{ufs}),'model_log'),...
                fullfile('pp_link', 'shunt', [num2str(name_list{ufs}),'_model_log']));
        end
        % Reading logs
        [out, ~] = dir_list_gen(fullfile('pp_link', 'shunt'), '', 1);
        out = out(3:end);
        for ief = 1:length(out)
            if  ~isempty(strfind(out{ief},'model_log')) && ~isempty(strfind(ppi.solvers, 'r'))
                run_logs.shunt = GdfidL_read_rshunt_log(fullfile('pp_link', 'shunt', out{ief}));
                break
            end
        end
        
        save(fullfile('pp_link', 'data_from_run_logs.mat'), 'run_logs')
        % Running postprocessor
        [out, ~] = dir_list_gen('pp_link','', 1);
        tst = 0;
        if  ~isempty(strfind(ppi.sim_select, 'r'))
            for psw = 1:length(out)
                if ~isempty(strfind(out{psw}, 'shunt'))
                    tst = 1;
                    break
                end
            end
            if tst == 1
                disp('GdfidL_post_process_models: Post processing shunt data.')
                pp_data.shunt_data = postprocess_shunt(ppi);
                GdfidL_plot_shunt(pp_data.shunt_data, fullfile('pp_link', 'shunt'))
            else
                pp_data.shunt_data = NaN;
            end
        else
            pp_data.shunt_data = NaN;
        end
        save(fullfile('pp_link', 'data_postprocessed.mat'), 'pp_data')
        
    catch ME
        display_postprocessing_error(ME, 'shunt')
    end %try
end %if

%% Remove the links and move back to the original directory.
delete('pp_link')
delete('data_link')
cd(old_loc)
rmdir(fullfile(ppi.scratch_path, tmp_name),'s');