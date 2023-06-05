function run_sim = make_data_store(model_name, results_storage_location, sim_type)
% Creates required data folders. If existing data is present it either sets
% the run_sim flag to 0 normally, or 1 if the override flag is set.

if exist(fullfile(results_storage_location, sim_type),'dir')
            fprintf(['\nSkipping ', model_name, '. ' ,sim_type, ' data already exists'])
        run_sim = 0;
else
    if ~exist(fullfile(results_storage_location, sim_type), 'dir')
    mkdir(results_storage_location, sim_type)
    end %if
    run_sim = 1;
end %if