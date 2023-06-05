function run_wake_analysis(input_settings, set_id, paths)
%

try
    postprocess_root = fullfile(paths.results_loc, input_settings.sets{set_id});
    [pp_folders] = dir_list_gen(postprocess_root, 'dirs',1);
    for nrs = 1:length(pp_folders)
        postprocess_folder = fullfile(pp_folders{nrs}, 'postprocessing', 'wake');
        analysis_folder = fullfile(pp_folders{nrs}, 'analysis', 'wake');
        [~,name_of_model,~] = fileparts(pp_folders{nrs});
        if exist(postprocess_folder, 'dir')
            if ~exist(analysis_folder, 'dir')
                mkdir(analysis_folder)
            end
            fprintf(['\nStarting wake analysis <strong>', name_of_model, '</strong>'])
            analyse_pp_data(postprocess_folder, analysis_folder);
        else
            fprintf('\nNo postprocessing folder... skipping wake analysis.')
        end %if
    end %for
catch ME
    warning([input_settings.sets{set_id}, ' <strong>Problem with wake analysis</strong>'])
    display_error_message(ME)
end %try