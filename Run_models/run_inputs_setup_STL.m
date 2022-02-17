function modelling_inputs = run_inputs_setup_STL(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: modelling_inputs = run_inputs_setup_STL(mi)

%%%% Generating mappings %%%%%
for nwe = 1:length(mi.mat_params)
    % Structure is {stl file name, material name, order to apply the stl files}
    mi.stl_part_mapping{nwe,1} = [mi.base_model_name, '-', mi.mat_params{nwe}{1}];
    mi.stl_part_mapping{nwe,2} = mi.mat_params{nwe}{2};
    mi.stl_part_mapping{nwe,3} = mi.mat_params{nwe}{6};
end %for
% A lookup table of materials to component names
ck = 1;
for nes = 1:length(mi.mat_params)
    if ~strcmp(mi.mat_params{nes}{2}, 'vacuum')
        mi.mat_list{ck, 1} = mi.mat_params{nes}{2};
        mi.mat_list{ck, 2} = mi.mat_params{nes}{3};
        mi.material_defs{ck} = {mi.mat_params{nes}{2}, ...
            mi.mat_params{nes}{5}, mi.mat_params{nes}{4}};
        ck = ck +1;
    end %if
end %for


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

%% Base model
for fdhs = 1:length(mi.model_names)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{fdhs});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if contains(mi.movie_flag, 'base')
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

%% Setting up the material variations off the base model.
baseline_def = regexp(defs{1}, 'define\(\s*(\w*)\s*,\s*(\w*)\s*\)','tokens');
for ks = 1:length(baseline_def)
    baseline_materials{ks,1} = baseline_def{ks}{1}{1};
    baseline_materials{ks,2} = baseline_def{ks}{1}{2};
end %for
varying_material = '';
material_value = '';
for awh = 2:length(defs)
    model_num = model_num +1;
    def = defs{awh};
    def = regexp(def, 'define\(\s*(\w*)\s*,\s*(\w*)\s*\)','tokens');
    for ks = 1:length(def)
        model_materials{ks,1} = def{ks}{1}{1};
        model_materials{ks,2} = def{ks}{1}{2};
    end %for
    for her = 1:size(model_materials,1)
        ind_in_baseline = find(contains(baseline_materials(:,1), model_materials{her,1}),1,'first');
        is_stable = strcmp(baseline_materials{ind_in_baseline,2}, model_materials{her,2});
        if is_stable
            continue
        else
            varying_material = model_materials{her,1};
            material_value = model_materials{her,2};
            break
        end %if
    end %for
    % The inputs of the current geometry before any simulation
    % parameter sweeps.
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if contains(mi.movie_flag, 'material_changes')
        modelling_inputs{model_num}.mov = 1;
    end %if
    modelling_inputs{model_num}.set_name = varying_material;
    modelling_inputs{model_num}.defs = defs{awh};
    modelling_inputs{model_num}.model_name = [...
        mi.base_model_name, '_', varying_material, '_sweep_value_', material_value];
    modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
    if exist(base_parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(base_parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for

%% Setting up simulation parameter sweeps
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
        if contains(mi.movie_flag, 'simulation_changes')
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

%% Now setup which fractional geometries to use
for uned = 2:length(mi.simulation_defs.geometry_fractions)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if contains(mi.movie_flag, 'geometry_fraction')
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

%% Now setup different port excitations to use
for unej = 2:length(mi.simulation_defs.wake.port_excitation)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if contains(mi.movie_flag, 'port_excitation')
        modelling_inputs{model_num}.mov = 1;
    end %if
    modelling_inputs{model_num}.port_excitation_wake.excitation_name = mi.simulation_defs.wake.port_excitation{unej}.excitation_name;
    modelling_inputs{model_num}.port_excitation_wake.port_names = mi.simulation_defs.wake.port_excitation{unej}.port_names;
    modelling_inputs{model_num}.port_excitation_wake.amplitude = mi.simulation_defs.wake.port_excitation{unej}.amplitude;
    modelling_inputs{model_num}.port_excitation_wake.phase = mi.simulation_defs.wake.port_excitation{unej}.phase;
    modelling_inputs{model_num}.port_excitation_wake.mode = mi.simulation_defs.wake.port_excitation{unej}.mode;
    modelling_inputs{model_num}.port_excitation_wake.frequency = mi.simulation_defs.wake.port_excitation{unej}.frequency;
    modelling_inputs{model_num}.port_excitation_wake.risetime = mi.simulation_defs.wake.port_excitation{unej}.risetime;
    modelling_inputs{model_num}.port_excitation_wake.bandwidth = mi.simulation_defs.wake.port_excitation{unej}.bandwidth;
    modelling_inputs{model_num}.port_excitation_wake.beam_offset_z = mi.simulation_defs.wake.port_excitation{unej}.beam_offset_z;
    temp = [...
        mi.base_model_name, '_', 'port_excitation', '_sweep_value_', ...
        mi.simulation_defs.wake.port_excitation{unej}.excitation_name];
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
%
% % Now setup different S-parameter settings to use
% for unpj = 2:length(mi.simulation_defs.s_param)
%     model_num = model_num +1;
%     modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
%     modelling_inputs{model_num}.mov = 0; %Default to no movie
%     if strcmpi(mi.movie_flag, 'All')
%         modelling_inputs{model_num}.mov = 1;
%     end %if
%      modelling_inputs{model_num}.s_param_excitation_f = mi.simulation_defs.s_param{unpj}.excitation_f;
%     modelling_inputs{model_num}.s_param_excitation_bw = mi.simulation_defs.s_param{unpj}.excitation_bw;
%     modelling_inputs{model_num}.s_param_excitation_amp = mi.simulation_defs.s_param{unpj}.excitation_amp;
%     modelling_inputs{model_num}.s_param_tmax = mi.simulation_defs.s_param{unpj}.tmax;
%
%     temp = [...
%         mi.base_model_name, '_', 's_param', '_sweep_value_', num2str(unpj)];
%     temp = regexprep(temp, '\.','p');
%     modelling_inputs{model_num}.model_name = temp;
%     modelling_inputs{model_num}.defs = defs{1};
%     modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
%         mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
%     if exist(base_parameter_file_path, 'file') == 2
%         modelling_inputs{model_num}.geometry_defs = ...
%             get_parameters_from_sidecar_file(base_parameter_file_path);
%     else
%         modelling_inputs{model_num}.geometry_defs = {};
%     end %if
% end %for
