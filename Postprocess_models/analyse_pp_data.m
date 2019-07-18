function analyse_pp_data(root_path, model_sets, wl_override)

for sts = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{sts}), 'mat', 1);
    wanted_files = files(contains(files, 'data_postprocessed.mat'));
    
    for ind = 1:length(wanted_files)
        current_folder = fileparts(wanted_files{ind});
        if ~isfile(fullfile(current_folder, 'data_analysed_wake.mat'))
        
        load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
        load(fullfile(current_folder, 'pp_inputs.mat'), 'ppi');
        load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
        load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
        wake_lengths_to_analyse = [str2double(modelling_inputs.wakelength),...
            str2double(modelling_inputs.wakelength) ./2,...
            str2double(modelling_inputs.wakelength) ./4];
if nargin == 3
        wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_data, modelling_inputs, ppi, run_logs, hfoi_override);
else
     wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_data, modelling_inputs, ppi, run_logs);
end %if
        save(fullfile(current_folder, 'data_analysed_wake.mat'), 'wake_sweep_data','-v7.3')
        disp(['Analysed ', current_folder])
        clear 'pp_data' 'ppi' 'run_logs' 'modelling_inputs' 'wake_sweep_data',
        else
            disp(['Analysis for ', current_folder, ' already exists... Skipping'])
        end %if
    end %for
end %for



