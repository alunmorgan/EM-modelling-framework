function [s_ltx, s_appnd] = report_chapter_s_parameter(results_path)
try
%     load(fullfile(results_path, 'run_inputs.mat'), 'modelling_inputs');
    
    % Load up the data extracted from the run log.
%     load(fullfile(results_path, 'data_from_run_logs.mat'), 'run_logs')
    % Load up post processing inputs
    %load(fullfile(results_path, 'pp_inputs.mat'))
%     report_input.model_name = regexprep(modelling_inputs.model_name,'_',' ');
    
    %     % Load up the post precessed data.
    %     load(fullfile(results_path, 'data_postprocessed.mat'), 'pp_data')
    
%     first_name = fieldnames(run_logs);
%     [mb_param_list, mb_param_vals, ...
%         geom_param_list, geom_param_vals ] = extract_parameters(run_logs, modelling_inputs);
%     report_input.date = run_logs.(first_name{1}).dte;
    [s_ltx, s_appnd] = Generate_s_parameter_report(results_path{ks});
catch
    s_ltx = cell(1,1);
    s_ltx = cat(1,s_ltx,'\chapter{S-Parameter analysis}');
    s_ltx = cat(1, s_ltx, 'There is no valid S-Parameter data. But a simulation was requested.');
    s_ltx = cat(1,s_ltx,'\clearpage');
    s_appnd = cell(1,1);
end %try
    