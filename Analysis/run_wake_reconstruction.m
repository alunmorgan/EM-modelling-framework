function run_wake_reconstruction(input_settings, set_id, paths)

reconstruct_root = fullfile(paths.results_loc, input_settings.sets{set_id});
        [r_folders] = dir_list_gen(reconstruct_root, 'dirs',1);
        if any(contains(input_settings.sim_types, 'wake'))
            try
                for nrs = 1:length(r_folders)
                    postprocess_folder = fullfile(r_folders{nrs}, 'postprocessing', 'wake');
                    reconstruction_folder = fullfile(r_folders{nrs}, 'reconstruction', 'wake');
                    [~,name_of_model,~] = fileparts(r_folders{nrs});
                    if exist(postprocess_folder, 'dir')
                        if ~exist(reconstruction_folder, 'dir')
                            mkdir(reconstruction_folder)
                        end
                        disp(['Starting wake reconstruction <strong>', name_of_model, '</strong>'])
                        reconstruct_pp_data(postprocess_folder, reconstruction_folder, ...
                            ppi, number_of_wake_lengths_to_analyse);
                    else
                        disp('No postprocessing folder... skipping wake reconstruction.')
                    end %if
                end %for
            catch ME
                warning([input_settings.sets{set_id}, ' <strong>Problem with wake reconstruction</strong>'])
                display_error_message(ME)
            end %try
        end %if