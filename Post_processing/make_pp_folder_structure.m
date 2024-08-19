function make_pp_folder_structure(paths, sets, set_id)


source_loc = fullfile(paths.data_loc, sets{set_id});
dest_loc = fullfile(paths.results_loc, sets{set_id});
data_folders = dir_list_gen_tree(source_loc, 'dirs',1);
pp_folders = regexprep(data_folders, source_loc, dest_loc);
for jse = 1:length(pp_folders)
    if exist(pp_folders{jse},'dir') == 0
        mkdir(pp_folders{jse})
    end %if
end %for