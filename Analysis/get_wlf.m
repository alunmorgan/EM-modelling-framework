function get_wlf(model_sets, skip_analysis)

if nargin == 1
    skip_analysis = 'skip';
end %if
if strcmp(skip_analysis, 'skip')
    return
end %if
load_local_paths
[extracted_data] = extract_all_wlf(results_loc, model_sets);
for kfn = 1:length(extracted_data)
    names = regexprep(extracted_data{kfn}.model_names, [extracted_data{kfn}.basename{1} '_'], '');
    sweeps = unique(regexprep(names, '_sweep_value_.*', ''));
    sweeps(strcmp(sweeps, 'Base')) = [];
    sweeps(strncmp(sweeps, 'old_data', 8)) = [];
    sweep_values = regexprep(names, '.*_sweep_value_', '');
    base_ind = contains(names, 'Base');
    makeBaseSummaryTable(extracted_data{kfn}, model_sets{kfn}, results_loc, base_ind)
    for hen = 1:length(sweeps)
        sweep_inds = contains(names, sweeps{hen});
        all_inds = or(base_ind, sweep_inds);
        %         vals = sweep_values(sweep_inds);
        %find the relevant values across the current sweep
        if strcmp(sweeps{hen}, 'wake_length')
            temp_vals = extracted_data{kfn}.wake_length(all_inds);
        elseif strcmp(sweeps{hen}, 'mesh_density')
            temp_vals = extracted_data{kfn}.mesh_density(all_inds);
        elseif strcmp(sweeps{hen}, 'mesh_scaling')
            temp_vals = extracted_data{kfn}.mesh_scaling(all_inds);
        elseif strcmp(sweeps{hen}, 'version')
            temp_vals = extracted_data{kfn}.version{all_inds};
        elseif strcmp(sweeps{hen}, 'Geometry_fraction')
            temp_vals = extracted_data{kfn}.Geometry_fraction(all_inds);
        elseif strcmp(sweeps{hen}, 'beam_offset_x')
            temp_vals = extracted_data{kfn}.beam_offset_x(all_inds);
        elseif strcmp(sweeps{hen}, 'beam_offset_y')
            temp_vals = extracted_data{kfn}.beam_offset_y(all_inds);
        elseif strcmp(sweeps{hen}, 'port_excitation')
            temp_vals = sweep_values(all_inds);
        elseif contains(sweeps{hen}, '_mat')
            loop_inds = find(all_inds == 1);
            for hse = 1:length (loop_inds)
                mat_loc_ind = find(strcmp(extracted_data{kfn}.material_names{loop_inds(hse)}, sweeps{hen}), 1, 'first');
                temp_vals{hse} = extracted_data{kfn}.material_values{loop_inds(hse)}{mat_loc_ind};
            end %for
        else
            geom_loop_inds = find(all_inds == 1);
            for hse = 1:length (geom_loop_inds)
                geom_loc_ind = find(strcmp(extracted_data{kfn}.geometry_names{geom_loop_inds(hse)}, sweeps{hen}), 1, 'first');
                temp_vals = extracted_data{kfn}.geometry_values{geom_loop_inds(hse)}{geom_loc_ind};
            end %for
        end %if
        makeSweepSummaryTables(temp_vals, all_inds, extracted_data{kfn}, model_sets{kfn}, sweeps{hen}, results_loc)
        makeSweepSummaryGraphs(temp_vals, all_inds, base_ind, extracted_data{kfn}, model_sets{kfn}, sweeps{hen}, results_loc)
        clear temp_vals all_inds mat_loc_ind geom_loc_ind
    end %for
    clear names sweeps sweep_values base_ind
end %for
