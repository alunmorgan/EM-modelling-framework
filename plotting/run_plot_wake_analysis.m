function run_plot_wake_analysis(input_settings, set_id, paths, ppi)

try
    analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    for nrs = 1:length(a_folders)
        postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'wake');
        plot_analysis_folder = fullfile(a_folders{nrs}, 'plot_analysis', 'wake');
        analysis_folder = fullfile(a_folders{nrs}, 'analysis', 'wake');
        [~,name_of_model,~] = fileparts(a_folders{nrs});
        if exist(analysis_folder, 'dir')
            if ~exist(plot_analysis_folder, 'dir')
                mkdir(plot_analysis_folder)
            end %if
            fprintf(['\nStarting wake analysis plotting <strong>', name_of_model, '</strong>'])
            
            %             datasets = find_datasets(fullfile(paths.results_loc, p.Results.sets{set_id}));
            run_inputs_loc = fullfile(postprocess_folder, 'run_inputs.mat');
            analysis_loc = fullfile(analysis_folder, 'data_analysed_wake.mat');
            GdfidL_plot_pp_wake(run_inputs_loc, analysis_loc, ppi, plot_analysis_folder)
            %             plot_model(datasets, ppi, p.Results.sim_types);
        else
            fprintf('\nNo plotting folder... skipping wake analysis plotting.')
        end %if
    end %for
catch ME5
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting</strong>'])
    display_error_message(ME5)
end %try
