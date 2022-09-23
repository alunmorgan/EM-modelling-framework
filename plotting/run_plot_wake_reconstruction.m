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
            disp(['Starting wake reconstruction plotting <strong>', name_of_model, '</strong>'])
            run_inputs_loc = fullfile(postprocess_folder, 'run_inputs.mat');
            run_logs_loc = fullfile(postprocess_folder, 'data_from_run_logs.mat');
            analysis_loc = fullfile(analysis_folder, 'data_analysed_wake.mat');
            reconstruction_loc = fullfile(reconstruction_folder, 'data_reconstructed_wake.mat');
            GdfidL_plot_wake_reconstruction(run_inputs_loc, run_logs_loc, analysis_loc, reconstruction_loc, ppi, plot_reconstruction_folder)
        else
            disp('No plotting folder... skipping wake reconstruction plotting.')
        end %if
    end %for
catch ME5
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting</strong>'])
    display_error_message(ME5)
end %try
