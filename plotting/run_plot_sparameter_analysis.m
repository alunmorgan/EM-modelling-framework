function run_plot_sparameter_analysis(input_settings, set_id, paths)

try
    analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    for nrs = 1:length(a_folders)
        postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'sparameter');
        plot_analysis_folder = fullfile(a_folders{nrs}, 'plot_analysis', 'sparameter');
        analysis_folder = fullfile(a_folders{nrs}, 'analysis', 'sparameter');
        [~,name_of_model,~] = fileparts(a_folders{nrs});
        if exist(analysis_folder, 'dir')
            if ~exist(plot_analysis_folder, 'dir')
                mkdir(plot_analysis_folder)
            end %if
            fprintf(['\nStarting S-Parameter analysis plotting <strong>', name_of_model, '</strong>'])
            temp  = dir_list_gen(postprocess_folder, 'dirs',1);
            run_inputs_loc = fullfile(temp{1}, 'run_inputs.mat');
            analysis_loc = fullfile(analysis_folder, 'data_analysed_sparameter.mat');
            GdfidL_plot_s_parameters(run_inputs_loc, analysis_loc, plot_analysis_folder)
            %             plot_model(datasets, ppi, p.Results.sim_types);
        else
            fprintf('\nNo plotting folder... skipping wake analysis plotting.')
        end %if
    end %for
catch ME5
    warning([input_settings.sets{set_id}, ' <strong>Problem with S-Parameter plotting</strong>'])
    display_error_message(ME5)
end %try
