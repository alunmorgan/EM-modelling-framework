function Generate_eigenmode_report( data_path,  arc_name )
% Take the output from the eigenmode postprocessing and collates it into a
% report.
%
% data_path is a string containing the full path to the selected model.
% arc_name is the name of the particular simulation run of that model.
% 
% Example: Generate_eigenmode_report( data_path,  arc_name )

old_path = pwd;
% Load up the original model input parameters.
% FIXME need to deal better with different solvers
% this may dissapear with the refactoring of the graphs.
load([data_path, '/', arc_name, '/s_parameter/run_inputs.mat'])
% Load up the data extracted from the run log.
load([data_path, '/', arc_name,'/data_from_run_logs.mat'])
% Load up post processing inputs
load([data_path, '/', arc_name,'/pp_inputs.mat'])
% Load up the post precessed data.
load([data_path, '/', arc_name,'/data_postprocessed.mat'])

% Setting up the latex headers etc.
[param_list, param_vals] = extract_parameters(mi, run_logs);
param_list = regexprep(param_list,'_',' ');
report_input.author = Author;
report_input.doc_num = ppi.rep_num;
report_input.param_list = param_list;
report_input.param_vals = param_vals;
report_input.model_name = regexprep(ppi.model_name,'_',' ');
report_input.doc_root = ppi.output_path;
report_input.date = run_logs.eigenmode.dte;

% This makes the preamble for the latex file.
preamble = latex_add_preamble(report_input);

if isstruct(pp_data.eigenmode_data)
    eigen_lossy_ltx = generate_latex_for_eigenmode_analysis(pp_data.eigenmode_data);
    combined = cat(1,preamble, '\clearpage', eigen_lossy_ltx);
else
    combined = cat(1,preamble, '\clearpage');
end
% This adds the input file to the document as an appendix.
gdf_name = regexprep(ppi.model_name, 'GdfidL_','');
if exist(['pp_link/eigenmode/', gdf_name, '.gdf'],'file')
    gdf_data = add_gdf_file_to_report(['pp_link/eigenmode/', gdf_name, '.gdf']);
    combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
end
% Finish the latex document.
combined = cat(1,combined,'\end{document}' );
cd([data_path, '/', arc_name,'/eigenmode'])
latex_write_file('Eigenmode_report',combined);
process_tex('.', 'Eigenmode_report')
cd(old_path)
