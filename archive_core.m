function archive_core(root, dest, model)
% root = '/dls/science/groups/b01/EM_simulation/EM_modeling_Reports/';
% dest = '/dls/science/groups/b01/';
% model = 'simple_diamond_2_buttons';
target_loc = fullfile(root, model);
locs_mat = dir_list_gen_tree(target_loc,'mat', 1);
locs_mat = locs_mat(~contains(locs_mat, 'data_analysed_wake'));
locs_all = dir_list_gen_tree(target_loc,'',1);
locs_gdf = dir_list_gen_tree(target_loc,'gdf',1);
locs_pp = locs_all(contains(locs_all, 'model_wake_post_processing'));
locs_log = locs_all(contains(locs_all, 'model_log'));
clear locs_all
locs = cat(1,locs_mat, locs_gdf, locs_pp, locs_log);
locs_out = regexprep(locs, root, dest);
for ics = 1:length(locs_out)
    [tmp_path,name,ext] = fileparts(locs_out{ics});
    if ~exist(tmp_path, 'dir')
        mkdir(tmp_path);
    end %if
    copyfile(locs{ics}, locs_out{ics})
end %for