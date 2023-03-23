function read_fexport_files(data_location, out_path, scratch_path)

gzFiles = dir_list_gen(data_location, 'gz',1);
if isempty(gzFiles)
    return
end %if
disp('Extracting field data')
set_start_inds = find(contains(gzFiles, '000001.gz'));
n_sets = length(set_start_inds);
set_start_inds = [set_start_inds; length(gzFiles)+1];
for twm = 1:n_sets
    disp([num2str(twm), ' of ', num2str(n_sets)])
    fileset = gzFiles(set_start_inds(twm):set_start_inds(twm+1)-1);
    [~, fileset_name, ~] = fileparts(gzFiles{set_start_inds(twm)});
    fileset_name = regexprep(fileset_name, '[0-9-]', '');
    
    if contains(fileset_name, 'fields_full_snapshot_')
        % dealing with a full snapshot.
        process_snapshot_fields(fileset, fileset_name, out_path, scratch_path)
    else
        % dealing with a single slice
        process_slice_fields(fileset, fileset_name, out_path, scratch_path)
    end %if
end %for
