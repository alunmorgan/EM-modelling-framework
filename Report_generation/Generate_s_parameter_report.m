function Generate_s_parameter_report( data_path, Author, rep_num, Graphic_path)
% Take the output from the s_parameter postprocessing and collates it into a
% report.
%
% data_path is the path where the images and datafiles are stored.
% Author is a string which contains the names of the authors listed on the
% report.
% rep_num is the number of the particular report.
% Graphic_path is the path to the logo you want on the report.
%
% Example: Generate_s_parameter_report( data_path, Author, rep_num, Graphic_path)

old_path = pwd;
% Load up the original model input parameters.
% this may dissapear with the refactoring of the graphs.
load([data_path, '/s_parameter/run_inputs.mat'])
% Load up the data extracted from the run log.
load([data_path, '/data_from_run_logs.mat'])
% Load up post processing inputs
load([data_path, '/pp_inputs.mat'])
% Load up the post precessed data.
load([data_path, '/data_postprocessed.mat'])

% Setting up the latex headers etc.
[param_list, param_vals] = extract_parameters(mi, run_logs, 's');
param_list = regexprep(param_list,'_',' ');
report_input.author = Author;
report_input.doc_num = rep_num;
report_input.graphic = Graphic_path;
report_input.param_list = param_list;
report_input.param_vals = param_vals;
report_input.model_name = regexprep(ppi.model_name,'_',' ');
report_input.doc_root = ppi.output_path;
first_name = fieldnames(run_logs.('s_parameter'));
report_input.date = run_logs.('s_parameter').(first_name{1}).dte;

% This makes the preamble for the latex file.
preamble = latex_add_preamble(report_input);

s_ltx = generate_latex_for_s_parameter_analysis(data_path);
combined = cat(1,preamble, '\clearpage', s_ltx);
% This adds the input file to the document as an appendix.
if exist([data_path, '/s_parameter/model.gdf'],'file')
    gdf_data = add_gdf_file_to_report([data_path, '/s_parameter/model.gdf']);
    combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
end
% Finish the latex document.
combined = cat(1,combined,'\end{document}' );

cd([data_path, '/s_parameter'])
latex_write_file('S_parameter_report',combined);
process_tex('.', 'S_parameter_report')
cd(old_path)
