function GdfidL_run_simulation(sim_type, paths, modelling_inputs, ow_behaviour, plots)
% Takes the geometry specification, adds the setup for a  simulation and
% runs the simulation with the desired calculational precision.
%
% Args:
%       sim_type (str): wake or s-parameter
%       paths (structure): Contains all the paths and file locations.
%       modelling_inputs (structure): Contains the setting for a specific modelling run.
%       ow_behaviour (string): optional. If set to 'no_skip' any existant data
%       will be moved to a folder called old data.
%       The default is for the simulation to be skipped.
%
% Example: GdifL_run_simulation('wake' paths, modelling_inputs, ow_behaviour, plots)

% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.

if strcmpi(sim_type, 'wake')
    sim_f_name = 'wake';
    sim_name = 'Wake';
elseif strcmpi(sim_type, 's-parameter') || strcmpi(sim_type, 's_parameter') ||...
        strcmpi(sim_type, 's-parameters') || strcmpi(sim_type, 's_parameters')
    sim_f_name = 's_parameters';
    sim_name = 'S-parameter';
elseif strcmpi(sim_type, 'eigenmode')
    sim_f_name = 'eigenmode';
    sim_name = 'Eigenmode';
elseif strcmpi(sim_type, 'lossy eigenmode')
    sim_f_name = 'lossy_eigenmode';
    sim_name = 'Lossy eigenmode';
elseif strcmpi(sim_type, 'shunt')
    sim_f_name = 'shunt';
    sim_name = 'Shunt';
end %if
skip = strcmp(ow_behaviour, 'no_skip');
% Create the required top leveloutput directories.
results_storage_location = fullfile(paths.storage_path, modelling_inputs.model_name);
run_sim = make_data_store(modelling_inputs.model_name, results_storage_location, sim_f_name, skip);
% if exist(fullfile(results_storage_location, sim_f_name),'dir')
%     if nargin ==4 && strcmp(ow_behaviour, 'no_skip')
%         old_store = ['old_data', datestr(now,30)];
%         mkdir(results_storage_location, old_store)
%         movefile(fullfile(results_storage_location, sim_f_name),...
%             fullfile(results_storage_location, old_store))
%         disp([sim_name,' data already exists for ',...
%             modelling_inputs.model_name, ...
%             '. However the overwrite flag is set so the simulation will be run anyway. Old data moved to ',...
%             fullfile(results_storage_location, old_store)])
%     else
%         disp(['Skipping ', modelling_inputs.model_name, '. ', sim_name,' data already exists'])
%         skip = 1;
%     end %if
% end %if

% if skip == 0
if run_sim == 1
    mkdir(results_storage_location, sim_f_name)
    % Move into the temporary folder.
    old_loc = pwd;
    tmp_location = move_into_tempororary_folder(paths.scratch_path);
    % If the simulation type is S-paramter then you need a simulation for
    % each excited port. For Shunt you need a simulation for each frequency.
    % For the other types you just need a single simulation.
    f_range = 1.3E9:5E7:1.9E9; % FIXME This needs to become a parameter
    if strcmp(sim_name, 'S-parameter')
        n_cycles = length(modelling_inputs.ports);
    elseif strcmp(sim_name, 'Shunt')
        n_cycles = length(f_range);
    else
        n_cycles = 1;
    end %if
    
    for nes = 1:n_cycles
        temp_files('make')
        
        %         modify_mesh_definition(paths.storage_path, 'temp_data', modelling_inputs.geometry_fraction)
        frequency = num2str(f_range(nes));
        port_name = modelling_inputs.ports{nes};
        arch_out = construct_storage_area_path(results_storage_location, sim_f_name, port_name, frequency);
        construct_gdf_file(paths, sim_name, modelling_inputs, port_name, frequency, plots)
        %         if strcmp(sim_name, 'S-parameter')
        %             port_name = modelling_inputs.ports{nes};
        %             construct_s_param_gdf_file(paths.input_file_path, paths.storage_path, modelling_inputs, port_name)
        %             % Create the required sub structure output directories.
        %             arch_out = fullfile(results_storage_location, sim_f_name,['port_',port_name, '_excitation']);
        %         elseif strcmp(sim_name, 'Wake')
        %             construct_wake_gdf_file(paths.path_to_models, modelling_inputs, plots)
        %             arch_out = fullfile(results_storage_location, sim_f_name);
        %         elseif strcmp(sim_name, 'Eigenmode')
        %             construct_eigenmode_gdf_file(path_to_model_file, modelling_inputs, 'no')
        %             arch_out = fullfile(results_storage_location, sim_f_name);
        %         elseif strcmp(sim_name, 'Lossy eigenmode')
        %             construct_eigenmode_gdf_file(path_to_model_file, modelling_inputs, 'yes')
        %             arch_out = fullfile(results_storage_location, sim_f_name);
        %         elseif strcmp(sim_name, 'Shunt')
        %             frequency = num2str(f_range(nes));
        %             construct_shunt_gdf_file(path_to_model_file, modelling_inputs, frequency)
        %             % Create the required sub structure output directories.
        %             arch_out = fullfile(results_storage_location, sim_f_name, frequency);
        %         end %if
        disp(['Running ', sim_name,' simulation for ', modelling_inputs.model_name, '.'])
        GdfidL_simulation_core(modelling_inputs.version, modelling_inputs.precision)
%         % setting the GdfidL version to test
%         orig_ver = getenv('GDFIDL_VERSION');
%         setenv('GDFIDL_VERSION',modelling_inputs.version);
%         if strcmp(modelling_inputs.precision, 'single')
%             [status, ~] = system('nice single.gd1 < temp_data/model.gdf > temp_data/model_log');
%         elseif strcmp(modelling_inputs.precision, 'double')
%             [status, cmd_output] = system('nice gd1 < temp_data/model.gdf > temp_data/model_log');
%         end %if
%         % restoring the original version.
%         setenv('GDFIDL_VERSION',orig_ver);
%         if status ~= 0
%             disp(['Look at model log', cmd_output])
%         end %if
        
        % Move the data to the storage area.
%         if ~exist(arch_out,'dir')
%             mkdir(arch_out)
%         end %if
        save(fullfile(results_storage_location, sim_f_name, 'run_inputs.mat'), 'paths', 'modelling_inputs')
        movefile('temp_data/*', arch_out);
        %         copyfile(path_to_model_file, arch_out);
        temp_files('remove')
%         if status == 0
%             delete('SOLVER-LOGFILE');
%             delete('WHAT-GDFIDL-DID-SPIT-OUT');
%         end %if
    end %for
    cd(old_loc)
    rmdir(tmp_location,'s');
end