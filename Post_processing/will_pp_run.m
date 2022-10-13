function run_pp = will_pp_run(input_data_location, output_data_location)

[~, type_name, ~] = fileparts(input_data_location);

if exist(input_data_location, 'dir')
    if ~exist(fullfile(output_data_location, ['model_', type_name, '_post_processing']), 'file')
        run_pp = 1;
    else
         disp(['Skipping ', type_name, ' postprocessing data already exists'])
        run_pp = 0;
    end %if
else
    disp('No source data for postprocessing')
    run_pp =0;
end %if

