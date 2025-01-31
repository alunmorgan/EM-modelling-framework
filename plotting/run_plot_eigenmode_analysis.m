function run_plot_eigenmode_analysis(input_settings, set_id)

try
    analysis_root = fullfile(input_settings.paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    for nrs = 1:length(a_folders)
        postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'lossy_eigenmode');
        analysis_folder = fullfile(a_folders{nrs}, 'analysis', 'lossy_eigenmode');
        plot_analysis_folder = fullfile(a_folders{nrs}, 'plot_analysis', 'lossy_eigenmode');
        [~,name_of_model,~] = fileparts(a_folders{nrs});
        mkdirtree(plot_analysis_folder)
        fprintf(['\nStarting lossy eigenmode analysis plotting <strong>', name_of_model, '</strong>'])
        input_file_locations{1} = fullfile(postprocess_folder, 'lossy_eigenmode', 'run_inputs.mat');
        input_file_locations{2} = fullfile(analysis_folder, 'data_from_logs.mat');
        plot_pp_eigenmode(input_file_locations, plot_analysis_folder)
    end %for
    fprintf('\n')
catch ME5
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting</strong>\n'])
    display_error_message(ME5)
end %try