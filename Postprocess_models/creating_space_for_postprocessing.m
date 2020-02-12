function creating_space_for_postprocessing(sim_type, run_pp, model_name)
% Create the appropriate folder structure for the postprocessed data to go.
% If data is already present and the no_skip option has been selected then the
% old data is moved to another folder.
%
% Example: creating_space_for_postprocessing('wake', 1, model_name)
if run_pp == 1
    if exist(fullfile('pp_link', sim_type), 'dir') == 7
        disp(['Moving old ', sim_type, ' postprocessing data for ',model_name])
        old_store = ['old_data', datestr(now,30)];
        mkdir('pp_link', old_store)
        movefile(fullfile('pp_link', sim_type), fullfile('pp_link', old_store))
    end %if
    disp(['Creating ', sim_type, ' postprocessing folder for ',model_name])
    [~] = system(['mkdir ', fullfile('pp_link', sim_type)]);
else
    disp(['Skipping ', sim_type, ' postprocessing for ',model_name, ' data already exists'])
end %if
