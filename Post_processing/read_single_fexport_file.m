function file_data = read_single_fexport_file(input_file, scratch_path)
% unzips and loads a signel fexport file. Will retry in the case of slow
% filesystems.

temp_unzip = fullfile(scratch_path, 'temp_unzip');
temp_name = gunzip(input_file, temp_unzip);
file_data = {};
for hsk = 1:10
    try
        file_data = read_in_text_file(temp_name{1});
        break
    catch
        % If the filesystem is slow then the new file will not appear by the
        % time you want to read it in. Wait for a bit and then try again.
        disp(['file ', temp_name{1}, ' unavailable... retrying'])
        pause(5)
    end %try
end %for
if isempty('file_data')
    disp(['Could not extract data from ', temp_name{1}])
end %if
delete(temp_name{1})