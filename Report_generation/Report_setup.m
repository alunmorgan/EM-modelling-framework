function Report_setup(results_path, ppi, port_overrides, chosen_wake_length)
% Generates a single report. Data is loaded in from files found in the
% results path.
%
% Example: Report_setup(results_path, chosen_wake_length)

%% Construct the preamble.
try
    load(fullfile(results_path, 'wake', 'data_from_run_logs.mat'), 'run_logs')
    load(fullfile(results_path, 'wake', 'run_inputs.mat'), 'modelling_inputs');
    
catch
    load(fullfile(results_path, 's-parameter', 'data_from_run_logs.mat'), 'run_logs')
    load(fullfile(results_path, 's-parameter', 'run_inputs.mat'), 'modelling_inputs');
    
end %try
[mb_param_list, mb_param_vals, ...
    geom_param_list, geom_param_vals ] = extract_parameters(run_logs, modelling_inputs);
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
[~, report_input.model_name] = fileparts(results_path);
report_input.date = run_logs.dte;
report_input.doc_root = results_path;
preamble = latex_add_preamble(report_input);
summary = latex_generate_summary( ppi, modelling_inputs, run_logs);

%% Construct the individual chapters
if contains(modelling_inputs.sim_select, 's')
    [s_ltx, s_appnd] = report_chapter_s_parameter(fullfile(results_path, 's_parameter'));
end %if

if contains(modelling_inputs.sim_select, 'w')
    [w_ltx, w_appnd] = report_chapter_wake(fullfile(results_path, 'wake'), ppi, port_overrides, chosen_wake_length);
end %if

%% Finish the latex document.
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

