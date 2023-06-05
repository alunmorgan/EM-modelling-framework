function blend_single_base(single_set)

paths = load_local_paths;
set_results_loc = fullfile(paths.results_loc, single_set);
[names,~] = dir_list_gen(set_results_loc, 'dirs', 1);
if isempty(names)
    fprintf(['\nNo data available for ', single_set])
    return
end %if
%select only those folders whos names start with the base name.
[~,name_common,~] = fileparts(set_results_loc);
names = names(strncmp(names, name_common, length(name_common)));
% select only the non blended folders.
names_all.geometry = names(~contains(names, ' - Blended'));
names_all.material = names(contains(names, '_mat_sweep_value_'));
names_all.beam_offset_x = names(contains(names, '_beam_offset_x_sweep_value_'));
names_all.beam_offset_y = names(contains(names, '_beam_offset_y_sweep_value_'));
names_all.port_excitation = names(contains(names, '_port_excitation_'));
names_all.geometry = names_all.geometry(~contains(names_all.geometry, '_beam_offset_'));
names_all.geometry = names_all.geometry(~contains(names_all.geometry, '_port_excitation_'));
names_all.geometry = names_all.geometry(~contains(names_all.geometry, '_mat_sweep_value_'));

ck = 2;
names_in_sweeps{1} = names_all.geometry;
basename = regexprep(names_all.geometry{contains(names_all.geometry, '_Base')}, '_Base', '');
g_sweep = regexprep(names_all.geometry, [basename,'_'] , '');
sweep_names{1} = regexprep(g_sweep, '_sweep_value_.*', '');
sweep_type{1} = 'geometry';
for she = 1:length(names_all.geometry)
    sweep_sub_types = {'beam_offset_x', 'beam_offset_y', 'material', 'port_excitation'};
    for whw = 1:length(sweep_sub_types)
        temp_vals = contains(names_all.(sweep_sub_types{whw}), names_all.geometry{she});
        if sum(temp_vals) > 0
            temp = names_all.(sweep_sub_types{whw})(temp_vals);
            temp = regexprep(temp, names_all.geometry{she}, '');
            temp = regexprep(temp, '_sweep_value_.*', '');
            temp2 = unique(temp);
            for hfd = 1:length(temp2)
                single_sweep_names = names_all.(sweep_sub_types{whw})(temp_vals);
                name_filter = contains(temp, temp2{hfd});
                single_sweep_names = single_sweep_names(name_filter);
                names_in_sweeps{ck} = cat(1,names_all.geometry(she), single_sweep_names);
                sweep_names{ck} = [sweep_sub_types{whw}, ' sweep (',temp2{hfd},') off base model ', names_all.geometry{she}];
                sweep_type{ck} = sweep_sub_types{whw};
                ck = ck +1;
            end %for
        end %if
        clear temp_vals
    end %for
end %for
for gnr = 1:length(sweep_names)
    if length(names_in_sweeps{gnr}) < 2
        valid_sweep(gnr) = 0;
    else
        valid_sweep(gnr) = 1;
    end %if
end %for
names_in_sweeps = names_in_sweeps(logical(valid_sweep));
sweep_names = sweep_names(logical(valid_sweep));
sweep_type = sweep_type(logical(valid_sweep));
for ewh = 1:length(sweep_names)
    report_input.rep_title = [sweep_names{ewh}, ' - Blended'];
    report_input.output_loc = fullfile(set_results_loc, report_input.rep_title);
    report_input.field_snapshot_times = [0.5, 2]; %ns
    for psw = length(names_in_sweeps{ewh}):-1:1
        [param_names_temp, param_vals_temp, good_data(psw), modelling_inputs{psw}] = ...
            params_in_simulation(fullfile(set_results_loc, names_in_sweeps{ewh}{psw}));
        param_names_temp{1, end+1} = 'beam_offset_x';
        param_vals_temp{1, end+1} = modelling_inputs{psw}.beam_offset_x;
        param_names_temp{1, end+1} = 'beam_offset_y';
        param_vals_temp{1, end+1} = modelling_inputs{psw}.beam_offset_y;
        for jdr = 1:length(param_names_temp)
            if isnan(param_names_temp{jdr})
                param_names_temp{jdr}  = 'ERR';
            end %if
        end %for
        for jdf = 1:length(param_vals_temp)
            if isnan(param_vals_temp{jdf})
                param_vals_temp{jdf}  = 'ERR';
            end %if
        end %for
        param_names(psw,1:length(param_names_temp)) = param_names_temp;
        param_vals(psw,1:length(param_names_temp)) = param_vals_temp;
        clear param_names_temp param_vals_temp,
        % add some values from the input file which do not show in the
        % postprocessing log.
        if isfield(modelling_inputs{psw}, 'port_multiple')
            report_input.port_multiple{psw} = modelling_inputs{psw}.port_multiple;
            report_input.port_fill_factor{psw} = modelling_inputs{psw}.port_fill_factor;
            report_input.volume_fill_factor{psw} = modelling_inputs{psw}.volume_fill_factor;
            report_input.mesh_stepsize{psw} = modelling_inputs{psw}.mesh_stepsize;
        end %if
    end %for
        if sum(good_data) ==0
            fprintf('\nNo valid data. Skipping report generation')
            return
        end %if

    % Remove bad data
    param_names = param_names(good_data == 1,:);
    param_vals = param_vals(good_data == 1,:);
    names_in_sweep = names_in_sweeps{ewh}(good_data == 1,:);
    report_input.port_multiple = report_input.port_multiple(good_data == 1);
    report_input.port_fill_factor = report_input.port_fill_factor(good_data == 1);
    report_input.volume_fill_factor = report_input.volume_fill_factor(good_data == 1);
    clear good_data
    
    % Identify which parameters vary.
    for sha = size(param_vals,2):-1:1
        stable(sha) = all(strcmp(param_vals{1,sha},param_vals(:,sha)));
    end %for
    varying_pars_ind = find(stable ==0);
    if length(varying_pars_ind) >1
        fprintf('\nMore than one variable changing during the sweep. Only using the first one.')
    end %if
    if isempty(varying_pars_ind)
        fprintf('\nNo varying parameters found. Skipping this one.')
        continue
    end %if

    report_input.sources = names_in_sweep;
    report_input.sweep_type = sweep_type{ewh};
    report_input.author = modelling_inputs{1}.author;
    report_input.date = datestr(now,'dd/mm/yyyy');
    report_input.source_path = set_results_loc;
    report_input.param_names_common = param_names(1, stable);
    report_input.param_vals_common = param_vals(1, stable);
    if length(varying_pars_ind) >1
        report_input.swept_name = {'Group of variables'};
        report_input.swept_vals = param_vals(:,varying_pars_ind(1));
    else
        report_input.swept_name = param_names(1, varying_pars_ind);
        report_input.swept_vals = param_vals(:,varying_pars_ind);
    end %if

    if ~exist(report_input.output_loc, 'dir')
        mkdir(report_input.output_loc)
    end %if
    %         s_parameter_extract_single_frequency_data(report_input); %FIXME
    Blend_figs(report_input);
    summary = Blend_summaries(report_input.source_path, report_input.sources);
    save(fullfile(report_input.output_loc, [report_input.swept_name{1}, '_summary.mat']), 'summary')
    Blend_single_report(report_input)
    clear varying_pars_ind param_names param_vals names_in_sweep report_input
end %for
