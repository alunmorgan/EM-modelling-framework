function analyse_pp_data(root_path, model_set)

files = dir_list_gen_tree(fullfile(root_path, model_set), '', 1);
wanted_files = files(contains(files, ['wake', filesep, 'model_wake_post_processing_log']));

for ind = 1:length(wanted_files)
    current_folder = fileparts(wanted_files{ind});
    if ~isfile(fullfile(current_folder, 'data_analysed_wake.mat'))
        [a1,~,~]= fileparts(current_folder);
        [~,name_of_model,~] = fileparts(a1);
        disp(['Starting analysis <strong>', name_of_model, '</strong>'])

        run_logs = load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
        run_logs = run_logs.run_logs;

        modelling_inputs = load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
        modelling_inputs = modelling_inputs.modelling_inputs;
        
%         pp_logs = GdfidL_read_pp_wake_log(current_folder);
        output_file_locations = GdfidL_find_ouput(current_folder);
        pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);
        
        pp_data.port.data = port_data_fill_factor_scaling(pp_data.port.data, modelling_inputs.port_fill_factor);
%         pp_data.port.data = port_data_remove_non_transmitting(pp_data.port.data, run_logs);
        if isfield(pp_data.port.data, 'time')
            % If there are no transmitting modes then there is no port data.
            pp_data.port.data.time = port_data_separate_remnant(pp_data.port.data.time, pp_data.port.timebase, modelling_inputs.beam_sigma);
        end %if
        
        fprintf('Analysed ... Saving...')
        save(fullfile(current_folder, 'data_analysed_wake.mat'), 'pp_data','-v7.3')
        fprintf('Saved\n')
        clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data' 'current_folder'
    else
        [a,~,~] = fileparts(current_folder);
        [~,c,~] = fileparts(a);
        disp(['Analysis for ', c, ' already exists... Skipping'])
    end %if
end %for



