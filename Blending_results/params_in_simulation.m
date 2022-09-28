function [param_names, param_vals, good_data, modelling_inputs] = params_in_simulation(simulation_name)
good_data = 1;
if exist(fullfile(simulation_name, 'postprocessing','wake'),'dir') == 7
    if exist(fullfile(simulation_name, 'postprocessing', 'wake','run_inputs.mat'), 'file') == 2
        try
            load(fullfile(simulation_name, 'postprocessing','wake','run_inputs.mat'), 'modelling_inputs')
        catch
            disp(['corrupted run_inputs file for ', simulation_name])
            good_data = 0;
            param_names = {NaN};
            param_vals = {NaN};
            modelling_inputs = NaN;
            return
        end %try
    else
        disp(['missing modelling_inputs for ', simulation_name])
        good_data = 0;
        param_names = {NaN};
        param_vals = {NaN};
        modelling_inputs = NaN;
        return
    end %if
    if exist(fullfile(simulation_name, 'postprocessing', 'wake','data_from_run_logs.mat'), 'file') == 2
        load(fullfile(simulation_name, 'postprocessing', 'wake', 'data_from_run_logs.mat'), 'run_logs')
    else
        disp(['missing wake data files for ', simulation_name])
        good_data = 0;
        param_names = {NaN};
        param_vals = {NaN};
        modelling_inputs = NaN;
        return
    end %if
elseif exist(fullfile(simulation_name, 'postprocessing', 's_parameter'),'dir') == 7
    s_sub_folders = dir_list_gen(fullfile(simulation_name, 'postprocessing', 's_parameter'), 'dir');
    if exist(fullfile(s_sub_folders{1},'run_inputs.mat'), 'file') == 2
        load(fullfile(s_sub_folders{1},'run_inputs.mat'), 'modelling_inputs')
    else
        disp(['missing modelling_inputs for ', simulation_name])
        good_data = 0;
        param_names = {NaN};
        param_vals = {NaN};
        modelling_inputs = NaN;
        return
    end %if
    if exist(fullfile(s_sub_folders{1},'data_from_run_logs.mat'), 'file') == 2
        load(fullfile(s_sub_folders{1}, 'data_from_run_logs.mat'), 'run_logs')
    else
        disp(['missing data files for ', simulation_name])
        good_data = 0;
        param_names = {NaN};
        param_vals = {NaN};
        modelling_inputs = NaN;
        return
    end %if
else
    disp(['No data folder found for ', simulation_name])
    good_data = 0;
    param_names = {NaN};
    param_vals = {NaN};
    modelling_inputs = NaN;
    return
end %if
[sim_param_names_tmp, sim_param_vals_tmp, ...
    geom_param_names_tmp, geom_param_vals_tmp,...
    mat_param_names_tmp, mat_param_vals_tmp] = extract_parameters(run_logs, modelling_inputs);

% Combine everything together.
param_names = cat(2,sim_param_names_tmp, geom_param_names_tmp,...
    'geometry_fraction', mat_param_names_tmp);
param_vals = cat(2,sim_param_vals_tmp, geom_param_vals_tmp,...
    modelling_inputs.geometry_fraction, mat_param_vals_tmp );

% param_names(psw,1:length(param_names)) = regexprep(param_names,'_',' ');
for ns = 1:length(param_vals)
    if ~ischar(param_vals{ns})
        param_vals{ns} = num2str(param_vals{ns});
    end %if
end %for
% param_vals(psw,1:length(param_vals)) = param_vals;