function extract_field_data
% Reads the field files generated by the wake simulation 
% and puts the data into a data structure then saves the results to a .mat file. 
% This is a slow process so it is best separated from analysis.

field_data = read_fexport_files(fullfile('data_link', 'wake'));
if ~isfield(field_data, 'nofiles')
    save(fullfile('pp_link', 'wake','field_data'), 'field_data')
end %if