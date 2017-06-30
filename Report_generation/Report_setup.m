function Report_setup(Author, Report_num, Graphic_path, results_path)
% Generates a single report.
% Author is a string which contains the names of the authors listed on the
% report.
% rep_num is the number of the particular report.
% Graphic_path is the path to the logo you want on the report.
%
% Example: Report_setup(Author, Report_num, Graphic_path, results_path, input_folder)
%% Use the post processed data to generate a report.
report_input.author = Author;
report_input.doc_num = Report_num;
report_input.graphic = Graphic_path;
data_path = dir_list_gen(fullfile(results_path),'dirs',1);

for ks = 1:length(data_path)
    [~,folder_name,~] = fileparts(data_path{ks});
    
    if strcmp(folder_name, 's_parameter')
        clear ppi pp_data run_logs modelling_inputs
        % Load up the data extracted from the run log.
        load(fullfile(data_path{ks}, 'data_from_run_logs.mat'))
        % Load up post processing inputs
        load(fullfile(data_path{ks}, 'pp_inputs.mat'))
        report_input.model_name = regexprep(ppi.model_name,'_',' ');
        report_input.doc_root = ppi.output_path;
        % Load up the post precessed data.
        load(fullfile(data_path{ks}, 'data_postprocessed.mat'))
        % Load up the original model input parameters.
        load(fullfile(data_path{ks}, 's_parameter', 'run_inputs.mat'));
        first_name = fieldnames(run_logs);
        report_input.date = run_logs.(first_name{1}).dte;
        [mb_param_list, mb_param_vals, ...
            geom_param_list, geom_param_vals ] = extract_parameters(run_logs);
        [s_ltx, s_appnd] = Generate_s_parameter_report(data_path);
    end %if
    
    if strcmp(folder_name, 'wake')
        clear ppi pp_data run_logs modelling_inputs
        % Load up the data extracted from the run log.
        load(fullfile(data_path{ks}, 'data_from_run_logs.mat'))
        % Load up post processing inputs
        load(fullfile(data_path{ks}, 'pp_inputs.mat'))
        report_input.model_name = regexprep(ppi.model_name,'_',' ');
        report_input.doc_root = ppi.output_path;
        % Load up the post precessed data.
        load(fullfile(data_path{ks}, 'data_postprocessed.mat'))
        load(fullfile(data_path{ks}, 'run_inputs.mat'));
        report_input.date = run_logs.dte;
        [mb_param_list, mb_param_vals, ...
            geom_param_list, geom_param_vals ] = extract_parameters(run_logs);
        [w_ltx, w_appnd] = Generate_wake_report(data_path{ks}, pp_data, modelling_inputs, ppi, run_logs);
    end %if
end %for
mb_param_list = regexprep(mb_param_list,'_',' ');
if iscell(geom_param_list)
    geom_param_list = regexprep(geom_param_list,'_',' ');
end
report_input.geometry_param_list = geom_param_list;
report_input.geometry_param_vals = geom_param_vals;
report_input.mb_param_list = mb_param_list;
report_input.mb_param_vals = mb_param_vals;
% This makes the preamble for the latex file.
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

