function postprocess_model_sets(model_names, force_pp, pp_type)
% model_names: the name of the model set you wish to simulate.
% force_pp: sets whether the GdfidL postprocessing is rerun for existing
% simulations. values are 'skip' and 'no_skip'.

orig_loc = pwd;

for hew = 1:length(model_names)
    try
        cd(fullfile(orig_loc, model_names{hew}))
        run_inputs = feval(model_names{hew});
        run_model_postprocessing(run_inputs, NaN, force_pp, pp_type)
        cd(orig_loc)
    catch ME
        cd(orig_loc)
        warning('postprocess_model_sets: Problem with models.')
                  rethrow(ME)

    end %try
end %for
