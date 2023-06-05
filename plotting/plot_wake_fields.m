function plot_wake_fields(input_settings, set_id, paths)

try
    analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
    [a_folders] = dir_list_gen(analysis_root, 'dirs',1);
    a_folders = a_folders(~contains(a_folders, ' - Blended'));
    for nrs = 1:length(a_folders)
        field_data_folder = fullfile(a_folders{nrs}, 'fields', 'wake');
        postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'wake');
        field_plotting_folder = fullfile(a_folders{nrs}, 'field_plotting', 'wake');
        [~,name_of_model,~] = fileparts(a_folders{nrs});
        if ~exist(field_plotting_folder, 'dir')
            mkdir(field_plotting_folder)
        end %if
        fprintf(['\nStarting wake field plotting <strong>', name_of_model, '</strong>'])

        [field_data_files,~] = dir_list_gen(field_data_folder, 'mat',1);
        if isempty(field_data_files)
            fprintf('\nNo data field datafiles')
            continue
        end %if
        try
            RL = load(fullfile(postprocess_folder, 'data_from_run_logs.mat'), 'run_logs');
        catch
            fprintf('\nMissing run logs... skipping')
            continue
        end %try

        snapshot_inds = contains(field_data_files, 'snapshot');
        field_snapshots = field_data_files(snapshot_inds);
        if exist(fullfile(field_plotting_folder, 'CSV_files'), 'dir')~=7
            mkdir(field_plotting_folder, 'CSV_files')
        end %if
        fprintf('Processing field snapshots...')
        f1 = figure('Position',[30,30, 600, 600]);
        for nes = 1:length(field_snapshots)
            S = load(fullfile(field_data_folder, field_snapshots{nes}));
            temp = regexp(field_snapshots{nes},'field_data_snapshots_F([xyz])([EH]).*\.mat','tokens');
            field_types{nes} = temp{1}{2};
            field_components{nes} = temp{1}{1};
            field_timestamps(nes) = S.data.timestamp;
            export_snapshots_csvs(S, field_types{nes}, fullfile(field_plotting_folder, 'CSV_files'), [name_of_model, field_types{nes}])
            plot_fexport_snapshots(f1, S, field_types{nes}, field_plotting_folder, [name_of_model, field_types{nes}]);
            snapshot_Frames(nes) = getframe(f1);
            clf(f1)
            t_temp = ['T' regexprep(num2str(field_timestamps(nes)),'\.', 'p')];
            t_temp = regexprep(t_temp, '-', 'm');
            c_temp = ['F', field_components{nes}];
            slice_data.(field_types{nes}).(t_temp).('x').(c_temp) = squeeze(S.(c_temp)(floor(size(S.(c_temp),1)./2), :, :));
            slice_data.(field_types{nes}).(t_temp).('y').(c_temp)  = squeeze(S.(c_temp)(:, floor(size(S.(c_temp),2)./2), :));
            slice_data.(field_types{nes}).(t_temp).('z').(c_temp)  = squeeze(S.(c_temp)(:, :, floor(size(S.(c_temp),3)./2)));
            if nes==1
                slice_metadata.coord_x = S.data.coord_x;
                slice_metadata.coord_y = S.data.coord_y;
                slice_metadata.coord_z = S.data.coord_z;
            end %if
            clear S
        end %for
        close(f1)
        fts = unique(field_types);
        fcs = unique(field_components);
        for kdq = 1:length(fts)
            for ladw = 1:length(fcs)
                % selecting the files for the relevant set.
                ind1 = strcmp(field_types, fts{kdq});
                ind2 = strcmp(field_components, fcs{ladw});
                ind3 = and(ind1, ind2);
                selected_frames = snapshot_Frames(ind3);
                % ordering the frames into increasing times
                selected_timestamps = field_timestamps(ind3);
                [~, ind4] = sort(selected_timestamps);
                selected_frames = selected_frames(ind4);

                field_images{1}.frames = selected_frames;
                field_images{1}.field_component = fcs{ladw};
                field_images{1}.field_type = fts{kdq};
                out_name = strcat(name_of_model, '_', fts{kdq}, '-field_', fcs{ladw}, '-component', '_fieldFrames.mat');
                save(fullfile(field_plotting_folder, out_name), 'field_images' )
            end
        end


        fprintf('\nProcessing field slices...')
        [max_field_components, slice_data_rearranged,slice_data_timestamps] =  rearrange_fexport_data(slice_data);
        plot_fexport_data(slice_data_rearranged, slice_data_timestamps, slice_metadata, max_field_components, field_plotting_folder, name_of_model);
        clear S
        fprintf('\nMaking field videos...')
        if exist(fullfile(field_plotting_folder, 'vids'), 'dir')~=7
            mkdir(field_plotting_folder, 'vids')
        end %if
        make_field_videos(field_plotting_folder, fullfile(field_plotting_folder, 'vids'))
        fprintf('Done\n')
        drawnow; pause(1);  % this innocent line prevents the Matlab hang
    end %for
catch ME6
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting fields</strong>'])
    display_error_message(ME6)
end %try