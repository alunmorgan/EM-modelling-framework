function datasets = find_datasets(root_path)

files = dir_list_gen_tree(root_path, 'mat', 1);
wanted_files = files(contains(files, 'data_from_pp_logs.mat'));
wanted_files = wanted_files(~contains(wanted_files, 'old_data'));
% Finding the models containing at least one data file.
for ind = 1:length(wanted_files)
    path_to_data{ind} = fileparts(wanted_files{ind});
    path_to_data{ind} = fileparts(path_to_data{ind});
end %for
path_to_data = unique(path_to_data);
for hef = 1:length(path_to_data)
    temp  = wanted_files(contains(wanted_files, path_to_data{hef}));
    if any(contains(temp, 'wake'))
        datasets{hef}.wake = temp{contains(temp, 'wake')};
    end %if
    if any(contains(temp, 's_parameter'))
        datasets{hef}.s_parameter = temp{contains(temp, 's_parameter')};
    end %if
    datasets{hef}.path_to_data = path_to_data{hef};
    [~, model_name, ~] = fileparts(path_to_data{hef});
    datasets{hef}.model_name = model_name;
end %for