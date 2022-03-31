function analyse_pp_data(root_path, model_set)

files = dir_list_gen_tree(fullfile(root_path, model_set), 'mat', 1);
wanted_files = files(contains(files, ['wake', filesep, 'data_from_pp_logs.mat']));

for ind = 1:length(wanted_files)
    current_folder = fileparts(wanted_files{ind});
    if ~isfile(fullfile(current_folder, 'data_postprocessed.mat'))
        [a1,~,~]= fileparts(current_folder);
        [~,name_of_model,~] = fileparts(a1);
        disp(['Starting analysis <strong>', name_of_model, '</strong>'])
        run_logs = load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
        run_logs = run_logs.run_logs;
        modelling_inputs = load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
        modelling_inputs = modelling_inputs.modelling_inputs;
        
        output_file_locations = GdfidL_find_ouput(current_folder);
        pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);   
        pp_data.port.data = port_data_fill_factor_scaling(pp_data.port.data, modelling_inputs.port_fill_factor);
        %separating time domain, frequency domain and material losses.
        
        fprintf('Analysed ... Saving...')
        save(fullfile(current_folder, 'data_postprocessed.mat'), 'pp_data','-v7.3')
        fprintf('Saved\n')
        clear 'pp_data' 'run_logs' 'modelling_inputs' 'current_folder'
    else
        [a,b,~] = fileparts(current_folder);
        [~,c,~] = fileparts(a);
        disp(['Analysis for ', c, ' already exists... Skipping'])
    end %if
end %for



