function run_field_extraction(input_settings, set_id)

for herf = 1:length(input_settings.sim_types)
    if strcmp(input_settings.sim_types{herf}, 'wake')
        orig_loc = pwd;
        cd(fullfile(input_settings.paths.inputfile_location, input_settings.sets{set_id}))
        run_inputs = feval(input_settings.sets{set_id});
        modelling_inputs = run_inputs_setup_STL(run_inputs, input_settings.versions,...
            input_settings.n_cores, input_settings.precision);
        cd(orig_loc)
        for awh = 1:length(modelling_inputs)
            try
                data_path = fullfile(input_settings.paths.results_loc, modelling_inputs{awh}.base_model_name,...
                    modelling_inputs{awh}.model_name, 'postprocessing', 'wake', 'wake');
                output_path = fullfile(input_settings.paths.results_loc, modelling_inputs{awh}.base_model_name,...
                    modelling_inputs{awh}.model_name, 'fields', 'wake');
                mkdirtree(output_path)
                output_files = dir_list_gen(output_path, 'mat', 1);
                if isempty(output_files)
                    read_fexport_files(data_path, output_path, input_settings.paths.scratch_loc);
                else
                    disp([modelling_inputs{awh}.model_name, ': <strong>Data already exists</strong>'])
                end %if
            catch ME
                warning([input_settings.sets{set_id}, ' <strong>Problem with field extraction</strong>'])
                display_error_message(ME)
            end %try
        end %for
    end %if
end %for