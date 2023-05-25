function run_field_extraction(input_settings, set_id, paths)

for herf = 1:length(input_settings.sim_types)
    if strcmp(input_settings.sim_types{herf}, 'wake')
        orig_loc = pwd;
        cd(fullfile(paths.inputfile_location, input_settings.sets{set_id}))
        run_inputs = feval(input_settings.sets{set_id});
        modelling_inputs = run_inputs_setup_STL(run_inputs, input_settings.versions,...
            input_settings.n_cores, input_settings.precision);
        cd(orig_loc)
        for awh = 1:length(modelling_inputs)
            try
                data_path = fullfile(paths.results_loc, modelling_inputs{awh}.base_model_name,...
                    modelling_inputs{awh}.model_name, 'postprocessing', 'wake');
                output_path = fullfile(paths.results_loc, modelling_inputs{awh}.base_model_name,...
                    modelling_inputs{awh}.model_name, 'fields', 'wake');
                if ~exist(output_path, 'dir')
                    mkdir(output_path)
                end
                read_fexport_files(data_path, output_path, paths.scratch_loc);
            catch ME
                warning([input_settings.sets{set_id}, ' <strong>Problem with field extraction</strong>'])
                display_error_message(ME)
            end %try
        end %for
    end %if
end %for