function generate_report(root_path, model_sets, chosen_wake_length)

for hfa = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{hfa}), 'mat', 1);
    wanted_files = files(contains(files, 'data_postprocessed.mat'));
    split_str = regexp(wanted_files, ['\',filesep], 'split');
    for ind = 1:length(wanted_files)
        model_name = split_str{ind}{end - 2};
        path_to_data = fullfile(split_str{ind}{1:end-2});
        disp(['Generating a report for ', model_name])
        generate_graphs(path_to_data, chosen_wake_length)
        Report_setup(path_to_data, chosen_wake_length)
    end %for
end %for
