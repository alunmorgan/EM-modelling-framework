function generate_report(datasets, ppi, input_settings, override)

for ind = 1:length(datasets)
    if override == 1 || ~exist(fullfile(datasets{ind}.path_to_data, 'Report.pdf'), 'file')
        disp(['Generating a report for ', datasets{ind}.model_name])
        Report_setup(datasets{ind}.path_to_data, ppi, input_settings)
    else
        disp(['Report already exists for ', datasets{ind}.model_name, ' and no override is set. Skipping...'])
    end %if
end %for
