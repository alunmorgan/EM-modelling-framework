function data = read_file_full_line(file_name)
% Reads a text file line by line and returns a cell array containing each
% line in full.
%
% Example: data = read_file_full_line(file_name)

fid = fopen(file_name);
ck = 1;
while ~feof(fid)
    current_line = textscan(fid,'%[^\n]',1,'Delimiter','\n');
    if ~isempty(current_line{1})
%         current_line = find_val_in_cell_nest(current_line);
        data{ck,1} = current_line{1};
        ck = ck+1;
    else
        % Sometimes the end of file is not properly found.
        % in that case an empty cell is often returned.
        break
    end
end
fclose(fid);