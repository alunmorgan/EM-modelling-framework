function analyse_pp_data(postprocess_folder, output_folder)


if ~isfile(fullfile(output_folder, 'data_analysed_wake.mat'))
    if exist(fullfile(postprocess_folder, 'model_log'),"file")
        run_logs = GdfidL_read_wake_log(fullfile(postprocess_folder, 'model_log'));
        modelling_inputs = load(fullfile(postprocess_folder, 'run_inputs.mat'), 'modelling_inputs');
        modelling_inputs = modelling_inputs.modelling_inputs;
        output_file_locations = GdfidL_find_ouput(postprocess_folder);
        analysed_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);
        if ~isnan(analysed_data.port.timebase)
            analysed_data.port.data = port_data_fill_factor_scaling(analysed_data.port.data, modelling_inputs.port_fill_factor);
            analysed_data.port.data.time = port_data_separate_remnant(analysed_data.port.data.time, analysed_data.port.timebase, modelling_inputs.beam_shape);
            analysed_data.port.data = port_data_sum_modes(analysed_data.port.data);
        end %if
        fprintf('Analysed ... Saving...')
        save(fullfile(output_folder, 'data_analysed_wake.mat'), 'analysed_data','-v7.3')
        fprintf('Saved\n')
    else
        fprintf('Analyse_pp_data: missing model_log file... Skipping\n ')
    end %if
else
    fprintf('Analysis already exists... Skipping\n')
end %if



