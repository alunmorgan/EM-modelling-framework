function [w_ltx, w_appnd] = Generate_wake_report(modelling_inputs, input_settings, set_id, results_paths)
% Uses the pregenerated images resulting from the wake analysis
% and generates the appropriate latex code to turn them
% into a useable report.
%
% data_path is the path where the images and datafiles are stored.
%
% Example: Generate_wake_report( data_path, pp_data)

ppi = input_settings.ppi;


% pp_data, run_log

% Load up the data extracted from the run log.
%  load(fullfile(results_path, 'data_from_run_logs.mat'), 'run_logs')

% Load up the post precessed data.
% load(fullfile(postprocessing_path, 'data_postprocessed.mat'), 'pp_data')
ad = load(fullfile(results_paths.analysis_path, 'data_analysed_wake.mat'));
wake_data = ad.analysed_data;

try
    w_ltx = generate_latex_for_wake_analysis(wake_data, modelling_inputs, ppi, results_paths);
catch
    w_ltx = cell(1,1);
    w_ltx = cat(1,w_ltx,'\chapter{Wakefield analysis}');
    w_ltx = cat(1, w_ltx, 'There is no valid wake data. But a wake report was requested.');
    w_ltx = cat(1,w_ltx,'\clearpage');
end %try
% This adds the input file to the document as an appendix.
if exist(fullfile(results_paths.postprocessing_path, 'model.gdf'),'file') == 2
    gdf_data = add_gdf_file_to_report(fullfile(results_paths.postprocessing_path, 'model.gdf'));
    w_appnd = cat(1,'\chapter{Wake input file}',gdf_data);
else
    w_appnd = cell(1,1);
end %if



