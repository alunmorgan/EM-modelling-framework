function run_pp = will_pp_run(input_data_location, output_data_location)

[~, type_name, ~] = fileparts(input_data_location);

if exist(input_data_location, 'dir')
    if ~exist(fullfile(output_data_location, ['model_', type_name, '_post_processing']), 'file')
        run_pp = 1;
    else
         fprinf(['\nSkipping ', type_name, ' postprocessing data already exists'])
        run_pp = 0;
    end %if
else
    fprinf('\nNo source data for postprocessing')
    run_pp =0;
end %if

