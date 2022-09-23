function plot_model(datasets, ppi, p_types)

for ind = 1:length(datasets)
    % location and size of the default figures.
    fig_pos = [10000 678 560 420];
    
    if isfield(datasets{ind}, 'wake') && any(contains(p_types, 'wake'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'wake'), 'png',1)) 
            disp(['Generating wake graphs for ', datasets{ind}.model_name])
            run_inputs_loc = fullfile(datasets{ind}.wake, 'postprocessing', 'wake', 'run_inputs.mat');
            analysis_loc = fullfile(datasets{ind}.wake, 'analysis', 'wake', 'data_analysed_wake.mat');
            run_logs_loc = fullfile(datasets{ind}.wake, 'postprocessing', 'wake', 'run_inputs.mat');
            GdfidL_plot_pp_wake(run_inputs_loc, analysis_loc, run_logs_loc, ppi)
        else
            disp(['Wake graphs already exists for ', datasets{ind}.model_name, '. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 'eigenmode') && any(contains(p_types, 'eigenmode'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'eigenmode'), 'png',1)) 
            disp(['Generating eigenmode graphs for ', datasets{ind}.model_name])
            GdfidL_plot_eigenmode(datasets{ind}.eigenmode, datasets{ind}.path_to_data)
        else
            disp(['eigenmode graphs already exists for ', datasets{ind}.model_name, '. Skipping...'])
        end
    end %if
    
    
    if isfield(datasets{ind}, 'lossy_eigenmode') && any(contains(p_types, 'lossy_eigenmode'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'lossy_eigenmode'), 'png',1)) 
            disp(['Generating lossy eigenmode graphs for ', datasets{ind}.model_name])
            GdfidL_plot_eigenmode_lossy(datasets{ind}.lossy_eigenmode, datasets{ind}.path_to_data)
        else
            disp(['lossy eigenmode graphs already exists for ', datasets{ind}.model_name, '. Skipping...'])
        end
    end %if
    
    
    if isfield(datasets{ind}, 'sparameter') && any(contains(p_types, 'sparameter'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'sparameter'), 'png',1)) 
            disp(['Generating s_parameter graphs for ', datasets{ind}.model_name])
            GdfidL_plot_s_parameters(datasets{ind}.sparameter, fig_pos);
        else
            disp(['s_parameter graphs already exists for ', datasets{ind}.model_name, '. Skipping...'])
        end
    end %if
    
    if isfield(datasets{ind}, 'shunt') && any(contains(p_types, 'shunt'))
        if isempty(dir_list_gen(fullfile(datasets{ind}.path_to_data, 'shunt'), 'png',1)) 
            disp(['Generating shunt graphs for ', datasets{ind}.model_name])
            GdfidL_plot_shunt(datasets{ind}.shunt)
        else
            disp(['shunt graphs already exists for ', datasets{ind}.model_name, '. Skipping...'])
        end
    end %if
end %if

