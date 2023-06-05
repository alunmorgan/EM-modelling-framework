function run_plot_wake_reconstruction(input_settings, set_id, paths, ppi)

try
    analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    for nrs = 1:length(a_folders)
        postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'wake');
        plot_reconstruction_folder = fullfile(a_folders{nrs}, 'plot_reconstruction', 'wake');
        analysis_folder = fullfile(a_folders{nrs}, 'analysis', 'wake');
        reconstruction_folder = fullfile(a_folders{nrs}, 'reconstruction', 'wake');
        [~,name_of_model,~] = fileparts(a_folders{nrs});
        if exist(analysis_folder, 'dir')
            if ~exist(plot_reconstruction_folder, 'dir')
                mkdir(plot_reconstruction_folder)
            end %if
            fprintf(['\nStarting wake reconstruction plotting <strong>', name_of_model, '</strong>'])
            run_inputs_loc = fullfile(postprocess_folder, 'run_inputs.mat');
            run_logs_loc = fullfile(postprocess_folder, 'data_from_run_logs.mat');
            analysis_loc = fullfile(analysis_folder, 'data_analysed_wake.mat');
            reconstruction_loc1 = fullfile(reconstruction_folder, 'data_reconstructed_single_bunch_wake.mat');
            reconstruction_loc2 = fullfile(reconstruction_folder, 'data_reconstructed_wake_sweep.mat');
            reconstruction_loc3 = fullfile(reconstruction_folder, 'data_reconstructed_bunch_length_sweep_wake.mat');
            reconstruction_loc4 = fullfile(reconstruction_folder, 'data_reconstructed_varying_machine_conditions_wake.mat');
            
            files_to_load = {run_inputs_loc, {'modelling_inputs'};...
                analysis_loc, {'pp_data'};...
                reconstruction_loc1, {'time_slice_data', 't_data', 'f_data'};...
                reconstruction_loc2, {'wake_sweep_data'};...
                reconstruction_loc3, {'bunch_length_sweep_data'};...
                reconstruction_loc4, {'bunch_charge_sweep_data'};...
                run_logs_loc, {'run_logs'}};
            
            [temp, ~, ~] = fileparts(run_inputs_loc);
            [temp, ~, ~] = fileparts(temp);
            [temp, ~, ~] = fileparts(temp);
            [~, prefix, ~] = fileparts(temp);
            GdfidL_plot_pp_wake(run_inputs_loc, reconstruction_loc1, ppi, plot_reconstruction_folder)
            GdfidL_plot_wake_reconstruction(files_to_load, ppi, plot_reconstruction_folder, prefix)
        else
            fprintf('\nNo plotting folder... skipping wake reconstruction plotting.')
        end %if
    end %for
catch ME5
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting</strong>'])
    display_error_message(ME5)
end %try
