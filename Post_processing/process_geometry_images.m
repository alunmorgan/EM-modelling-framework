function process_geometry_images(paths, model_set)
% Converting any images from ps to png to reduce the file
% size. For larger models keeping the ps files can break the
% filesystem.
% find the simulated variations
[model_varients_folders, ~] = dir_list_gen(fullfile(paths.data_loc, model_set),'dirs', 1);
for ne = 1:length(model_varients_folders)
    source_loc = fullfile(paths.data_loc, model_set,model_varients_folders{ne});
    dest_loc = fullfile(paths.results_loc, model_set, model_varients_folders{ne});
    if exist(fullfile(dest_loc, 'geometry'),'dir') == 0
        mkdir(fullfile(dest_loc, 'geometry'))
    end %if
    [pic_names, ~] = dir_list_gen(fullfile(source_loc, 'geometry'),'ps',1);
    if ~isempty(pic_names)
        for ns = 1:length(pic_names)
            pic_nme = pic_names{ns}(1:end-3);
            [~] = system(['convert ',fullfile(source_loc, 'geometry', pic_nme),...
                '.ps -rotate -90 ',...
                fullfile(dest_loc, 'geometry', pic_nme),'.png']);
        end %for
    end %if
end %for