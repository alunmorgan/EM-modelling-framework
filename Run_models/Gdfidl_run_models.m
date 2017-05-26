function Gdfidl_run_models(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: varargout = Gdfidl_run_models(mi.)

if ispc ==1
    error('This needs to be run on the linux modelling machine')
end

[defs, ~] = construct_defs(mi.additional_defs);
for awh = 1:length(defs)
    disp(datestr(now))
    disp([mi.model_name, ' - ',num2str(awh), ' of ', num2str(length(defs))])
    
    % Setting up the inputs which change in each model iteration.
    modelling_inputs.defs = defs{awh};
    
    % Find the names of the ports used in the current model.
    model_file = [mi.input_file_path, mi.model_name, '_model_data'];
    [port_names] = gdf_extract_port_names(model_file);
    modelling_inputs.port_names = port_names;
    modelling_inputs.n_cores = num2str(mi.n_cores);
    
    
    arc_date = datestr(now,30);
    if ~isempty(strfind(mi.sim_select, 'w'))
        try
            run_wake_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'wake')
        end
        
    end
    if ~isempty(strfind(mi.sim_select, 's'))
        try
            run_s_param_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'S-parameter')
        end
    end
    if ~isempty(strfind(mi.sim_select, 'e'))
        try
            run_eigenmode_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'eigenmode')
        end
        
    end
    if ~isempty(strfind(mi.sim_select, 'l'))
        try
            run_eigenmode_lossy_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'lossy eigenmode')
        end
        
    end
    if ~isempty(strfind(mi.sim_select, 'r'))
        try
            run_shunt_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'shunt')
        end
        
    end
end

