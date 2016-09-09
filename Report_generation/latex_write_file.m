function latex_write_file(file_title,file_contents)
% Takes a cell array of strings and writes is to a text file.
fid = fopen([file_title '.tex'],'wt');
for be = 1:length(file_contents)
    mj = char(file_contents{be});
    fwrite(fid,mj);
    fprintf(fid,'\n','');
end
clear be
fclose(fid);
