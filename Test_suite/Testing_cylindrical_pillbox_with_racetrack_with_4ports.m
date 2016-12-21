function Testing_cylindrical_pillbox_with_racetrack_with_4ports(input_file_loc, scratch_loc,...
    data_loc, version)
% input_file_loc is the location of the model input files.
% scratch_loc is the location of the temporary file space. Nothing is kept here.
% data_loc is the location to store the data generated from the modelling run.
% results_loc is the location to store the output from the post processing.
%
% Example:  Testing_cylindrical_pillbox_with_racetrack_with_4ports(input_file_loc, scratch_loc, data_loc, results_loc)

%% Modelling section.

%% Input paramters for the model geometry
% A lookup table of materials to component names
% The list of materials used and the labels used to identify them.
mat_list = {'cav_mat','cavity';...
    'bp_in', 'input beam pipe';...
    'bp_out', 'output beam pipe'};

% additional defs - parameters values to be passed in during gdf file
% creation. This is where sweeps can be set up.
% This allows lengths, materials and any other numeric settings to be set.
% Parameter sweeps can be set up here by passing a cell array of >1 value.
additional_defs = {{'extension_length', {100e-3},'Length of the model extensions.'},...
    {'cav_length', {42e-3}, 'Length of the cavity.'},...
    {'cav_rad', {65.1e-3}, 'Radius of the cavity.'},...
    {'bp_minor', {10e-3}, 'Beam pipe minor radius.'},...
    {'bp_major', {36e-3}, 'Beam pipe major radius.'},...
    {'cav_mat', {'steel316'}, 'Material the cavity is made of.'},...
    {'bp_in', {'steel316_2'}, 'Material for beam input pipe.'},...
    {'bp_out', {'steel316_3'}, 'Material for beam output pipe.'},...
    {'NPMLs', {40}, 'Number of perfectly matched layers used.'},...
    };

%%%%%%%%%%%%%% Setting up paths %%%%%%%%%%%%%%%%%%

% Location of the temporary file space. Nothing is kept here.
run_inputs.scratch_path = scratch_loc;
% Location of the model input files.
run_inputs.input_file_path = input_file_loc ;
% Location to store the data generated from the modelling run.
run_inputs.storage_path = data_loc;

run_inputs.model_name = 'cylindrical_pillbox_with_racetrack_with_4ports';
run_inputs.beam_sigma = '5E-3'; %in m
run_inputs.mesh_stepsize = '750E-6'; %in m
run_inputs.wakelength = '2';
run_inputs.mat_list = mat_list;
run_inputs.additional_defs = additional_defs;

% calculation precision (double/ single).
run_inputs.precision = 'double';

% number of cores to use
run_inputs.n_cores = 25;

% sim select - chooses which simulations to run
% (Wake/S-parameter/Eigenmode). Uses a string as input 'esw' will select
% all three.
run_inputs.sim_select = 'w';

% specifies if there is an electron beam passing throug the structure.
% if there is it is assumed to be passing between ports 1 and 2.
run_inputs.beam = 'yes';

% Specifies the ports which the sparameter simulation will excite
% sequentially. (useful if symetry mean that not all ports need to be
% tried).
run_inputs.s_param_ports = {'port_signal_out1','port_signal_out2','port_signal_out3','port_signal_out4'};

% Describes the S parameter port excitation.
% There needs to be very little power at 0Hz as this gives a DC component
% which is undesirable.
run_inputs.s_param_excitation_f = 2.500E9;
run_inputs.s_param_excitation_bw = 5E9;

% Determines the length of time the S parameter monitor is run for.
run_inputs.s_param_tmax = 80E-9;


%%%%%%%%%%%%%% If symetry planes are used. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% When using symetry planes some ports are not within the mesh and are thus not
% counted. The port multiple is a way of taking these "hidden" ports into
% account when it come to calculating the losses.
run_inputs.port_multiple = [1,1,1,1,1,1];

% in GdfidL if a port is cut by a symetry plane then only the section of the
% port within the mesh returns any signal. In order to get the signal for the
% full port one must divide by the fill factor.
run_inputs.port_fill_factor = [1,1,1,1,1,1];

% In order to get the total energy values correct you have to say what fraction
% of the structure was simulated.
run_inputs.volume_fill_factor =  1;

% Identifies port extensions so that the energy loss accounting is done
% correctly.The losses from these will be combined witht he port losses rather than
% the structure losses.
run_inputs.extension_names = {'input beam pipe', 'output beam pipe'};


% %%%%%%%%%%%%%%%%%%%%%%%%%% Running the models %%%%%%%%%%%%%%%%%%%
orig_ver = getenv('GDFIDL_VERSION');
% setting the GdfidL version to test
setenv('GDFIDL_VERSION',version);
cur_ver = getenv('GDFIDL_VERSION');
disp(['Testing version ', cur_ver])
Gdfidl_run_models(run_inputs);

% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);