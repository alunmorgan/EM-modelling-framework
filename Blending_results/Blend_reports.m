function Blend_reports(sets, chosen_wake_lengths, frequency_display_limit)
%Blends some of the output from the individual thermal analysis reports to
%generate a summary comparison report.
%
% Example: Blend_reports(results_loc, chosen_wake_length, frequency_display_limit)
[report_root, names, analysis_library] = analysis_model_settings_library;

for jse = 1:length(sets)
    results_loc = fullfile(report_root, sets{jse});
    [names,~] = dir_list_gen(results_loc, 'dirs', 1);
    %select only those folders whos names start with the base name.
    [~,name_common,~] = fileparts(results_loc);
    names = names(strncmp(names, name_common, length(name_common)));
    % select only the non blended folders.
    names = names(~contains(names, ' - Blended'));
    
    sweeps = unique(regexprep(names, '_sweep_value_.*', '_sweep'));
    sweeps = sweeps(~contains(sweeps, '_Base'));
    
    for ewh = 1:length(sweeps)
        report_input.rep_title = [sweeps{ewh}, ' - Blended'];
        report_input.output_loc = fullfile(results_loc, report_input.rep_title);
        
        names_in_sweep = names(contains(names, '_Base') | contains(names, sweeps{ewh}));
        for psw = length(names_in_sweep):-1:1
            [param_names_temp, param_vals_temp, good_data(psw), modelling_inputs{psw}] = ...
                params_in_simulation(fullfile(results_loc, names_in_sweep{psw}));
            if good_data(psw) == 0
                for shf = 1:size(param_names,2)
                    param_names{psw,shf} = NaN;
                end %for
            else
                param_names(psw,:) = param_names_temp;
            end %if
            if good_data(psw) == 0
                for shf = 1:size(param_vals,2)
                    param_vals{psw,shf} = NaN;
                end %for
            else
                param_vals(psw,:) = param_vals_temp;
            end %if
            clear param_names_temp param_vals_temp,
            % add some values from the input file which do not show in the
            % postprocessing log.
            if isfield(modelling_inputs{psw}, 'port_multiple')
                report_input.port_multiple{psw} = modelling_inputs{psw}.port_multiple;
                report_input.port_fill_factor{psw} = modelling_inputs{psw}.port_fill_factor;
                report_input.volume_fill_factor{psw} = modelling_inputs{psw}.volume_fill_factor;
            end %if
        end %for
        if sum(good_data) ==0
            warning('No valid data. Skipping report generation')
            return
        end %if
        % Remove bad data
        param_names = param_names(good_data == 1,:);
        param_vals = param_vals(good_data == 1,:);
        names_in_sweep = names_in_sweep(good_data == 1,:);
        report_input.port_multiple = report_input.port_multiple(good_data == 1);
        report_input.port_fill_factor = report_input.port_fill_factor(good_data == 1);
        report_input.volume_fill_factor = report_input.volume_fill_factor(good_data == 1);
        
        % Identify which parameters vary.
        for sha = size(param_vals,2):-1:1
            stable(sha) = all(strcmp(param_vals{1,sha},param_vals(:,sha)));
        end %for
        varying_pars_ind = find(stable ==0);
        if length(varying_pars_ind) >1
            warning('More than one variable changing during the sweep. Only using the first one.')
        end %if
        if isempty(varying_pars_ind)
            warning('No varying parameters found. Skipping this one.')
            continue
        end %if
        
        report_input.sources = names_in_sweep;
        report_input.author = modelling_inputs{1}.author;
        report_input.date = datestr(now,'dd/mm/yyyy');
        report_input.source_path = results_loc;
        report_input.param_names_common = param_names(1, stable);
        report_input.param_vals_common = param_vals(1, stable);
        report_input.swept_name = param_names(1, varying_pars_ind);
        report_input.swept_vals = param_vals(:,varying_pars_ind);
        
        if ~exist(report_input.output_loc, 'dir')
            mkdir(report_input.output_loc)
        end %if
        s_parameter_extract_single_frequency_data(report_input);
        Blend_figs(report_input, 'wake', chosen_wake_lengths{jse}, frequency_display_limit);
        Blend_single_report(report_input, chosen_wake_lengths{jse})
        clear param_names param_vals good_data names_in_sweep report_input
    end %for
end %for
