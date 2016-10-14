function GdfidL_post_process_models(ppi)
% Takes the output of the GdfidL run and postprocesses it to generate
% reports.
%
% Example: pp_log = GdfidL_post_process_models(ui, ppi.range, 'w');

% storing the original location so that  we can retrun there at the end.
old_loc = pwd;
% Move to the scratch folder.
cd(ppi.scratch_path)
% Generating a random name to reduce the risk of name clashes.
tmp_name = tempname;
tmp_name = tmp_name(6:12);
% Make a directory with the temporary name and enter it.
mkdir(ppi.scratch_path, tmp_name)
cd([ppi.scratch_path, tmp_name])
try
    if ~exist(strcat(ppi.output_path, ppi.model_name,'/',ppi.arc_date), 'dir')
        mkdir(strcat(ppi.output_path, '/',ppi.model_name,'/',ppi.arc_date))
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
    [~]=system(['ln -s -T ',ppi.storage_path, ppi.model_name,'/',ppi.arc_date, '/ ', 'data_link']);
    [~]=system(['ln -s -T ',ppi.output_path, ppi.model_name,'/',ppi.arc_date, '/',' pp_link']);
    
    %% Save input structure
    save('pp_link/pp_inputs.mat', 'ppi')
    
    disp(['GdfidL_post_process_models: Started analysis of ', ppi.model_name])
    pp_data = struct;
    %% Post processing wakes
    if exist('data_link/wake/model_log', 'file') && ~isempty(strfind(ppi.sim_select, 'w'))
        % Creating sub structure.
        try
            if  ~exist('pp_link/wake', 'dir')
                [~] = system('mkdir pp_link/wake');
            end
            % Move files to the post processing folder.
            copyfile('data_link/wake/model.gdf','pp_link/wake/model.gdf');
            copyfile('data_link/wake/model_log','pp_link/wake/model_log');
            copyfile('data_link/wake/run_inputs.mat','pp_link/wake/');
            
            % Load up the original model input parameters.
            % This contains mi and modelling_inputs.
            load('pp_link/wake/run_inputs.mat')
            % Reading logs
            run_logs.wake = GdfidL_read_wake_log('pp_link/wake/model_log');
            save('pp_link/data_from_run_logs.mat', 'run_logs')
            disp('GdfidL_post_process_models: Post processing wake data.')
            % Running postprocessor
            orig_ver = getenv('GDFIDL_VERSION');
            setenv('GDFIDL_VERSION',run_logs.wake.ver);
            pp_data.wake_data = postprocess_wakes(ppi, mi, modelling_inputs, run_logs.wake);
            % restoring the original version.
            setenv('GDFIDL_VERSION',orig_ver)
            save('pp_link/data_postprocessed.mat', 'pp_data','-v7.3')
            % Generate the plots.
            GdfidL_plot_wake(pp_data.wake_data, ppi, mi, run_logs.wake,'pp_link/wake/', 1E7)
        catch W_ERR
            warning('Wake postprocessing failed')
            disp(['Error is :', W_ERR.message])
            disp([W_ERR.stack(1).name, ' at line ', num2str(W_ERR.stack(1).line)])
        end
    end
    %% Post processing S-parameters
    if exist('data_link/s_parameters', 'dir') && ~isempty(strfind(ppi.sim_select, 's'))
        % Creating sub structure.
        try
            if ~isempty(strfind(ppi.sim_select, 's')) && ~exist('pp_link/s_parameter', 'dir')
                [~] = system('mkdir pp_link/s_parameter');
            end
            % Move files to the post processing folder.
            copyfile('data_link/s_parameters/run_inputs.mat','pp_link/s_parameter/');
            [d_list, pth] = dir_list_gen('data_link/s_parameters','dirs');
            d_list = d_list(3:end);
            copyfile([pth, d_list{1},'/model.gdf'],'pp_link/s_parameter/model.gdf');
            if exist([pth, d_list{1},'/model_log'], 'file')
                copyfile([pth, d_list{1},'/model_log'], 'pp_link/s_parameter/model_log');
            end
            % Reading logs
            for js = 1:length(d_list)
                run_logs.s_parameter.(d_list{js}) = ...
                    GdfidL_read_s_parameter_log(['data_link/s_parameters/',d_list{js},'/model_log']);
            end
            save('pp_link/data_from_run_logs.mat', 'run_logs')
            disp('GdfidL_post_process_models: Post processing S parameter data.')
            % Running postprocessor
            orig_ver = getenv('GDFIDL_VERSION');
            setenv('GDFIDL_VERSION',run_logs.s_parameter.(d_list{1}).ver);
            pp_data.s_parameter_data = postprocess_s_parameters;
            % restoring the original version.
            setenv('GDFIDL_VERSION',orig_ver)
            save('pp_link/data_postprocessed.mat', 'pp_data')
            % location and size of the default figures.
            fig_pos = [10000 678 560 420];
            % Generate the plots for the report.
            GdfidL_plot_s_parameters(pp_data.s_parameter_data, ppi, fig_pos, 'pp_link/s_parameter/');
        catch
            warning('S-parameter postprocessing failed')
        end
    end
    %% Post processing eigenmode
    if exist('data_link/eigenmode/model_log', 'file') && ~isempty(strfind(ppi.sim_select, 'e'))
        % Creating sub structure.
        if ~isempty(strfind(ppi.sim_select, 'e')) && ~exist('pp_link/eigenmode', 'dir')
            [~] = system('mkdir pp_link/eigenmode');
        end
        % Move files to the post processing folder.
        copyfile('data_link/eigenmode/model.gdf', 'pp_link/eigenmode/model.gdf');
        copyfile('data_link/eigenmode/model_log', 'pp_link/eigenmode/model_log');
        % Reading logs
        run_logs.eigenmode = GdfidL_read_eigenmode_log('pp_link/eigenmode/model_log');
        save('pp_link/data_from_run_logs.mat', 'run_logs')
        % Running postprocessor
        disp('GdfidL_post_process_models: Post processing eigenmode data.')
        orig_ver = getenv('GDFIDL_VERSION');
        % FIXME input correct version information location
        setenv('GDFIDL_VERSION',version{1});
        pp_data.eigenmode_data = postprocess_eigenmode(ppi);
        % restoring the original version.
        setenv('GDFIDL_VERSION',orig_ver)
        save('pp_link/data_postprocessed.mat', 'pp_data')
        GdfidL_plot_eigenmode(pp_data.eigenmode_data, 'pp_link/eigenmode/')
    end
    %% Post processing lossy eigenmode
    if exist('data_link/lossy_eigenmode/model_log', 'file')&& ~isempty(strfind(ppi.sim_select, 'l'))
        % Creating sub structure.
        if ~isempty(strfind(ppi.sim_select, 'l')) && ~exist('pp_link/lossy_eigenmode', 'dir')
            [~] = system('mkdir pp_link/lossy_eigenmode');
        end
        % Move files to the post processing folder.
        copyfile('data_link/eigenmode_lossy/model.gdf', 'pp_link/lossy_eigenmode/model.gdf');
        copyfile('data_link/eigenmode_lossy/model_log', 'pp_link/lossy_eigenmode/model_log');
        % Reading logs
        run_logs.eigenmode_lossy = GdfidL_read_eigenmode_log('pp_link/lossy_eigenmode/model_log');
        save('pp_link/data_from_run_logs.mat', 'run_logs')
        disp('GdfidL_post_process_models: Post processing lossy eigenmode data.')
        % Running postprocessor
        orig_ver = getenv('GDFIDL_VERSION');
        % FIXME input correct version information location
        setenv('GDFIDL_VERSION',version{1});
        pp_data.eigenmode_lossy_data = postprocess_eigenmode_lossy(ppi);
        % restoring the original version.
        setenv('GDFIDL_VERSION',orig_ver)
        save('pp_link/data_postprocessed.mat', 'pp_data')
        GdfidL_plot_eigenmode_lossy(pp_data.eigenmode_lossy_data, 'pp_link/lossy_eigenmode/')
    end
    %% Post processing shunt
    if exist('data_link/shunt', 'dir')&& ~isempty(strfind(ppi.sim_select, 'r'))
        % Creating sub structure.
        if ~isempty(strfind(ppi.sim_select, 'r')) && ~exist('pp_link/shunt', 'dir')
            [~] = system('mkdir pp_link/shunt');
        end
        [name_list, ~] =  dir_list_gen( 'data_link/shunt','dirs');
        name_list = name_list(3:end);
        for ufs = 1:length(name_list)
            copyfile(['data_link/shunt/', num2str(name_list{ufs}),'/model_log'],['pp_link/shunt/',num2str(name_list{ufs}),'_model_log']);
        end
        % Reading logs
        [out, ~] = dir_list_gen('pp_link/shunt', '');
        out = out(3:end);
        for ief = 1:length(out)
            if  ~isempty(strfind(out{ief},'model_log')) && ~isempty(strfind(ppi.solvers, 'r'))
                run_logs.shunt = GdfidL_read_rshunt_log(['pp_link/shunt/' out{ief}]);
                break
            end
        end
    end
    save('pp_link/data_from_run_logs.mat', 'run_logs')
    % Running postprocessor
    [out, ~] = dir_list_gen('pp_link','');
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
            GdfidL_plot_shunt(pp_data.shunt_data, 'pp_link/shunt')
        else
            pp_data.shunt_data = NaN;
        end
    else
        pp_data.shunt_data = NaN;
    end
    save('pp_link/data_postprocessed.mat', 'pp_data')
    
    %% Remove the links and move back to the original directory.
    delete('pp_link')
    delete('data_link')
catch ME
    disp(['Error is :', ME.message])
    disp([ME.stack(1).name, ' at line ', num2str(ME.stack(1).line)])
end


cd(old_loc)
rmdir([ppi.scratch_path, tmp_name],'s');