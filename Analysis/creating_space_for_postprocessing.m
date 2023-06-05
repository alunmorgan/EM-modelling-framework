function creating_space_for_postprocessing(pp_directory, sim_type, model_name)
% Create the appropriate folder structure for the postprocessed data to go.
% If data is already present then the old data is moved to another folder.
%
% Example: creating_space_for_postprocessing('wake', model_name)
if exist(pp_directory, 'dir') == 7
    fprinf(['\nMoving old ', sim_type, ' postprocessing data for ',model_name])
    old_store = ['old_data', datestr(now,30)];
    mkdir(pp_directory, old_store)
    movefile(pp_directory, fullfile(pp_directory, old_store))
end %if
fprinf(['\nCreating ', sim_type, ' postprocessing folder for ',model_name])
mkdir(pp_directory);

