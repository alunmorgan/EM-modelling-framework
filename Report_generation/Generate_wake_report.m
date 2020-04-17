function [w_ltx, w_appnd] = Generate_wake_report(data_path, pp_data, wake_data, mi, ppi, port_overrides, run_log)
% Uses the pregenerated images resulting from the wake analysis
% and generates the appropriate latex code to turn them
% into a useable report.
%
% data_path is the path where the images and datafiles are stored.
%
% Example: Generate_wake_report( data_path, pp_data)

try
    w_ltx = generate_latex_for_wake_analysis(pp_data, wake_data, mi, ppi, port_overrides, run_log);
catch
    w_ltx = cell(1,1);
    w_ltx = cat(1,w_ltx,'\chapter{Wakefield analysis}');
    w_ltx = cat(1, w_ltx, 'There is no valid wake data. But a wake simulation was requested.');
    w_ltx = cat(1,w_ltx,'\clearpage');
end %try
% This adds the input file to the document as an appendix.
if exist(fullfile(data_path, 'model.gdf'),'file') == 2
    gdf_data = add_gdf_file_to_report(fullfile(data_path, 'model.gdf'));
    w_appnd = cat(1,'\chapter{Wake input file}',gdf_data);
else
    w_appnd = cell(1,1);
end %if



