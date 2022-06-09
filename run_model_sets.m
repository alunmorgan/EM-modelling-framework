function run_model_sets(model_names, sim_types, versions, n_cores, precision)
% model_names: the name of the model set you wish to simulate.
% force_pp: sets whether the GdfidL postprocessing is rerun for existing
% simulations. values are 'skip' and 'no_skip'.

paths = load_local_paths;
orig_loc = pwd;

for hew = 1:length(model_names)
    try
        cd(fullfile(orig_loc, model_names{hew}))
        run_inputs = feval(model_names{hew});
        run_models(run_inputs, sim_types, paths.restart_files_path, ...
                   versions, n_cores, precision)
        cd(orig_loc)
    catch ME
        cd(orig_loc)
        disp(['Problem running model ', model_names{hew}])
        display_error_message(ME)
        
    end %try
end %for
