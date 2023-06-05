function data = read_in_text_file(file_location)
% Opens the requested file. Each line is put into a cell of a cell array.
% file_location is the name and path of the file to open
% data is the resulting cell array.
%
% Example: data = read_in_text_file(file_location)

fid = fopen(file_location);
% finding the length of the file first. For large files this allows for the
% correct level of preallocation and thus prevents slowdowns.
% NOTE: This does not correctly deal with empty lines so a while loop is still
% required. But the preallocation helps.
nrows = numel(cell2mat(textscan(fid,'%1c%*[^\n]')));
frewind(fid);
data = cell(nrows,1);
pgs = 0;
fprintf([' Reading file...', file_location, '...'])
fprintf('  0%%')
nd =1;
while true
    current_line = fgetl(fid);
    if rem(nd, floor(nrows/100)) == 0
        pgs = pgs + 1;
        fprintf(['\b\b\b\b', num2str(pgs, '%03.f'),'%%'])
    end %if
    if current_line == -1
        break
    end
    data{nd} = current_line;
    nd = nd +1;
end %while
fclose(fid);
data = data';



