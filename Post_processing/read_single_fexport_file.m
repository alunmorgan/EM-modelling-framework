function file_data = read_single_fexport_file(input_file)
% loads a single fexport file. Will retry in the case of slow
% filesystems.


file_data = {};
for hsk = 1:10
    try
        file_data = read_in_text_file(input_file);
        break
    catch
        % If the filesystem is slow then the new file will not appear by the
        % time you want to read it in. Wait for a bit and then try again.
        fprinf(['\nfile ', input_file, ' unavailable... retrying'])
        pause(5)
    end %try
end %for
if isempty('file_data')
    fprinf(['\nCould not extract data from ', input_file])
end %if
