function [model_names, wlf, wake_length, metric] = extract_all_wlf(root_path, model_sets)


for sts = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{sts}), 'mat', 1);
    wanted_files = files(contains(files, 'data_analysed_wake.mat'));
    if isempty(wanted_files)
        disp(['No analysed files found for ',model_sets{sts},', please run analyse_pp_data.'])
        continue
    else
        disp(['Getting wake loss factors for ',model_sets{sts}])
    end %if
    split_str = regexp(wanted_files, ['\',filesep], 'split');
    for ind = 1:length(wanted_files)
        current_folder = fileparts(wanted_files{ind});
        load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
        load(fullfile(current_folder, 'data_analysed_wake'),'wake_data');
        model_names{sts,ind} = split_str{ind}{end - 2};
        wlf(sts,ind) = wake_data.time_domain_data.wake_loss_factor;
        wake_length(sts,ind) = pp_data.wake_setup.Wake_length;
        pling = max(abs(pp_data.Wake_potential(:,2)));
        % now looking at the last ~10ps of data
        tail = max(abs(pp_data.Wake_potential(end-600:end,2)));
        metric(sts,ind) = (tail ./ pling) .* 100;
        clear pp_data wake_data
    end %for
end %for