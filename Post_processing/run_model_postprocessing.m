function run_model_postprocessing(mi, simulation_result_locations, ...
                                  pp_type, versions, n_cores, precision)


if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

modelling_inputs = run_inputs_setup_STL(mi, versions, n_cores, precision);

for awh = 1:length(modelling_inputs)
    fprinf(['\n<strong>', datestr(now), '</strong>'])
    fprinf(['\nPostprocessing ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    try
        model_name = modelling_inputs{awh}.model_name;
        if isnan(simulation_result_locations)
            %If NaN. will default to the main storage location.
            GdfidL_post_process_models(mi.paths, model_name,...
                'type_selection', pp_type);
        else
            GdfidL_post_process_models(mi.paths, model_name, ...
                'input_data_location', simulation_result_locations,...
                'type_selection', pp_type);
        end %if
    catch ERR
        fprinf('\nProblem with postprocessing.')
        display_error_message(ERR)
    end %try
end %for


