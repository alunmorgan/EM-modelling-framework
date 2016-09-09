
%% Modelling section.
%%%%%%%%%%%%%% Setting up paths %%%%%%%%%%%%%%%%%%

% Location of the temporary file space. Nothing is kept here.
%     mi.scratch_path = '/scratch/afdm76/';
% using the ram disk as the file system is too small for eigenmode simulation.
mi.scratch_path = '/dev/shm/';
% Location of the model input files.
mi.input_file_path = '/home/afdm76/Git/working/Gdfidl_input_files/';
% Location to store the data generated from the modelling run.
mi.storage_path = '/dls/science/groups/b01/Alun/EM_tests/data/';

mi.model_name = 'rectangular_pillbox_with_ceramic';

%%%%%%%%%%%% Settings for the model %%%%%%%%%%%%%%%%%%%

% Port multiple
% When using symetry planes some ports are not within the mesh and are thus not
% counted. The port multiple is a way of taking these "hidden" ports into
% account when it come to calculating the losses.

% Port fill factor
% in GdfidL if a port is cut by a symetry plane then only the section of the
% port within the mesh returns any signal. In order to get the signal for the
% full port one must divide by the fill factor.

% volume_fill_factor
% In order to get the total energy values correct you have to say what fraction
% of the structure was simulated.

% sigma
% the beam sigma (m)

% mesh stepsize (m)

% The wake length (m)

% mat list - a lookup table of materials to component names.

% extension names - Identifies the materials used for the pipe extensions.
% The losses from these will be combined witht he port losses rather than
% the structure losses.

% additional defs - parameters values to be passed in during gdf file
% creation. This is where sweeps can be set up.

% precision - calculation precision (double/ single).

% n_cores - number of cores to use.

% sim select - chooses which simulations to run
% (Wake/S-parameter/Eigenmode). Uses a string as input 'esw' will select
% all three.

% The list of materials used and the labels used to identify them.
rectangular_pillbox_mat_list = {'cav_mat','cavity';...
    'ceramic_mat','ceramic';...
    'bp_in', 'input beam pipe';...
    'bp_out', 'output beam pipe'};
%Additional defines. This allows lengths, materials and any other
%muneric settings to be set.
% Parameter sweeps can be set up here by passing a cell array of >1 value.
add_defs = {{'extension_length', {100e-3},'Length of the model extensions.'},...
    {'pipe_width', {40e-3},'Width of the beam pipe.'},...
    {'pipe_height', {20e-3},'Height of the beam pipe.'},...
    {'cav_length', {20e-3}, 'Length of the cavity.'},...
    {'cav_width', {50e-3}, 'Width of the cavity.'},...
    {'cav_height', {30e-3}, 'Height of the cavity.'},...
    {'cav_mat', {'steel316'}, 'Material the cavity is made of.'},...
    {'ceramic_mat', {'aluminium_oxide'}, 'Material for ceramic.'},...
    {'bp_in', {'steel316_2'}, 'Material for beam input pipe.'},...
    {'bp_out', {'steel316_3'}, 'Material for beam output pipe.'},...
    {'NPMLs', {40}, 'Number of perfectly matched layers used.'},...
    };

% %%%%%%%%%
mi.beam_sigma = '3E-3'; %in m
mi.mesh_stepsize = '5E-4'; %in m
mi.wakelength = '50';
mi.mat_list = rectangular_pillbox_mat_list;
mi.additional_defs = add_defs;
mi.precision = 'double';
% number of CPUs to use
mi.n_cores = 25;
mi.sim_select = 'w';
mi.beam = 'yes';

% %%%%%%%%%%%%%%%%%%%%%%%%%% Running the models %%%%%%%%%%%%%%%%%%%
% % Cycling through the different versions
start = now;
orig_ver = getenv('GDFIDL_VERSION');
% versions = {'150719g', '150923g', '151128g', '160410g','160429g, '160517g'};
versions = {'160517g'};
for kse = 1:length(versions)
    % setting the GdfidL version to test
    setenv('GDFIDL_VERSION',versions{kse});
    cur_ver = getenv('GDFIDL_VERSION');
     disp(['Testing version ', cur_ver])
    Gdfidl_run_models(mi);
end
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
fin = now;
%% Postprocessing section.
%%%%%%%%%%%%%% Setting up paths %%%%%%%%%%%%%%%%%%

% Location of the temporary file space. Nothing is kept here.
ppi.scratch_path = '/scratch/afdm76/';
% using the ram disk as the file system is too small for eigenmode simulation.
%     ppi.scratch_path = '/dev/shm/';
% Location to store the data generated from the modelling run.
ppi.storage_path = '/dls/science/groups/b01/Alun/EM_tests/data/';
% Location to store the output from the post processing.
ppi.output_path = '/dls/science/groups/b01/Alun/EM_tests/Results/';

ppi.model_name = 'rectangular_pillbox_with_ceramic';
%%%%%%%%%%%%%% set the highest frequency of interest. %%%%%%%%%%%%%%%%%
ppi.hfoi = 25E9;

%%%%%%%%%%%%%%%%%%% Set the report number %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ppi.rep_num = 'TDI-DIA-TS-???';

%%%%%%%%%%%%%%%%%%%%% What simluation types to post process. %%%%%%%%%%%
ppi.sim_select = 'w';
% if wake simulation and you want to investigate machine parameters these
% can be set here.
ppi.bt_length = [900, 686]; % number of bunches in train.
ppi.current = [0.08, 0.3, 0.5]; % A
ppi.rf_volts = [2.5, 3.3, 4.5]; % MV
ppi.RF_freq = 499.654E6; % Machine RF frequency (Hz).

%%%%%%%%%%%%%% If symetry planes are used. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ppi.port_multiple = [1,1];
ppi.port_fill_factor = [0.25,0.25];
ppi.volume_fill_factor =  0.25;

% Identifies port extensions so that the energy loss accounting is done
% correctly.
ppi.extension_names = {'input beam pipe', 'output beam pipe'};

%%%%%%%%%%%%%%%% Selecting the date range to process. %%%%%%%%%%%%%%%%
ppi.range = {start, fin};
%%%%%%%%%%%%%%%%%%%%%%%%% Postprocessing the models. %%%%%%%%%%%%%%%%
GdfidL_post_process_models(ppi);
%% Use the post processed data to generate a report.
arc_names = GdfidL_find_selected_models([ppi.output_path, ppi.model_name ], ppi.range);
for ks = 1:length(arc_names)
Generate_wake_report([ppi.output_path, ppi.model_name, '/',  arc_names{ks}],'Alun Morgan' )
end
%assemble_report([ppi.output_path, ppi.model_name ], ppi.range,  'Alun Morgan')
