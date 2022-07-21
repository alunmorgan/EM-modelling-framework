function modelling_inputs = run_inputs_setup_STL(mi, versions, n_cores, precision)
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

%% Base model and geometry sweeps
for fdhs = 1:length(mi.model_names)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{fdhs}, versions, n_cores, precision);
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if any(contains(mi.movie_flag, 'base'))
        modelling_inputs{model_num}.mov = 1;
    end %if
    modelling_inputs{model_num}.sweep_type = 'Geometry';
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
    modelling_inputs{model_num}.parameter_file_path = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name,mi.model_names{fdhs},...
        [mi.model_names{fdhs}, '_parameters.txt']);
    
    if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for
geometry_models_last_ind = model_num;
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
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind}, versions, n_cores, precision);
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if any(contains(mi.movie_flag, 'material_changes'))
        modelling_inputs{model_num}.mov = 1;
    end %if
    modelling_inputs{model_num}.sweep_type = 'Material';
    modelling_inputs{model_num}.set_name = varying_material;
    modelling_inputs{model_num}.defs = defs{awh};
    modelling_inputs{model_num}.model_name = [...
        mi.base_model_name, '_Base_', varying_material, '_sweep_value_', material_value];
    modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
    if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for

%% Setting up simulation parameter sweeps
% Then set up the simulation parameter scans off the the base model.
% Generally all the codes starts with the temp_inputs as a starting
% point and then modifies the specific variable of that sweep.
sim_param_sweeps = {'beam_sigma', ...
    'mesh_stepsize', 'mesh_density_scaling', 'wakelength', ...
    'NPMLs'};
for nw = 1:length(sim_param_sweeps)
    for mss = 2:length(mi.simulation_defs.(sim_param_sweeps{nw}))
        model_num = model_num +1;
        modelling_inputs{model_num} = modelling_inputs{1}; % copy geometry model
        modelling_inputs{model_num}.mov = 0; %Default to no movie
        if any(contains(mi.movie_flag, 'simulation_changes'))
            modelling_inputs{model_num}.mov = 1;
        end %if
        modelling_inputs{model_num}.sweep_type = 'Simulation';
        modelling_inputs{model_num}.(sim_param_sweeps{nw}) = mi.simulation_defs.(sim_param_sweeps{nw}){mss};
        modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
            mi.base_model_name, modelling_inputs{model_num}.model_name, 'ascii');
        modelling_inputs{model_num}.model_name = [...
            modelling_inputs{model_num}.model_name, '_', sim_param_sweeps{nw}, '_sweep_value_', ...
            regexprep(num2str(modelling_inputs{model_num}.(sim_param_sweeps{nw})), '\.','p')];
        modelling_inputs{model_num}.defs = defs{1};
        if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
            modelling_inputs{model_num}.geometry_defs = ...
                get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
        else
            modelling_inputs{model_num}.geometry_defs = {};
        end %if
    end %for
end %for

%% Setting up beam offset sweeps
% Then set up the simulation parameter scans off the the base model.
% Generally all the codes starts with the temp_inputs as a starting
% point and then modifies the specific variable of that sweep.
beam_offset_sweeps = {'beam_offset_x', 'beam_offset_y'};
for awh = 1:geometry_models_last_ind
    for nw = 1:length(beam_offset_sweeps)
        for mss = 2:length(mi.simulation_defs.(beam_offset_sweeps{nw}))
            model_num = model_num +1;
            modelling_inputs{model_num} = modelling_inputs{awh}; % copy geometry model
            modelling_inputs{model_num}.mov = 0; %Default to no movie
            if any(contains(mi.movie_flag, 'simulation_changes'))
                modelling_inputs{model_num}.mov = 1;
            end %if
            modelling_inputs{model_num}.sweep_type = 'BeamOffset';
            modelling_inputs{model_num}.(beam_offset_sweeps{nw}) = mi.simulation_defs.(beam_offset_sweeps{nw}){mss};
            modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
                mi.base_model_name, modelling_inputs{model_num}.model_name, 'ascii');
            modelling_inputs{model_num}.model_name = [...
                modelling_inputs{model_num}.model_name, '_', beam_offset_sweeps{nw}, '_sweep_value_', ...
                regexprep(num2str(modelling_inputs{model_num}.(beam_offset_sweeps{nw})), '\.','p')];
            modelling_inputs{model_num}.defs = defs{1};
            if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
                modelling_inputs{model_num}.geometry_defs = ...
                    get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
            else
                modelling_inputs{model_num}.geometry_defs = {};
            end %if
        end %for
    end %for
end %for

%% Setting up simulator parameter sweeps
% Then set up the simulation parameter scans off the the base model.
% Generally all the codes starts with the temp_inputs as a starting
% point and then modifies the specific variable of that sweep.
sim_param_sweeps = {'version','precision', 'n_cores'};
for nw = 1:length(sim_param_sweeps)
    if strcmp(sim_param_sweeps{nw}, 'version')
        sweep_length = length(versions);
    elseif strcmp(sim_param_sweeps{nw}, 'precision')
        sweep_length = length(precision);
    elseif strcmp(sim_param_sweeps{nw}, 'n_cores')
        sweep_length = length(n_cores);
    end %if
    for mss = 2:sweep_length
        model_num = model_num +1;
        modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind}, versions, n_cores, precision);
        modelling_inputs{model_num}.mov = 0; %Default to no movie
        if any(contains(mi.movie_flag, 'simulation_changes'))
            modelling_inputs{model_num}.mov = 1;
        end %if
        modelling_inputs{model_num}.sweep_type = 'Simulator';
        if strcmp(sim_param_sweeps{nw}, 'version')
            modelling_inputs{model_num}.(sim_param_sweeps{nw}) = versions{mss};
        elseif strcmp(sim_param_sweeps{nw}, 'precision')
            modelling_inputs{model_num}.(sim_param_sweeps{nw}) = precision{mss};
        elseif strcmp(sim_param_sweeps{nw}, 'n_cores')
            modelling_inputs{model_num}.(sim_param_sweeps{nw}) = n_cores{mss};
        end %if
        modelling_inputs{model_num}.model_name = [...
            mi.base_model_name, '_Base_', sim_param_sweeps{nw}, '_sweep_value_', ...
            regexprep(num2str(modelling_inputs{model_num}.(sim_param_sweeps{nw})), '\.','p')];
        modelling_inputs{model_num}.defs = defs{1};
        modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
            mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
        if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
            modelling_inputs{model_num}.geometry_defs = ...
                get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
        else
            modelling_inputs{model_num}.geometry_defs = {};
        end %if
    end %for
end %for

%% Now setup which fractional geometries to use
for uned = 2:length(mi.simulation_defs.geometry_fractions)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind}, versions, n_cores, precision);
    modelling_inputs{model_num}.mov = 0; %Default to no movie
    if any(contains(mi.movie_flag, 'geometry_fraction'))
        modelling_inputs{model_num}.mov = 1;
    end %if
    modelling_inputs{model_num}.sweep_type = 'GeometryFraction';
    tne = find(mi.simulation_defs.volume_fill_factor == mi.simulation_defs.geometry_fractions(uned));
    modelling_inputs{model_num}.geometry_fraction = mi.simulation_defs.geometry_fractions(uned);
    modelling_inputs{model_num}.port_fill_factor = mi.simulation_defs.port_fill_factor{tne};
    modelling_inputs{model_num}.port_multiple = mi.simulation_defs.port_multiple{tne};
    modelling_inputs{model_num}.volume_fill_factor = mi.simulation_defs.volume_fill_factor(tne);
    modelling_inputs{model_num}.ports = mi.simulation_defs.ports(1:end-tne +1);
    modelling_inputs{model_num}.port_location = mi.simulation_defs.port_location(1:end-tne +1);
    modelling_inputs{model_num}.port_modes = mi.simulation_defs.port_modes(1:end-tne +1);
    temp = [...
        mi.base_model_name, '_Base_', 'Geometry_fraction', '_sweep_value_', ...
        num2str(mi.simulation_defs.geometry_fractions(uned))];
    temp = regexprep(temp, '\.','p');
    modelling_inputs{model_num}.model_name = temp;
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
        mi.base_model_name, [mi.base_model_name, '_Base'], 'ascii');
    if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
    else
        modelling_inputs{model_num}.geometry_defs = {};
    end %if
end %for

%% Now setup different port excitations to use
for awh = 1:geometry_models_last_ind
    for unej = 2:length(mi.simulation_defs.wake.port_excitation)
        model_num = model_num +1;
        modelling_inputs{model_num} = modelling_inputs{awh}; % Copy geometry model
        modelling_inputs{model_num}.mov = 0; %Default to no movie
        if any(contains(mi.movie_flag, 'port_excitation'))
            modelling_inputs{model_num}.mov = 1;
            modelling_inputs{model_num}.field_capture.stop_time = mi.simulation_defs.wake.port_excitation{unej}.field_capture.stop_time;
        end %if
        modelling_inputs{model_num}.sweep_type = 'PortExcitation';
        modelling_inputs{model_num}.port_excitation_wake = mi.simulation_defs.wake.port_excitation{unej};
        modelling_inputs{model_num}.stl_location = fullfile(mi.paths.path_to_models, ...
            mi.base_model_name, modelling_inputs{model_num}.model_name, 'ascii');
        temp = [...
            modelling_inputs{model_num}.model_name, '_', 'port_excitation', '_sweep_value_', ...
            mi.simulation_defs.wake.port_excitation{unej}.excitation_name];
        temp = regexprep(temp, '\.','p');
        modelling_inputs{model_num}.model_name = temp;
        modelling_inputs{model_num}.defs = defs{1};
        if exist(modelling_inputs{model_num}.parameter_file_path, 'file') == 2
            modelling_inputs{model_num}.geometry_defs = ...
                get_parameters_from_sidecar_file(modelling_inputs{model_num}.parameter_file_path);
        else
            modelling_inputs{model_num}.geometry_defs = {};
        end %if
    end %for
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
