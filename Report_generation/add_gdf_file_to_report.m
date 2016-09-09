function data = add_gdf_file_to_report(gdf_loc)
% Wraps the gdf file in Latex code so it can be appended to the report.
%
% Example: data = add_gdf_file_to_report(gdf_loc)

data = read_in_text_file(gdf_loc);
data = cat(1,'\begin{verbatim}', data, '\end{verbatim}');