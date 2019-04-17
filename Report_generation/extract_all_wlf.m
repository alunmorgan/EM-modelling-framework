function [model_names, wlf, wake_length, metric] = extract_all_wlf(root, model_set)

files = dir_list_gen_tree(fullfile(root, model_set), 'mat', 1);
wanted_files = files(contains(files, 'data_postprocessed.mat'));
split_str = regexp(wanted_files, ['\',filesep], 'split');
for ind = 1:length(wanted_files)
    tmp = load(wanted_files{ind});
    model_names{ind} = split_str{ind}{end - 2};
    wlf(ind) = tmp.pp_data.time_domain_data.wake_loss_factor;
    wake_length(ind) = tmp.pp_data.raw_data.wake_setup.Wake_length;
    pling = max(abs(tmp.pp_data.raw_data.Wake_potential(:,2)));
    % now looking at the last ~10ps of data
    tail = max(abs(tmp.pp_data.raw_data.Wake_potential(end-600:end,2)));
    metric(ind) = (tail ./ pling) .* 100;
    clear tmp    
end %for
