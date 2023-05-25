function export_snapshots_csvs(data, field_type, output_location, prefix)

if isfield(data, 'Fx')
    field_dir = 'Fx';
elseif isfield(data, 'Fy')
    field_dir = 'Fy';
elseif isfield(data, 'Fz')
    field_dir = 'Fz';
end %if

if strcmp(field_type, 'e')
    field_units = '(V/m)';
elseif strcmp(field_type, 'h')
    field_units = '(A/m)';
end %if

save_timestamp = [num2str(round(data.data.timestamp * 1E9*10000)/10000), 'ns'];
save_timestamp = regexprep(save_timestamp, '\.', 'p');
field_data = data.(field_dir);
out_file_name = [prefix, '_snapshot_', save_timestamp, '_', field_dir];
disp('export_snapshots_csvs: writing snapshot CSV')
writematrix(field_data, fullfile(output_location, [out_file_name, '.csv']));
