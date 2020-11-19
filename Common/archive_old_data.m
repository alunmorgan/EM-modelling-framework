function archive_old_data(results_storage_location, model_name, simulation_type)
% Moves old data so that a new simulation can be run clean.

   old_store = ['old_data', datestr(now,30)];
        mkdir(results_storage_location, old_store)
        movefile(fullfile(results_storage_location, simulation_type),...
            fullfile(results_storage_location, old_store))
        disp([simulation_type,' data already exists for ',...
            model_name, ...
            ' Old data moved to ', fullfile(results_storage_location, old_store)])