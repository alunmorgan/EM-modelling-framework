function Testing_simple_buttons(input_file_loc, scratch_loc,...
    data_loc)
% input_file_loc is the location of the model input files.
% scratch_loc is the location of the temporary file space. Nothing is kept here.
% data_loc is the location to store the data generated from the modelling run.
%
% Example: Testing_cylindrical_pillbox_with_4ports(input_file_loc, scratch_loc, data_loc, results_loc)

%% Adding locations to the data structure.
% Location of the temporary file space. Nothing is kept here.
run_inputs.paths.scratch_path = scratch_loc;
% Location of the model input files.
run_inputs.paths.input_file_path = input_file_loc ;
% Location to store the data generated from the modelling run.
run_inputs.paths.storage_path = data_loc;
% The model set to associate each model to.
run_inputs.model_set = {'simple_buttons', 'simple_buttons', 'simple_buttons'};

%% Adding list of model names to run.
run_inputs.model_names = {'simple_buttons_Base',...
    'simple_buttons_button_radius_sweep_value_0p002',...
    'simple_buttons_button_radius_sweep_value_0p0025'};
for sen = 1:length(run_inputs.model_names)
create_model_data_file_for_STL(fullfile(run_inputs.paths.input_file_path, ...
    run_inputs.model_set{sen}, run_inputs.model_names{sen}))
end %for
%% Material parameters for the model geometry
% A lookup table of materials to component names
run_inputs.mat_list = {...
    'beampipe_mat', 'beam pipe';...
    'block_mat', 'button block';...
    'button_mat', 'button';...
    'ceramic_mat', 'button ceramic';...
    'pin_mat', 'pin';...
    'shell_mat', 'button outer shell'};

% Material parameters sweeps can be defined here by 
% passing a cell array of >1 value.
run_inputs.material_defs = {...
    {'beampipe_mat', {'steel316'}, 'Material the beam pipe is made of.'},...
    {'block_mat', {'steel316_2'}, 'Material for the button block.'},...
    {'button_mat', {'steel316_3'}, 'Material for the button.'},...
    {'ceramic_mat', {'aluminium_oxide'}, 'Material for the button ceramic.'},...
    {'pin_mat', {'molybdenum'}, 'Material for the pin.'},...
    {'shell_mat', {'steel304'}, 'Material for the button outer shell.'},...
    };

%% This is where geometry sweeps can be set up.
% Parameter sweeps can be set up here by passing a cell array of >1 value.
for whfw = 1:length(run_inputs.model_set)
run_inputs.geometry_defs{whfw} = get_parameters_from_sidecar_file(...
    fullfile(run_inputs.paths.input_file_path, ...
    run_inputs.model_set{whfw},...
    run_inputs.model_names{whfw},...
    'simple_buttons_parameters.txt'));
end %for

%% This is for setting up the simulation parameters.
run_inputs.simulation_defs.versions = {'170509g'};
run_inputs.simulation_defs.beam_sigma = {'5E-3'}; %in m
run_inputs.simulation_defs.mesh_stepsize = {'750E-6'}; %in m
run_inputs.simulation_defs.wakelength = {'300'};
%Number of perfectly matched layers used.
run_inputs.simulation_defs.NPMLs = {'40'};
% calculation precision (double/ single).
run_inputs.simulation_defs.precision = {'double'};
% number of cores to use
run_inputs.simulation_defs.n_cores = '25';
% sim select - chooses which simulations to run
% (Wake/S-parameter/Eigenmode). Uses a string as input 'esw' will select
% all three.
run_inputs.simulation_defs.sim_select = 'ws';
% specifies if there is an electron beam passing throug the structure.
% if there is it is assumed to be passing between ports 1 and 2.
run_inputs.simulation_defs.beam = 'yes';
% Specifies the ports which the sparameter simulation will excite
% sequentially. (useful if symetry mean that not all ports need to be
% tried).
run_inputs.simulation_defs.s_param_ports = {'signal_1','signal_2','signal_3','signal_4'};
% Describes the S parameter port excitation.
% There needs to be very little power at 0Hz as this gives a DC component
% which is undesirable.
run_inputs.simulation_defs.s_param_excitation_f = 2.500E9;
run_inputs.simulation_defs.s_param_excitation_bw = 5E9;
% Determines the length of time the S parameter monitor is run for.
run_inputs.simulation_defs.s_param_tmax = 80E-9;
% When using symetry planes some ports are not within the mesh and are thus not
% counted. The port multiple is a way of taking these "hidden" ports into
% account when it come to calculating the losses.
run_inputs.simulation_defs.port_multiple = [1,1,1,1,1,1];
% in GdfidL if a port is cut by a symetry plane then only the section of the
% port within the mesh returns any signal. In order to get the signal for the
% full port one must divide by the fill factor.
run_inputs.simulation_defs.port_fill_factor = [1,1,1,1,1,1];
% In order to get the total energy values correct you have to say what fraction
% of the structure was simulated.
run_inputs.simulation_defs.volume_fill_factor =  1;
% Identifies port extensions so that the energy loss accounting is done
% correctly.The losses from these will be combined witht he port losses rather than
% the structure losses.
run_inputs.simulation_defs.extension_names = {'beampipe'};

% %%%%%%%%%%%%%%%%%%%%%%%%%% Running the models %%%%%%%%%%%%%%%%%%%
Gdfidl_run_models(run_inputs, 'STL');
