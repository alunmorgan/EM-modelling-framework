function analyse_pp_data(postprocess_folder, output_folder)


if ~isfile(fullfile(postprocess_folder, 'data_analysed_wake.mat'))

    run_logs = load(fullfile(postprocess_folder, 'data_from_run_logs.mat'), 'run_logs');
    run_logs = run_logs.run_logs;
    
    modelling_inputs = load(fullfile(postprocess_folder, 'run_inputs.mat'), 'modelling_inputs');
    modelling_inputs = modelling_inputs.modelling_inputs;
    
    output_file_locations = GdfidL_find_ouput(postprocess_folder);
    pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);
    if ~isnan(pp_data.port.timebase)
        pp_data.port.data = port_data_fill_factor_scaling(pp_data.port.data, modelling_inputs.port_fill_factor);
        %             pp_data.port.data = port_data_remove_non_transmitting(pp_data.port.data, run_logs);
        % If there are no transmitting modes then there is no port data.
        pp_data.port.data.time = port_data_separate_remnant(pp_data.port.data.time, pp_data.port.timebase, modelling_inputs.beam_sigma);
    end %if
    
    fprintf('Analysed ... Saving...')
    save(fullfile(output_folder, 'data_analysed_wake.mat'), 'pp_data','-v7.3')
    fprintf('Saved\n')
else
    disp(['Analysis already exists... Skipping'])
end %if



