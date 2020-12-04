function get_wlf(model_sets)

load_local_paths
[extracted_data] = extract_all_wlf(results_loc, model_sets);
for kfn = 1:length(extracted_data)
    names = regexprep(extracted_data{kfn}.model_names, [extracted_data{kfn}.basename '_'], '');
    sweeps = unique(regexprep(names, '_sweep_value_.*', ''));
    sweeps(strcmp(sweeps, 'Base')) = [];
    sweeps(strncmp(sweeps, 'old_data', 8)) = [];
    sweep_values = regexprep(names, '.*_sweep_value_', '');
    base_ind = contains(names, 'Base');
         makeBaseSummaryTable(extracted_data{kfn}, model_sets{kfn}, results_loc, base_ind)
    for hen = 1:length(sweeps)
        sweep_inds = contains(names, sweeps{hen});
        vals = sweep_values(sweep_inds);
        if strcmp(sweeps{hen}, 'wake_length')
            temp_base_val = extracted_data{kfn}.wake_length(hen);
        elseif strcmp(sweeps{hen}, 'mesh_density')
            temp_base_val = extracted_data{kfn}.mesh_density(hen);
        elseif strcmp(sweeps{hen}, 'mesh_scaling')
            temp_base_val = extracted_data{kfn}.mesh_scaling(hen);
        elseif strcmp(sweeps{hen}, 'version')
            temp_base_val = extracted_data{kfn}.version{hen};
        elseif strcmp(sweeps{hen}, 'Geometry_fraction')
            temp_base_val = extracted_data{kfn}.Geometry_fraction(hen);
        else
            temp_base_val = extracted_data{kfn}.geometry_values.(sweeps{hen});
        end %if
        [vals_t, base_val, xunit] = recover_numeric_values(vals, temp_base_val);
        [valsX, Isort] = sort(cat(2, vals_t, base_val));
        temp_inds = cat(2, find(sweep_inds), find(base_ind));
        dataInds = temp_inds(Isort);
        makeSweepSummaryTables(valsX, dataInds, extracted_data{kfn}, model_sets{kfn}, xunit, sweeps{hen}, results_loc)
        makeSweepSummaryGraphs(valsX, dataInds, base_val, base_ind, extracted_data{kfn}, model_sets{kfn}, xunit, sweeps{hen}, results_loc)
        clear vals temp_base_val temp_inds dataInds xunit vals_t base_val valsX Isort
    end %for
    clear names sweeps sweep_values base_ind
end %for
