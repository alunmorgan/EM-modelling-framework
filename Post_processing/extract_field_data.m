function extract_field_data(in_path, out_path, scratch_path)
% Reads the field files generated by the wake simulation
% and puts the data into a data structure then saves the results to a .mat file.
% This is a slow process so it is best separated from analysis.

if ~exist(fullfile(out_path, 'field_data.mat'),'file')
    field_data = read_fexport_files(in_path, scratch_path);
    if ~isfield(field_data, 'nofiles')
        disp('Saving field datafile')
        save(fullfile(out_path,'field_data'), 'field_data')
        disp('Saved')
    end %if
else
    disp('Field_data file already exists... Skipping extraction.')
end %if