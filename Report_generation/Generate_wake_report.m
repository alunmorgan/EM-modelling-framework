function Generate_wake_report( data_path, Author, rep_num, Graphic_path)
% Uses the pregenerated images resulting from the wake analysis 
% and generates the appropriate latex code to turn them
% into a useable report.
%
% data_path is the path where the images and datafiles are stored.
% Author is a string containing the authors name.
%
% Example: Generate_wake_report( data_path, Author)

old_path = pwd;
% Load up the original model input parameters.
% FIXME need to deal better with different solvers
% this may dissapear with the refactoring of the graphs.
load([data_path, '/wake/run_inputs.mat'])
% Load up the data extracted from the run log.
load([data_path,'/data_from_run_logs.mat'])
% Load up post processing inputs
load([data_path, '/pp_inputs.mat'])
% Load up the post precessed data.

load([data_path, '/data_postprocessed.mat'])
if ~isfield(pp_data, 'wake_data')
    %TODO make this more fine grained so that it can use what is there
    %better.
    warning('No wake data present')
    return
end

% Setting up the latex headers etc.
[param_list, param_vals] = extract_parameters(mi, run_logs);
param_list = regexprep(param_list,'_',' ');
report_input.author = Author;
report_input.doc_num = rep_num;
report_input.param_list = param_list;
report_input.param_vals = param_vals;
report_input.model_name = regexprep(ppi.model_name,'_',' ');
report_input.doc_root = ppi.output_path;
report_input.graphic = Graphic_path;
report_input.date = run_logs.wake.dte;
% This makes the preamble for the latex file.
preamble = latex_add_preamble(report_input);
wake_ltx = generate_latex_for_wake_analysis(...
    pp_data.wake_data.raw_data.port.alpha,...
    pp_data.wake_data.raw_data.port.beta,...
    pp_data.wake_data.raw_data.port.frequency_cutoffs_all, ...
    pp_data.wake_data.raw_data.port.labels_table);
combined = cat(1,preamble, '\clearpage', wake_ltx);
% This adds the input file to the document as an appendix.
gdf_name = regexprep(ppi.model_name, 'GdfidL_','');
if exist(['pp_link/wake/', gdf_name, '.gdf'],'file')
    gdf_data = add_gdf_file_to_report(['pp_link/wake/', gdf_name, '.gdf']);
    combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
end
% Finish the latex document.
combined = cat(1,combined,'\end{document}' );

cd([data_path, '/wake'])
latex_write_file('Wake_report',combined);
process_tex('.', 'Wake_report')
cd(old_path)
