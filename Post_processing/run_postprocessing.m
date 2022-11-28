function run_postprocessing(input_settings, set_id, paths)

% postprocess the current set for all simulation types
for herf = 1:length(input_settings.sim_types)
    orig_loc = pwd;
    try
        cd(fullfile(paths.inputfile_location, input_settings.sets{set_id}))
        run_inputs = feval(input_settings.sets{set_id});
        modelling_inputs = run_inputs_setup_STL(run_inputs, input_settings.versions,...
            input_settings.n_cores, input_settings.precision);
        for awh = 1:length(modelling_inputs)
            [old_loc, tmp_name, data_path, output_path] = prepare_for_pp(modelling_inputs{awh}.base_model_name,...
                modelling_inputs{awh}.model_name, paths);
            [stat_datalink, ~]=system(['ln -s -T ',data_path, ' data_link']);
             [stat_pplink, ~]=system(['ln -s -T ',output_path, ' output_link']);
            GdfidL_post_process_models(fullfile(pwd, 'data_link'), fullfile(pwd, 'output_link'), modelling_inputs{awh}.model_name,...
                'type_selection', input_settings.sim_types{herf});
            cleanup_after_pp(old_loc, tmp_name)
        end %for
        cd(orig_loc)
    catch ME
        cd(orig_loc)
        disp([input_settings.sets{set_id},' <strong>Problem with postprocessing models.</strong>'])
        display_error_message(ME)
    end %try
end %for
