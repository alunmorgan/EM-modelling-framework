function summary = Blend_summaries(doc_root, names)
% Extacts data from the summary graph fig files.
%
% Example: summary = Blend_summaries(doc_root, names)
for hse = 1:length(names)
    try
        %         load(fullfile(doc_root, names{hse}, 'wake', 'data_postprocessed.mat'), 'pp_data');
        load(fullfile(doc_root, names{hse}, 'wake', 'data_from_run_logs.mat'), 'run_logs');
        load(fullfile(doc_root, names{hse}, 'wake', 'run_inputs.mat'), 'modelling_inputs');
        load(fullfile(doc_root, names{hse}, 'wake', 'data_analysed_wake.mat'), 'wake_sweep_data');
        
        for nw = 1:length(wake_sweep_data.raw)
            wake_sweep_vals(nw) = wake_sweep_data.raw{1, nw}.wake_setup.Wake_length;
        end %for
        chosen_wake_ind = find(wake_sweep_vals == str2double(chosen_wake_length));
        if isempty(chosen_wake_ind)
            chosen_wake_ind = find(wake_sweep_vals == max(wake_sweep_vals));
            disp('Chosen wake length not found. Setting the wakelength to maximum value.')
        end %if
        %         load(fullfile(doc_root, names{hse}, 'wake', 'pp_inputs.mat'), 'ppi');
        summary.wlf{hse} = [num2str(wake_sweep_data.time_domain_data{chosen_wake_ind}.wake_loss_factor * 1e-12), '~V/pC' ];
        summary.date{hse} = [run_logs.dte, '  ', run_logs.tme];
        summary.soft_ver{hse} = num2str(run_logs.ver);
        summary.soft_type{hse} = 'GdfidL';
        [~, tmp] = convert_secs_to_hms(run_logs.CPU_time);
        summary.CPU_time{hse} = tmp;
        summary.num_cores{hse} = num2str(modelling_inputs.n_cores);
        [~, tmp] = convert_secs_to_hms(run_logs.wall_time);
        summary.wall_time{hse} = tmp;
        summary.num_mesh_cells{hse} = num2str(run_logs.Ncells);
        summary.mem_used{hse} = [num2str(run_logs.memory), 'MB'];
        [tmp, t_scale] = rescale_value(run_logs.Timestep,' ');
        summary.timestep{hse} =[ num2str(round(tmp)), ' ',t_scale, 's'];
        summary.mesh_spacing{hse} = [num2str(run_logs.mesh_step_size * 1E6), '\mu{}m'];
        summary.name{hse} = [];
    catch
        disp(['Summary not available for ', num2str(names{hse})])
        summary.wlf{hse} = '';
        summary.date{hse} = '';
        summary.soft_ver{hse} = '';
        summary.soft_type{hse} = '';
        summary.CPU_time{hse} = '';
        summary.num_cores{hse} = '';
        summary.wall_time{hse} = '';
        summary.num_mesh_cells{hse} = '';
        summary.mem_used{hse} = '';
        summary.timestep{hse} = '';
        summary.mesh_spacing{hse} = '';
        summary.name{hse} = '';
        continue
    end %try
    clear run_log modelling_inputs wake_data
end %for