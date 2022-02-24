function plot_model(datasets, ppi, override, p_types)

for ind = 1:length(datasets)
    % location and size of the default figures.
    fig_pos = [10000 678 560 420];
    
    if isfield(datasets{ind}, 'wake') && any(contains(p_types, 'wake'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'wake'), 'png',1)) ||...
                strcmp(override{contains(p_types, 'wake')}, 'yes')
            disp(['Generating wake graphs for ', datasets{ind}.model_name])
            GdfidL_plot_pp_wake(datasets{ind}.wake, ppi)
        else
            disp(['Wake graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 'eigenmode') && any(contains(p_types, 'eigenmode'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'eigenmode'), 'png',1)) ||...
                strcmp(override{contains(p_types, 'eigenmode')}, 'yes')
            disp(['Generating eigenmode graphs for ', datasets{ind}.model_name])
            GdfidL_plot_eigenmode(datasets{ind}.eigenmode, datasets{ind}.path_to_data)
        else
            disp(['eigenmode graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    
    if isfield(datasets{ind}, 'lossy_eigenmode') && any(contains(p_types, 'lossy_eigenmode'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'lossy_eigenmode'), 'png',1)) ||...
                strcmp(override{contains(p_types, 'lossy_eigenmode')}, 'yes')
            disp(['Generating lossy eigenmode graphs for ', datasets{ind}.model_name])
            GdfidL_plot_eigenmode_lossy(datasets{ind}.lossy_eigenmode, datasets{ind}.path_to_data)
        else
            disp(['lossy eigenmode graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    
    if isfield(datasets{ind}, 's_parameter') && any(contains(p_types, 's_parameter'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 's_parameter'), 'png',1)) ||...
                strcmp(override{contains(p_types, 's_parameter')}, 'yes')
            disp(['Generating s_parameter graphs for ', datasets{ind}.model_name])
            GdfidL_plot_s_parameters(datasets{ind}.s_parameter, fig_pos);
        else
            disp(['s_parameter graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 'shunt') && any(contains(p_types, 'shunt'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'shunt'), 'png',1)) ||...
                strcmp(override{contains(p_types, 'shunt')}, 'yes')
            disp(['Generating shunt graphs for ', datasets{ind}.model_name])
            GdfidL_plot_shunt(datasets{ind}.shunt)
        else
            disp(['shunt graphs already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
        end
    end %if
end %if

