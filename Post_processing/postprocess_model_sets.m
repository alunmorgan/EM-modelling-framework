function postprocess_model_sets(input_file_loc, model_names, force_pp, pp_type)
% model_names: the name of the model set you wish to simulate.
% force_pp: sets whether the GdfidL postprocessing is rerun for existing
% simulations. values are 'skip' and 'no_skip'.
% pptype: 'all', 'wake', 'eigenmode', 'eigenmode_lossy','s_parameter', 'shunt'
orig_loc = pwd;

for hew = 1:length(model_names)
    try
        disp(['<strong>Post processing model set ', model_names{hew}, '</strong>'])
        cd(fullfile(input_file_loc, model_names{hew}))
        run_inputs = feval(model_names{hew});
        run_model_postprocessing(run_inputs, NaN, force_pp, pp_type)
        cd(orig_loc)
    catch ME
        cd(orig_loc)
        disp('<strong>Problem with models.</strong>')
        display_error_message(ME)
    end %try
end %for
