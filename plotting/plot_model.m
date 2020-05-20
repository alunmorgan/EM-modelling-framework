function plot_model(root_path, ppi, input_settings, override)

datasets = find_datasets(root_path, input_settings);

% split_str = regexp(path_to_data, filesep, 'split');
for ind = 1:length(datasets)
    [~, model_name, ~] = fileparts(path_to_data{ind});
    %     path_to_data = fullfile(split_str{ind}{1:end-2});
    %     if isempty(split_str{1,1}{1})
    %         % This will ensure the leading slash is kept.
    %         path_to_data = [filesep, path_to_data];
    %     end %if
    if override == 1 || exist(fullfile(rep_path, 'Report.pdf')) == 0
        disp(['Generating a graphs for ', model_name])
        generate_graphs(datasets{ind}, ppi, input_settings{4})
    else
        disp(['Graphs already exists for ', model_name, ' and no override is set. Skipping...'])
    end
end %for
