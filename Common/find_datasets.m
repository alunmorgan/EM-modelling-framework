function datasets = find_datasets(root_path)

files = dir_list_gen_tree(root_path, 'mat', 1);
% wanted_files = files(contains(files, 'data_analysed_wake.mat'));
wanted_files = files(~contains(files, 'old_data'));
% Finding the models containing at least one data file.
path_to_data = wanted_files;
for ind = 1:length(wanted_files)
    for wha = 1:6
        [path_to_data{ind}, section_name] = fileparts(path_to_data{ind});
        if strcmp(section_name, 'sparameter') || strcmp(section_name, 'wake')
            break
        end %if
    end %for
end %for
path_to_data = unique(path_to_data);
for hef = 1:length(path_to_data)
    temp  = wanted_files(contains(wanted_files, path_to_data{hef}));
    datasets{hef}.wake = temp(contains(temp, 'wake'));
    datasets{hef}.sparameter = temp(contains(temp, 'sparameter'));
    datasets{hef}.path_to_data = path_to_data{hef};
    [~, model_name, ~] = fileparts(path_to_data{hef});
    datasets{hef}.model_name = model_name;
end %for