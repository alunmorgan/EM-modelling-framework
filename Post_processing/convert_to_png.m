function convert_to_png(source_loc, dest_loc)
% Converting any images from ps to png to reduce the file
% size. For larger models keeping the ps files can break the
% filesystem. Creates subfolders in the destination as required.
%
% Example: convert_to_png(source_loc, dest_loc)


[data_files, data_folders] = dir_list_gen_tree(source_loc, 'ps',1);
for sej =1:length(data_folders)
    dest_folder = regexprep(data_folders{sej}, source_loc, dest_loc);
    if ~exist(dest_folder, "dir")
        mkdir(dest_folder)
    end %if
    source_pic = fullfile(data_folders{sej}, data_files{sej});
    pp_pic = fullfile(dest_folder, [data_files{sej}(1:end-3), '.png']);
    if ~exist(pp_pic, "file")
        [~] = system(['convert ', source_pic,' -rotate -90 ',...
            pp_pic]);
    end %if
end %for
