function Gdfidl_run_models_from_STL(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: varargout = Gdfidl_run_models_from_STL(mi)

if ispc ==1
    error('This needs to be run on the linux modelling machine')
end

model_num = 0;


%% Building up a set of inputs to be passed to the EM simulator.
[defs, ~] = construct_defs(mi.material_defs);
% The geometry variations are already defined,
for fdhs = 1:length(mi.model_names)
    model_num = model_num +1;
    modelling_inputs{model_num} = base_inputs(mi, mi.model_names{fdhs});
    if fdhs ~= mi.base_model_ind
        modelling_inputs{model_num}.set_name = regexprep(mi.model_names{fdhs}, ...
            [mi.base_model_name, '_(.*)?_value_.*'], '$1' );
    else
        modelling_inputs{model_num}.set_name ='Base';
    end %if
    modelling_inputs{model_num}.defs = defs{1};
    modelling_inputs{model_num}.geometry_defs = ...
        get_parameters_from_sidecar_file(...
        fullfile(mi.paths.input_file_path, mi.model_names{fdhs},...
        [mi.model_names{fdhs}, '_parameters.txt']));
    % Find the names of the ports used in the current model.
    modelling_inputs{model_num}.port_names = gdf_extract_port_names(...
        fullfile(mi.paths.storage_path, 'port_definition.txt'));
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
    modelling_inputs{model_num}.set_name = def{1};
    modelling_inputs{model_num}.defs = defs{awh};
    modelling_inputs{model_num}.model_name = [...
        mi.base_model_name, '_', def{1}, '_', def{2}];
    modelling_inputs{model_num}.geometry_defs = ...
        get_parameters_from_sidecar_file(...
        fullfile(mi.paths.input_file_path, mi.model_names{mi.base_model_ind},...
         [mi.model_names{mi.base_model_ind}, '_parameters.txt']));
end %for

% Then set up the simulation parameter scans off the the base model.
% Generally all the codes starts with the temp_inputs as a starting
% point and then modifies the specific variable of that sweep.
sim_param_sweeps = {'beam_sigma', 'mesh_stepsize', 'wakelength', ...
    'NPMLs', 'precision', 'version'};
for nw = 1:length(sim_param_sweeps)
    for mss = 2:length(mi.simulation_defs.(sim_param_sweeps{nw}))
        model_num = model_num +1;
        modelling_inputs{model_num} = base_inputs(mi, mi.model_names{mi.base_model_ind});
        modelling_inputs{model_num}.(sim_param_sweeps{nw}) = mi.simulation_defs.(sim_param_sweeps{nw}){mss};
        modelling_inputs{model_num}.model_name = [...
            mi.base_model_name, '_', sim_param_sweeps{nw}, '_', ...
            num2str(modelling_inputs(model_num).(sim_param_sweeps{nw}))];
        modelling_inputs{model_num}.defs = defs{1};
        modelling_inputs{model_num}.geometry_defs = ...
            get_parameters_from_sidecar_file(...
            fullfile(mi.paths.input_file_path, mi.model_names{mi.base_model_ind},...
             [mi.model_names{mi.base_model_ind}, '_parameters.txt']));
    end %for
end %for

% Running the different simulators for each model.
for awh = 1:length(modelling_inputs)
    % Making the directory to store the run data in.
    mkdir(fullfile(mi.paths.storage_path, modelling_inputs{awh}.model_name))
    % Create model_data file from STL file.
    create_model_data_file_for_STL(...
        mi.paths.input_file_path, mi.paths.storage_path,...
        modelling_inputs{awh}.base_model_name,...
        modelling_inputs{awh}.model_name)
    %FIXME
    ow_behaviour = '';
    % Write update to the command line
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'w'))
        try
            run_wake_simulation(mi.paths, modelling_inputs{awh}, ow_behaviour, 'STL');
        catch ERR
            display_modelling_error(ERR, 'wake')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 's'))
        try
            run_s_param_simulation(mi.paths, modelling_inputs{awh}, ow_behaviour, 'STL');
        catch ERR
            display_modelling_error(ERR, 'S-parameter')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'e'))
        try
            run_eigenmode_simulation(mi.paths, modelling_inputs{awh}, ow_behaviour, 'STL');
        catch ERR
            display_modelling_error(ERR, 'eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'l'))
        try
            run_eigenmode_lossy_simulation(mi.paths, modelling_inputs{awh}, ow_behaviour, 'STL');
        catch ERR
            display_modelling_error(ERR, 'lossy eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'r'))
        try
            run_shunt_simulation(mi.paths, modelling_inputs{awh}, ow_behaviour, 'STL');
        catch ERR
            display_modelling_error(ERR, 'shunt')
        end %try
    end %if
end %for
end % function

function base = base_inputs(mi, base_name)
% get the setting for the original base model.
base.mat_list = mi.mat_list;
base.n_cores  = mi.simulation_defs.n_cores;
base.sim_select = mi.simulation_defs.sim_select;
base.beam = mi.simulation_defs.beam;
base.volume_fill_factor = mi.simulation_defs.volume_fill_factor;
base.extension_names = mi.simulation_defs.extension_names;
base.base_model_name = base_name;
base.model_name = base_name;
% base.set_name = mi.model_set;
base.port_multiple = mi.simulation_defs.port_multiple;
base.port_fill_factor = mi.simulation_defs.port_fill_factor;
base.extension_names = mi.simulation_defs.extension_names;
base.version = mi.simulation_defs.version{1};
% base.defs = defs{1};
base.beam_sigma = mi.simulation_defs.beam_sigma{1};
base.mesh_stepsize = mi.simulation_defs.mesh_stepsize{1};
base.wakelength = mi.simulation_defs.wakelength{1};
base.NPMLs = mi.simulation_defs.NPMLs{1};
base.precision = mi.simulation_defs.precision{1};
if isfield(mi.simulation_defs, 's_param_ports')
    base.s_param_ports = mi.simulation_defs.s_param_ports;
    base.s_param_excitation_f = mi.simulation_defs.s_param_excitation_f;
    base.s_param_excitation_bw = mi.simulation_defs.s_param_excitation_bw;
    base.s_param_tmax = mi.simulation_defs.s_param_tmax;
end %if
end %function