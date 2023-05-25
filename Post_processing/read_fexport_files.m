function read_fexport_files(data_location, out_path, scratch_path)

fileset_name = 'field_snapshots_';

field_files = dir_list_gen(data_location, '',1);
[~,file_names_temp,~]=fileparts(field_files);
inds = strfind(file_names_temp, fileset_name);
inds = find_position_in_cell_lst(inds);
if isempty(inds)
    return
end %if
disp('Extracting field data')
fileset = field_files(inds);
    if contains(fileset_name, 'field_snapshots_')
        % dealing with a full snapshot.
        process_snapshot_fields(fileset, fileset_name, out_path)
    else
        % dealing with a single slice
        process_slice_fields(fileset, fileset_name, out_path, scratch_path)
    end %if
end %for
