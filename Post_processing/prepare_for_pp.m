function [old_loc, tmp_name] = prepare_for_pp(model_base_name, model_name, paths)

% storing the original location so that  we can return there at the end.
[old_loc, tmp_name] = move_into_tempororary_folder(paths.scratch_loc);

if ~exist(fullfile(paths.results_loc, model_base_name, model_name), 'dir')
    mkdir(fullfile(paths.results_loc, model_base_name, model_name))
end
% make soft links to the data folder and output folder into /scratch.
% this is because the post processor does not handle long paths well.
% this makes things more controlled.
if exist('data_link','dir') ~= 0
    delete('data_link')
end
if exist('pp_link','dir') ~= 0
    delete('pp_link')
end
[stat_datalink, ~]=system(['ln -s -T ',fullfile(paths.data_loc, model_base_name, model_name), ' data_link']);
[stat_pplink, ~]=system(['ln -s -T ',fullfile(paths.results_loc, model_base_name, model_name), ' pp_link']);
if stat_datalink ~= 0 || stat_pplink ~= 0
    disp('<strong>Error creating soft links... aborting postprocessing</strong>')
end %if