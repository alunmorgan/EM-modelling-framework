function Report_setup(results_path, ppi, port_overrides, chosen_wake_length)
% Generates a single report. Data is loaded in from files found in the
% results path.
% 
% Example: Report_setup(results_path, chosen_wake_length)

%% Use the post processed data to generate a report.
load(fullfile(results_path, 'wake','run_inputs.mat'), 'modelling_inputs');
if contains(modelling_inputs.sim_select, 's')
    % Load up the data extracted from the run log.
    load(fullfile(results_path, 'data_from_run_logs.mat'), 'run_logs')
    % Load up post processing inputs
    %load(fullfile(results_path, 'pp_inputs.mat'))
    report_input.model_name = regexprep(modelling_inputs.model_name,'_',' ');
    report_input.doc_root = results_path;
    % Load up the post precessed data.
    load(fullfile(results_path, 'data_postprocessed.mat'), 'pp_data')
    
    first_name = fieldnames(run_logs);
    [mb_param_list, mb_param_vals, ...
        geom_param_list, geom_param_vals ] = extract_parameters(run_logs, modelling_inputs);
    report_input.date = run_logs.(first_name{1}).dte;
    [s_ltx, s_appnd] = Generate_s_parameter_report(results_path{ks});
end %if

if contains(modelling_inputs.sim_select, 'w')
    % Load up the data extracted from the run log.
    load(fullfile(results_path, 'wake', 'data_from_run_logs.mat'), 'run_logs')
    % Load up post processing inputs
%     load(fullfile(results_path, 'wake', 'pp_inputs.mat'), 'ppi')
    report_input.model_name = regexprep(modelling_inputs.model_name,'_',' ');
    report_input.doc_root = results_path;
    % Load up the post precessed data.
    load(fullfile(results_path, 'wake', 'data_postprocessed.mat'), 'pp_data')
    load(fullfile(results_path, 'wake', 'data_analysed_wake.mat'), 'wake_sweep_data')
    for nw = 1:length(wake_sweep_data.raw)
        wake_sweep_vals(nw) = wake_sweep_data.raw{1, nw}.wake_setup.Wake_length;
    end %for
    chosen_wake_ind = find(wake_sweep_vals == str2double(chosen_wake_length));
    if isempty(chosen_wake_ind)
        [~,chosen_wake_ind] = min(abs((wake_sweep_vals ./ str2double(chosen_wake_length)) - 1));
        warning('Chosen wake length not found. Setting the wakelength to maximum value.')
    end %if
    wake_data.port_time_data = wake_sweep_data.port_time_data{chosen_wake_ind};
    wake_data.time_domain_data = wake_sweep_data.time_domain_data{chosen_wake_ind};
    wake_data.frequency_domain_data = wake_sweep_data.frequency_domain_data{chosen_wake_ind};
    
    first_name = fieldnames(run_logs);
    [mb_param_list, mb_param_vals, ...
        geom_param_list, geom_param_vals ] = extract_parameters(run_logs, modelling_inputs);
    
    report_input.date = run_logs.dte;
    [w_ltx, w_appnd] = Generate_wake_report(results_path, ...
        pp_data, wake_data, modelling_inputs, ppi, port_overrides, run_logs);
end %if

mb_param_list = regexprep(mb_param_list,'_',' ');
if ~isnan(geom_param_list{1})
    geom_param_list = regexprep(geom_param_list,'_',' ');
end
report_input.geometry_param_list = geom_param_list;
report_input.geometry_param_vals = geom_param_vals;
report_input.mb_param_list = mb_param_list;
report_input.mb_param_vals = mb_param_vals;
% This makes the preamble for the latex file.
if isfield(modelling_inputs, 'author')
    report_input.author = modelling_inputs.author;
else
    report_input.author = '';
end %if
preamble = latex_add_preamble(report_input);
summary = latex_generate_summary( ppi, modelling_inputs, run_logs);

% Finish the latex document.
combined = cat(1,preamble, summary, '\clearpage');
if exist('w_ltx', 'var')
    combined = cat(1, combined, w_ltx);
end %if
if exist('s_ltx','var')
    combined = cat(1, combined, s_ltx);
end %if
combined = cat(1, combined, '\appendix');
if exist('w_appnd', 'var')
    combined = cat(1, combined, w_appnd);
end %if
if exist('s_appnd', 'var')
    combined = cat(1, combined, s_appnd);
end %if
combined = cat(1,combined,'\end{document}' );

old_path = pwd;
cd(fullfile(results_path))
latex_write_file('Report',combined);
process_tex('.', 'Report')
cd(old_path)

