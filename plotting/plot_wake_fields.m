function plot_wake_fields(input_settings, set_id, paths)

% selected_time = 2; %ns
ROI = 8E-3;
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
        disp(['Starting wake field plotting <strong>', name_of_model, '</strong>'])
        
        if isempty(dir_list_gen(field_plotting_folder, 'avi',1))
            [field_data_files,~] = dir_list_gen(field_data_folder, 'mat',1);
            RL = load(fullfile(postprocess_folder, 'data_from_run_logs.mat'), 'run_logs');
            fprintf('Plotting field snapshots...')
            graph_limits{1} = [-20,20; -14, 14];
            graph_limits{2} = [-6,6; -6, 6];
            snapshot_inds = contains(field_data_files, 'snapshot');
            field_snapshots = field_data_files(snapshot_inds);
            for nes = 1:length(field_snapshots)
                S = load(fullfile(field_data_folder, field_snapshots{nes}));
                 temp = regexp(slices{nes},'field_data_snapshot_([eh])fields\.mat','tokens');
                field_type = temp{1};
                plot_fexport_snapshots(S, field_type, RL.run_logs.mesh_step_size, graph_limits, field_plotting_folder, [name_of_model, field_type]);
                clear S
            end %for
           
            fprintf('Plotting field slices...')
            slice_inds = contains(field_data_files, 'slice');
            slices = field_data_files(slice_inds);
            for nes = 1:length(slices)
                S = load(fullfile(field_data_folder, slices{nes}));
                temp = regexp(slices{nes},'field_data_slices_([eh])fields([xyz])\.mat','tokens');
                field_type = temp{1}{1};
                slice_dir = temp{1}{2};
                
                disp(strcat('plot_wake_fields: ',field_type,'-field slice', num2str(nes)))
                disp('plot_wake_fields: plot peak field')
                plot_fexport_data_peak_field(S.data, field_type, slice_dir, field_plotting_folder, name_of_model);
%                 disp('plot_wake_fields: plot slice')
%                 plot_fexport_data_selected_timeslice(S.data, field_type, slice_dir, field_plotting_folder, name_of_model, selected_time)
%                 plot_field_views_selected_timeslice(S.data, field_type, slice_dir, field_plotting_folder, name_of_model, selected_time, ROI)
                disp('plot_wake_fields: plot fexport data')
                plot_fexport_data(S.data, field_type, slice_dir, field_plotting_folder, name_of_model)
                disp('plot_wake_fields: generate CSVs')
                mkdir(field_plotting_folder, 'CSV_files')
                generate_field_csvs(S.data, field_type, slice_dir, fullfile(field_plotting_folder, 'CSV_files'), name_of_model)
                disp('plot_wake_fields: make field images')
                make_field_images(S.data, field_type, slice_dir, field_plotting_folder, name_of_model, NaN);
                make_field_images(S.data, field_type, slice_dir, field_plotting_folder, name_of_model, ROI);
                clear S
            end %for
            fprintf('Making field videos...')
            make_field_videos(field_plotting_folder)
            fprintf('Done\n')
            drawnow; pause(1);  % this innocent line prevents the Matlab hang
        end %if
    end %for
catch ME6
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting fields</strong>'])
    display_error_message(ME6)
end %try