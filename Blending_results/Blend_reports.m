function Blend_reports(sets, chosen_wake_length, upper_frequency, use_names)
%Blends some of the output from the individual thermal analysis reports to
%generate a summary comparison report.
%
%   Args:
%       sets (cell array of strings): If there is a single entry then generate blended results for all parameter sweeps in the set.
%                                     If there are more than one entries then blend the base models
% Example: Blend_reports(results_loc, chosen_wake_length, frequency_display_limit)
paths = load_local_paths;
if length(sets) == 1
    single_set = sets{1};
    set_results_loc = fullfile(paths.results_loc, single_set);
    [names,~] = dir_list_gen(set_results_loc, 'dirs', 1);
    if isempty(names)
        disp(['No data available for ', single_set])
        return
    end %if
    %select only those folders whos names start with the base name.
    [~,name_common,~] = fileparts(set_results_loc);
    names = names(strncmp(names, name_common, length(name_common)));
    % select only the non blended folders.
    names = names(~contains(names, ' - Blended'));
    
    sweeps = unique(regexprep(names, '_sweep_value_.*', '_sweep'));
    sweeps = sweeps(~contains(sweeps, '_Base'));
    
    for ewh = 1:length(sweeps)
        report_input.rep_title = [sweeps{ewh}, ' - Blended'];
        report_input.output_loc = fullfile(set_results_loc, report_input.rep_title);
        
        names_in_sweep = names(contains(names, '_Base') | contains(names, sweeps{ewh}));
        for psw = length(names_in_sweep):-1:1
            [param_names_temp, param_vals_temp, good_data(psw), modelling_inputs{psw}] = ...
                params_in_simulation(fullfile(set_results_loc, names_in_sweep{psw}));
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
            end %if
        end %for
        if sum(good_data) ==0
            disp('No valid data. Skipping report generation')
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
            disp('More than one variable changing during the sweep. Only using the first one.')
        end %if
        if isempty(varying_pars_ind)
            disp('No varying parameters found. Skipping this one.')
            continue
        end %if
        
        report_input.sources = names_in_sweep;
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
        s_parameter_extract_single_frequency_data(report_input);
        Blend_figs(report_input);
        Blend_single_report(report_input, chosen_wake_length)
        clear varying_pars_ind param_names param_vals good_data names_in_sweep report_input
    end %for
else
    ck = 1;
    for jse = 1:length(sets)
        set_results_loc = fullfile(paths.results_loc, sets{jse});
        names_temp = dir_list_gen(set_results_loc, 'dirs', 1);
        if isempty(names_temp)
            disp(['No data available for ', sets{jse}])
            continue
        end %if
        % select only the non blended folders.
        names_temp = names_temp(~contains(names_temp, ' - Blended'));
        names(ck) = names_temp(contains(names_temp, '_Base'));
        ck = ck+1;
    end %for
    for ks = 1:length(names)
        [~,test{ks},~]=fileparts(names{ks});
        test{ks} = regexprep(test{ks}, '_Base', '');
        sections{ks,:} = regexp(test{ks},'_','split');
    end %for
    sections = flatten_nest(sections);
    for nes = 1:size(sections, 2)
        word = sections{1,nes};
        if ~isempty(word)
            locations_of_word = strcmpi(word,sections);
            if all(sum(locations_of_word,2))
                if nes == 1
                    words_to_remove = locations_of_word;
                else
                    words_to_remove = words_to_remove | locations_of_word;
                end %if
                
            end %if
        end %if
    end %for
    words_to_remove(1,:) = 0;
    words_to_remove(:,end+1) = 0;
    sections(:,end+1) = {'vs'};
    sections = sections';
    words_to_remove = words_to_remove';
    sections(words_to_remove == 1) = '';
    rep_title = ['Comparison - ', sections{1}];
    for ks = 2:length(sections) -1
        if ~isempty(sections{ks})
            rep_title = strcat(rep_title , '_', sections{ks});
        end %if
    end %for
%     Schar = char(test(:));
%     end_of_common = find(sum(diff(Schar)) ~= 0, 1, 'first') -1;
%     underscores = strfind(test{1}(1:end_of_common), '_');
%     if isempty(underscores)
%         rep_title = ['Comparison - ',Schar(1, 1:end)];
%         for jd = 2:length(test)
%             rep_title = strcat(rep_title , '_vs_', Schar(jd, 1:end));
%         end %for
%     else
%         rep_title = [Schar(1, 1:underscores(end) - 1), ' - ',Schar(1, underscores(end)+1:end)];
%         for jd = 2:length(test)
%             rep_title = strcat(rep_title , '_vs_', Schar(jd, underscores(end)+1:end));
%         end %for
%     end %if
    [report_loc,~,~] = fileparts(set_results_loc);
    report_input.rep_title = rep_title;
    report_input.output_loc = fullfile(report_loc, report_input.rep_title);
    for psw = length(names):-1:1
        [param_names_temp, param_vals_temp, good_data(psw), modelling_inputs{psw}] = ...
            params_in_simulation(names{psw});
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
        end %if
    end %for
    if sum(good_data) ==0
        disp('No valid data. Skipping report generation')
        return
    end %if
    % Remove bad data
    param_names = param_names(good_data == 1,:);
    param_vals = param_vals(good_data == 1,:);
    names = names(good_data == 1);
    report_input.port_multiple = report_input.port_multiple(good_data == 1);
    report_input.port_fill_factor = report_input.port_fill_factor(good_data == 1);
    report_input.volume_fill_factor = report_input.volume_fill_factor(good_data == 1);
    
    % Identify which parameters vary.
    for sha = size(param_vals,2):-1:1
        stable(sha) = all(strcmp(param_vals{1,sha},param_vals(:,sha)));
    end %for
    varying_pars_ind = find(stable ==0);
    
    report_input.sources = names;
    report_input.author = modelling_inputs{1}.author;
    report_input.date = datestr(now,'dd/mm/yyyy');
    report_input.source_path = '';
    report_input.param_names_common = param_names(1, stable);
    report_input.param_vals_common = param_vals(1, stable);
    if use_names == 1
        report_input.swept_name = {'Model names'};
        report_input.swept_vals = test;
    else
        if length(varying_pars_ind) >1
            report_input.swept_name = {'Group of variables'};
            report_input.swept_vals = param_vals(:,varying_pars_ind(1));
        else
            report_input.swept_name = param_names(1, varying_pars_ind);
            report_input.swept_vals = param_vals(:,varying_pars_ind);
        end %if
    end %if
    
    if ~exist(report_input.output_loc, 'dir')
        mkdir(report_input.output_loc)
    end %if
    Blend_figs(report_input, chosen_wake_length, upper_frequency);
    Blend_single_report(report_input, chosen_wake_length)
    clear varying_pars_ind param_names param_vals good_data names_in_sweep report_input
end %if