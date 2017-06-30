function Testing_cylindrical_pillbox_with_4ports(input_file_loc, scratch_loc,...
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

%% Adding list of model names to run.
run_inputs.model_names = {'cylindrical_pillbox_with_4ports'};

%% Material parameters for the model geometry
% A lookup table of materials to component names
run_inputs.mat_list = {'cav_mat','cavity';...
    'bp_in', 'input beam pipe';...
    'bp_out', 'output beam pipe'};

% Material parameters sweeps can be defined here by 
% passing a cell array of >1 value.
run_inputs.material_defs = {...
    {'cav_mat', {'steel316'}, 'Material the cavity is made of.'},...
    {'bp_in', {'steel316_2'}, 'Material for beam input pipe.'},...
    {'bp_out', {'steel316_3'}, 'Material for beam output pipe.'},...
    };

%% This is where geometry sweeps can be set up.
% Parameter sweeps can be set up here by passing a cell array of >1 value.
run_inputs.geometry_defs = {{'extension_length', {100e-3},'Length of the model extensions.'},...
    {'pipe_rad', {10e-3},'Radius of the beam pipe.'},...
    {'cav_length', {42e-3}, 'Length of the cavity.'},...
    {'cav_rad', {65.1e-3}, 'Radius of the cavity.'},...
    };

%% This is for setting up the simulation parameters.
run_inputs.simulation_defs.versions = {'161207g', '160210g','160410g','160429g','160517g','161003g','161108g', '170509g'};%{'161003g'};
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
run_inputs.simulation_defs.s_param_ports = {'port_signal_out1','port_signal_out2','port_signal_out3','port_signal_out4'};
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
run_inputs.simulation_defs.extension_names = {'input beam pipe', 'output beam pipe'};

% %%%%%%%%%%%%%%%%%%%%%%%%%% Running the models %%%%%%%%%%%%%%%%%%%
Gdfidl_run_models(run_inputs);
