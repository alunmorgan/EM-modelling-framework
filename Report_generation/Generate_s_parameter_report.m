function [s_ltx, s_appnd] = Generate_s_parameter_report(data_path)
% Take the output from the s_parameter postprocessing and collates it into a
% report.
%
% data_path is the path where the images and datafiles are stored.
%
% Example: Generate_s_parameter_report( data_path)




s_ltx = generate_latex_for_s_parameter_analysis(data_path);

% This adds the input file to the document as an appendix.
if exist([data_path, '/s_parameter/model.gdf'],'file')
    gdf_data = add_gdf_file_to_report([data_path, '/s_parameter/model.gdf']);
    s_appnd = cat(1,'\chapter{S parameter input file}',gdf_data);
end
