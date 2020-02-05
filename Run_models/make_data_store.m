function run_sim = make_data_store(model_name, results_storage_location, sim_type, skip_setting)
% Creates required data folders. If existing data is present it either sets
% the run_sim flag to 0 normally, or 1 if the override flag is set.

if exist(fullfile(results_storage_location, sim_type),'dir')
    if  skip_setting == 0
        old_store = ['old_data', datestr(now,30)];
        mkdir(results_storage_location, old_store)
        movefile(fullfile(results_storage_location, sim_type),...
            fullfile(results_storage_location, old_store))
        disp([sim_type,' data already exists for ',...
            model_name, ...
            '. However the overwrite flag is set so the simulation will be run anyway. Old data moved to ',...
            fullfile(results_storage_location, old_store)])
        run_sim = 1;
    else
        disp(['Skipping ', model_name, '. ' ,sim_type, ' data already exists'])
        run_sim = 0;
    end %if
else
    mkdir(results_storage_location, sim_type)
    run_sim = 1;
end %if