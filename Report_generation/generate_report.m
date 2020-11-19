function generate_report(root_path, ppi, input_settings, override)

    datasets = find_datasets(fullfile(root_path, input_settings{1}));
for ind = 1:length(datasets)
%     model_name = split_str{ind}{end - 2};
%     path_to_data = fullfile(split_str{ind}{1:end-2});
%     if isempty(split_str{1,1}{1})
%         % This will ensure the leading slash is kept.
%         path_to_data = [filesep, path_to_data];
%     end %if
    if override == 1 || ~exist(fullfile(datasets{ind}.path_to_data, 'Report.pdf'), 'file') == 0
        disp(['Generating a report for ', datasets{ind}.model_name])
%         generate_graphs(path_to_data, ppi, input_settings{4})
        Report_setup(datasets{ind}.path_to_data, ppi, input_settings{2}, input_settings{3})
    else
        disp(['Report already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
    end %if
end %for

%     if override == 1 || exist(fullfile(rep_path, 'Report.pdf')) == 0
%             rep_path = fullfile(report_root, input_settings{1}, [input_settings{1}, '_',input_settings{3}{1}]);