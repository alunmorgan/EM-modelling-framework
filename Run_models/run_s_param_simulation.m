function run_s_param_simulation(paths, modelling_inputs)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% paths (structure) : Contains all the paths and file locations.
% modelling_inputs (structure): Contains the setting for a specific modelling run.
%
% Example: run_s_param_simulation(mi, modelling_inputs)

% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.

% Move into the temporary folder.
old_loc = pwd;
tmp_location = move_into_tempororary_folder(paths.scratch_path);

for nes = 1:length(modelling_inputs.s_param_ports)
    port_name = modelling_inputs.s_param_ports{nes};
    temp_files('make')
    construct_s_param_gdf_file(paths.input_file_path, modelling_inputs, port_name)
    % setting the GdfidL version to test
    orig_ver = getenv('GDFIDL_VERSION');
    setenv('GDFIDL_VERSION',modelling_inputs.version);
    if strcmp(modelling_inputs.precision, 'single')
        [status, ~] = system('single.gd1 < temp_data/model.gdf > temp_data/model_log');
    elseif strcmp(modelling_inputs.precision, 'double')
        [status, ~] = system('gd1 < temp_data/model.gdf > temp_data/model_log');
    end %if
    % restoring the original version.
    setenv('GDFIDL_VERSION',orig_ver);
    if status ~= 0
        disp('Look at model log')
    end %if
    
    % Create the required output directories.
    if ~exist(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 's_parameters'),'dir')
        mkdir(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name), 's_parameters')
    end
    arch_out = fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name,'s_parameters',['port_',port_name, '_excitation']);
    if ~exist(arch_out,'dir')
        mkdir(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 's_parameters'), ['port_',port_name, '_excitation'])
    end %if
    
    % Move the data to the storage area.
    save(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 's_parameters', 'run_inputs.mat'), 'paths', 'modelling_inputs')
    movefile('temp_data/*', arch_out);
    copyfile(fullfile(paths.input_file_path, [modelling_inputs.base_model_name, '_model_data']), arch_out);
    temp_files('remove')
    delete('SOLVER-LOGFILE');
    delete('WHAT-GDFIDL-DID-SPIT-OUT');
end %for
cd(old_loc)
rmdir(tmp_location,'s');