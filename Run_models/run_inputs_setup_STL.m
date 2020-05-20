function modelling_inputs = run_inputs_setup_STL(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: modelling_inputs = run_inputs_setup_STL(mi)

model_num = 0;

%% Building up a set of inputs to be passed to the EM simulator.
[defs, ~] = construct_defs(mi.material_defs);
% The geometry variations are already defined,

% This is the locaton of the parameter file for the base model. The code
% will default to using this if there is no model specific parameter file
% present. (i.e. if meshing parameters are being changed rather
% than geometric parameters)
base_parameter_file_path = fullfile(mi.paths.path_to_models, ...
    mi.base_model_name,[mi.base_model_name, '_Base'],...
    [mi.base_model_name, '_Base_parameters.txt']);

for fdhs = 1:length(mi.model_names)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{fdhs});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if strcmpi(mi.movie_flag, 'All')
        modelling_inputs{model_num}.mov = 1;
    end %if
    if fdhs ~= mi.base_model_ind
        modelling_inputs{model_num}.set_name = regexprep(mi.model_names{fdhs}, ...
            [mi.base_model_name, '_(.*)?_value_.*'], '$1' );
    else
        modelling_inputs{model_num}.set_name ='Base';
        if strcmpi(mi.movie_flag, 'Base')
            modelling_inputs{model_num}.mov = 1;
        end %if
        
    end %if
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name,mi.model_names{fdhs}, 'ascii');
    parameter_file_path = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name,mi.model_names{fdhs},...
        [mi.model_names{fdhs}, '_parameters.txt']);
    
    if exist(parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for

% Setting up the material variations off the base model.
for awh = 2:length(defs)
    model_num = model_num +1;
    def = defs{awh};
    def = regexp(def, 'define\(\s*(\w*)\s*,\s*(\w*)\s*\)','tokens');
    def = def{1}{1};
    % The inputs of the current geometry before any simulation
    % parameter sweeps.
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if strcmpi(mi.movie_flag, 'All')
        modelling_inputs{model_num}.mov = 1;
    end %if
    modelling_inputs{model_num}.set_name = def{1};
    modelling_inputs{model_num}.defs = defs{awh};
    modelling_inputs{model_num}.model_name = [...
        mi.base_model_name, '_', def{1}, '_sweep_value_', def{2}];
    modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
    if exist(base_parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(base_parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for

% Then set up the simulation parameter scans off the the base model.
% Generally all the codes starts with the temp_inputs as a starting
% point and then modifies the specific variable of that sweep.
sim_param_sweeps = {'beam_sigma', 'beam_offset_x', 'beam_offset_y',...
    'mesh_stepsize', 'mesh_density_scaling', 'wakelength', ...
    'NPMLs', 'precision', 'version', 'n_cores'};
for nw = 1:length(sim_param_sweeps)
    for mss = 2:length(mi.simulation_defs.(sim_param_sweeps{nw}))
        model_num = model_num +1;
        modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
        modelling_inputs{model_num}.mov = 0; %Default to no movie
        if strcmpi(mi.movie_flag, 'All')
            modelling_inputs{model_num}.mov = 1;
        end %if
        modelling_inputs{model_num}.(sim_param_sweeps{nw}) = mi.simulation_defs.(sim_param_sweeps{nw}){mss};
        modelling_inputs{model_num}.model_name = [...
            mi.base_model_name, '_', sim_param_sweeps{nw}, '_sweep_value_', ...
            regexprep(num2str(modelling_inputs{model_num}.(sim_param_sweeps{nw})), '\.','p')];
        modelling_inputs{model_num}.defs = defs{1};
        modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
            mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
        if exist(base_parameter_file_path, 'file') == 2
            modelling_inputs{model_num}.geometry_defs = ...
                get_parameters_from_sidecar_file(base_parameter_file_path);
        else
            modelling_inputs{model_num}.geometry_defs = {};
        end %if
    end %for
end %for

% Now setup which fractional geometries to use
for uned = 2:length(mi.simulation_defs.geometry_fractions)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if strcmpi(mi.movie_flag, 'All')
        modelling_inputs{model_num}.mov = 1;
    end %if
    tne = find(mi.simulation_defs.volume_fill_factor == mi.simulation_defs.geometry_fractions(uned));
    modelling_inputs{model_num}.geometry_fraction = mi.simulation_defs.geometry_fractions(uned);
    modelling_inputs{model_num}.port_fill_factor = mi.simulation_defs.port_fill_factor{tne};
    modelling_inputs{model_num}.port_multiple = mi.simulation_defs.port_multiple{tne};
    modelling_inputs{model_num}.volume_fill_factor = mi.simulation_defs.volume_fill_factor(tne);
    modelling_inputs{model_num}.ports = mi.simulation_defs.ports(1:end-tne +1);
    modelling_inputs{model_num}.port_location = mi.simulation_defs.port_location(1:end-tne +1);
    modelling_inputs{model_num}.port_modes = mi.simulation_defs.port_modes(1:end-tne +1);
    temp = [...
        mi.base_model_name, '_', 'Geometry_fraction', '_sweep_value_', ...
        num2str(mi.simulation_defs.geometry_fractions(uned))];
    temp = regexprep(temp, '\.','p');
    modelling_inputs{model_num}.model_name = temp;
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
    if exist(base_parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(base_parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for
