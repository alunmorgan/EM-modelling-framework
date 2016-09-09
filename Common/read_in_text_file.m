function data = read_in_text_file(file_location)
% Opens the requested file. Each line is put into a cell of a cell array.
% file_location is the name and path of the file to open
% data is the resulting cell array.

fid = fopen(file_location);
nd = 1;
data = cell(1,1);
while 1==1
    current_line = fgetl(fid);
    if current_line == -1
        break
    end
    data{nd} = current_line;
    nd = nd + 1;
end
fclose(fid);
data = data';