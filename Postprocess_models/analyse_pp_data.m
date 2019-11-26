function analyse_pp_data(root_path, model_sets, ppi, port_modes_override, analysis_override)

if nargin <5
    analysis_override = 0;
end %if

for sts = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{sts}), 'mat', 1);
    wanted_files = files(contains(files, 'data_postprocessed.mat'));
    
    for ind = 1:length(wanted_files)
        current_folder = fileparts(wanted_files{ind});
        if ~isfile(fullfile(current_folder, 'data_analysed_wake.mat')) || analysis_override == 1
            disp(['Starting analysis ', current_folder])
            load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
            % load(fullfile(current_folder, 'pp_inputs.mat'), 'ppi');
            load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
            load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
            wakelength = str2double(modelling_inputs.wakelength);
            wake_lengths_to_analyse = [];
            for ke = 1:6
                    wake_lengths_to_analyse = cat(1, wake_lengths_to_analyse, wakelength);
                    wakelength = wakelength ./2;
            end %for
                wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_data, modelling_inputs, ppi, run_logs, port_modes_override);
            disp('Analysed ')
                save(fullfile(current_folder, 'data_analysed_wake.mat'), 'wake_sweep_data','-v7.3')
            disp('Saving results')
            clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data',
        else
            disp(['Analysis for ', current_folder, ' already exists... Skipping'])
        end %if
    end %for
end %for



