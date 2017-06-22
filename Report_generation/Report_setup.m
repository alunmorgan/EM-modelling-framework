function Report_setup(Author, Report_num, Graphic_path, results_path, start, fin)
% Author is a string which contains the names of the authors listed on the
% report.
% rep_num is the number of the particular report.
% Graphic_path is the path to the logo you want on the report.
%
% Example:
%% Use the post processed data to generate a report.
arc_names = GdfidL_find_selected_models(results_path, {start, fin});
for ks = 1:length(arc_names)
    data_path = [results_path, '/',  arc_names{ks}];
    % Load up the data extracted from the run log.
    load([data_path, '/data_from_run_logs.mat'])
    % Load up post processing inputs
    load([data_path, '/pp_inputs.mat'])
    % Load up the post precessed data.
    load([data_path, '/data_postprocessed.mat'])
    report_input.author = Author;
    report_input.doc_num = Report_num;
    report_input.graphic = Graphic_path;
    report_input.model_name = regexprep(ppi.model_name,'_',' ');
    report_input.doc_root = ppi.output_path;
    
    if isfield(run_logs, 's_parameter')
        % Load up the original model input parameters.
        s_in = load([data_path, '/s_parameter/run_inputs.mat']);
        first_name = fieldnames(run_logs.('s_parameter'));
        report_input.date = run_logs.('s_parameter').(first_name{1}).dte;
        [param_list, param_vals] = extract_parameters(s_in.modelling_inputs, run_logs, 's');
        param_list = regexprep(param_list,'_',' ');
        [s_ltx, s_appnd] = Generate_s_parameter_report(data_path);
    end
    
    if isfield(run_logs, 'wake')
        w_in = load([data_path, '/wake/run_inputs.mat']);
        report_input.date = run_logs.wake.dte;
        [param_list, param_vals] = extract_parameters(w_in.modelling_inputs, run_logs, 'w');
        param_list = regexprep(param_list,'_',' ');
        [w_ltx, w_appnd] = Generate_wake_report(data_path, pp_data, w_in.modelling_inputs, ppi, run_logs.wake);
    end
    
    
    report_input.param_list = param_list;
    report_input.param_vals = param_vals;
    % This makes the preamble for the latex file.
    preamble = latex_add_preamble(report_input, ppi, w_in.modelling_inputs, run_logs.wake);
    
    % Finish the latex document.
    combined = cat(1,preamble, '\clearpage');
    if isfield(run_logs, 'wake')
        combined = cat(1, combined, w_ltx);
    end
    if isfield(run_logs, 's_parameter')
        combined = cat(1, combined, s_ltx);
    end
    combined = cat(1, combined, '\appendix');
    if isfield(run_logs, 'wake')
        combined = cat(1, combined, w_appnd);
    end
    if isfield(run_logs, 's_parameter')
        combined = cat(1, combined, s_appnd);
    end
    combined = cat(1,combined,'\end{document}' );
    
    old_path = pwd;
    cd(data_path)
    latex_write_file('Report',combined);
    process_tex('.', 'Report')
    cd(old_path)
    
    
end
