function generate_wake_field_vids(input_settings, set_id, paths)

try
    analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    a_folders = a_folders(~contains(a_folders, ' - Blended'));

    % Creating videos from Frame data
    for nrs = 1:length(a_folders)
        try
            field_plotting_folder = fullfile(a_folders{nrs}, 'field_plotting', 'wake');
            fprintf('\nMaking field videos...')
            if exist(fullfile(field_plotting_folder, 'vids'), 'dir')~=7
                mkdir(field_plotting_folder, 'vids')
            else
                fprintf('\nField video folder already exists... Skipping field video generation.')
                return
            end %if
            make_field_videos(field_plotting_folder, fullfile(field_plotting_folder, 'vids'))
            fprintf('Done\n')
            drawnow; pause(1);  % this innocent line prevents the Matlab hang
        catch ME5
            warning([input_settings.sets{set_id}, ' <strong>Problem with generating field videos</strong>'])
            display_error_message(ME5)
            continue
        end %try
    end %for
catch ME6
    warning([input_settings.sets{set_id}, ' <strong>Problem with generating field videos</strong>'])
    display_error_message(ME6)
end %try