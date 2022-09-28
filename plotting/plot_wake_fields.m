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
        disp(['Starting wake field plotting <strong>', name_of_model, '</strong>'])
        
        if isempty(dir_list_gen(field_plotting_folder, 'avi',1))
            if exist(fullfile(field_data_folder, 'field_data.mat'), 'file') == 2
                T = load(fullfile(field_data_folder, 'field_data.mat'), 'field_data', 'pointing_data');
                RL = load(fullfile(postprocess_folder, 'data_from_run_logs.mat'), 'run_logs');
                [temp, ~, ~] = fileparts(field_data_folder);
                [temp, ~, ~] = fileparts(temp);
                [~, prefix, ~] = fileparts(temp);
                fprintf('Plotting field snapshots...')
                graph_limits{1} = [-20,20; -14, 14];
                graph_limits{2} = [-6,6; -6, 6];
                plot_fexport_snapshots(T.field_data.e.snapshots, RL.run_logs.mesh_step_size, graph_limits, field_plotting_folder, [prefix, 'e']);
                plot_fexport_snapshots(T.field_data.h.snapshots, RL.run_logs.mesh_step_size, graph_limits, field_plotting_folder, [prefix, 'h']);
%                 plot_poynting_snapshots(T.pointing_data.snapshots.pointing_real_1, RL.run_logs.mesh_step_size, graph_limits, field_plotting_folder, [prefix, 'p'])
                
                fprintf('Plotting field slices...')
                fprintf('Plotting peak fields...')
                plot_fexport_data_peak_field(T.field_data.e.slices, field_plotting_folder, [prefix, 'e']);
                plot_fexport_data_peak_field(T.field_data.h.slices, field_plotting_folder, [prefix, 'h']);
                fprintf('Done\n')
                fprintf('Plotting selected fields...')
                selected_time = 2; %ns
                plot_fexport_data_selected_timeslice(T.field_data.e.slices, field_plotting_folder, [prefix, 'e'], selected_time)
                plot_fexport_data_selected_timeslice(T.field_data.h.slices, field_plotting_folder, [prefix, 'h'], selected_time)
                plot_field_views_selected_timeslice(T.field_data.e.slices, field_plotting_folder, [prefix, 'e'], selected_time)
                plot_field_views_selected_timeslice(T.field_data.h.slices, field_plotting_folder, [prefix, 'h'], selected_time)
                fprintf('Done\n')
                fprintf('Plotting slices...')
                plot_fexport_data(T.field_data.e.slices, field_plotting_folder, [prefix, 'e'])
                plot_fexport_data(T.field_data.h.slices, field_plotting_folder, [prefix, 'h'])
                fprintf('Done\n')
                fprintf('Making field images...')
                make_field_images(T.field_data, field_plotting_folder);
                fprintf('Done\n')
                fprintf('Making field videos...')
                make_field_videos(field_plotting_folder, prefix)
                fprintf('Done\n')
            end %if
        end %if
    end %for
catch ME6
    warning([input_settings.sets{set_id}, ' <strong>Problem with plotting fields</strong>'])
    display_error_message(ME6)
end %try