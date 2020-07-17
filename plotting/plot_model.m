function plot_model(root_path, ppi, input_settings, override)

datasets = find_datasets(fullfile(root_path, input_settings{1}));

% split_str = regexp(path_to_data, filesep, 'split');
for ind = 1:length(datasets)
    % location and size of the default figures.
    fig_pos = [10000 678 560 420];
    if isfield(datasets{ind}, 'wake')
        if override == 1 || isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'wake'), 'png',1))
            disp(['Generating wake graphs for ', datasets{ind}.model_name])
            GdfidL_plot_wake(datasets{ind}.wake, ppi, 1E7, input_settings{4})
        else
            disp(['Wake graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 'eigenmode')
        if override == 1 || isempty(dir_list_gen(datasets{ind}.eigenmode, 'png',1))
            disp(['Generating eigenmode graphs for ', datasets{ind}.model_name])
            GdfidL_plot_eigenmode(datasets{ind}.eigenmode, path_to_data)
        else
            disp(['eigenmode graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 'lossy_eigenmode')
        if override == 1 || isempty(dir_list_gen(datasets{ind}.lossy_eigenmode, 'png',1))
            disp(['Generating lossy eigenmode graphs for ', datasets{ind}.model_name])
            GdfidL_plot_eigenmode_lossy(datasets{ind}.lossy_eigenmode, path_to_data)
        else
            disp(['lossy eigenmode graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 's_parameter')
        test= dir_list_gen(fullfile(datasets{ind}.path_to_data, 's_parameter'), 'dirs', 1);
        for nss = 1:length(test)
            if override == 1 || isempty(dir_list_gen(test{nss}, 'png', 1))
                disp(['Generating s_parameter graphs for ', datasets{ind}.model_name])
                GdfidL_plot_s_parameters(test{nss}, fig_pos);
            else
                disp(['s_parameter graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
            end
        end %for
    end %if
    
    if isfield(datasets{ind}, 'shunt')
        if override == 1 || isempty(dir_list_gen(datasets{ind}.shunt, 'png', 1))
            disp(['Generating shunt graphs for ', datasets{ind}.model_name])
            GdfidL_plot_shunt(datasets{ind}.shunt)
        else
            disp(['shunt graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
end %for
