function extract_gdf_files_from_folder_structure(root_path, destination)
% Scans the directory tree for gdf files. Renames them using their location in
% the tree. Puts the newly renamed files in the destination folder.
%
% Example: function extract_gdf_files_from_folder_structure(root_path, destination)

fullPaths = dir_list_gen_tree(root_path, '.gdf',1);
names = regexprep(fullPaths, [root_path, '/'], '');
names = regexprep(names, '/', '-');
for ne = 1:length(names)
    copyfile(fullPaths{ne}, fullfile(destination, names{ne}))
end %for