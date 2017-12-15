function modelling_inputs = run_inputs_setup_primitives(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: varargout = Gdfidl_run_models(mi.)

model_num = 0;

%% Building up a set of inputs to be passed to the EM simulator.
[defs, ~] = construct_defs(mi.material_defs);
for fdhs = 1:length(mi.model_names)
    [geometry_defs, ~] = construct_defs(mi.geometry_defs{fdhs});
    
    % Setup base model
    model_num = model_num +1;
    base_model_num = model_num;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{fdhs});
    modelling_inputs{model_num}.set_name ='Base';
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.geometry_defs = geometry_defs{1};
    % Find the names of the ports used in the current model.
    model_file = fullfile(mi.paths.input_file_path, ...
        [mi.model_names{fdhs}, '_model_data']);
    modelling_inputs{model_num}.port_names = gdf_extract_port_names(model_file);
    
    % Setting up the geometry variations off the base model.
    for awh = 2:length(geometry_defs)
        model_num = model_num +1;
        def = geometry_defs{awh};
        def = regexp(def, 'define\(\s*(\w*)\s*,\s*(\w*)\s*\)','tokens');
        def = def{1}{1};
        % The inputs of the current geometry before any simulation
        % parameter sweeps.
        modelling_inputs{model_num} = modelling_inputs{base_model_num};
        modelling_inputs{model_num}.geometry_defs = geometry_defs{awh};
        modelling_inputs{model_num}.set_name = def{1};
        modelling_inputs{model_num}.model_name = [...
            mi.base_model_name, '_', def{1}, '_', def{2}];
    end %for 
    
    % Setting up the material variations off the base model.
    for awh = 2:length(defs)
        model_num = model_num +1;
        def = defs{awh};
        def = regexp(def, 'define\(\s*(\w*)\s*,\s*(\w*)\s*\)','tokens');
        def = def{1}{1};
        % The inputs of the current geometry before any simulation
        % parameter sweeps.
        modelling_inputs{model_num} = modelling_inputs{base_model_num};
        modelling_inputs{model_num}.set_name = def{1};
        modelling_inputs{model_num}.defs = defs{awh};
        modelling_inputs{model_num}.model_name = [...
            mi.base_model_name, '_', def{1}, '_', def{2}];
    end %for
    
    % Then set up the simulation parameter scans off the the base model.
    % Generally all the codes starts with the temp_inputs as a starting
    % point and then modifies the specific variable of that sweep.
    sim_param_sweeps = {'beam_sigma', 'mesh_stepsize', 'wakelength', ...
        'NPMLs', 'precision', 'version'};
    for nw = 1:length(sim_param_sweeps)
        for mss = 2:length(mi.simulation_defs.(sim_param_sweeps{nw}))
            model_num = model_num +1;
            modelling_inputs{model_num} = modelling_inputs{base_model_num};
            modelling_inputs{model_num}.(sim_param_sweeps{nw}) = mi.simulation_defs.(sim_param_sweeps{nw}){mss};
            modelling_inputs{model_num}.model_name = [...
                mi.base_model_name, '_', sim_param_sweeps{nw}, '_', ...
                num2str(modelling_inputs(model_num).(sim_param_sweeps{nw}))];
            modelling_inputs{model_num}.defs = defs{1};
        end %for
    end %for   
end %for