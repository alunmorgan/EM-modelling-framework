function add_prefix(root_path, filetype, prefix)
% Scans the directory for files of the selected type. 
% Renames them to add the prefix.
%
% Example: add_prefix(root_path, filetype, prefix)

fullPaths = dir_list_gen(root_path, filetype, 1);

for je = 1:length(fullPaths)
    [a,b,c] = fileparts(fullPaths{je});
movefile(fullPaths{je}, fullfile(a,[prefix, '_', b, c]));
clear a b c 
end %for
