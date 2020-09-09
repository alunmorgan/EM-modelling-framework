function run_model_postprocessing(mi, simulation_result_locations, force_pp, pp_type)


if ispc ==1
    error('This needs to be run on the linux modelling machine')
end %if

modelling_inputs = run_inputs_setup_STL(mi);

for awh = 1:length(modelling_inputs)
    disp(datestr(now))
    disp(['Postprocessing ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    try
        model_name = modelling_inputs{awh}.model_name;
        if isnan(simulation_result_locations)
            %If NaN. will default to the main storage location.
            GdfidL_post_process_models(mi.paths, model_name,...
                'ow_behaviour',force_pp,...
                'type_selection', pp_type);
        else
            GdfidL_post_process_models(mi.paths, model_name, ...
                'ow_behaviour',force_pp,...
                'input_data_location', simulation_result_locations,...
                'type_selection', pp_type);
        end %if
    catch ERR
        display_postprocessing_error(ERR)
    end %try
end %for


