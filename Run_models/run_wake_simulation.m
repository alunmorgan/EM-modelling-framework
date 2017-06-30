function run_wake_simulation(paths, modelling_inputs)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% paths (structure) : Contains all the paths and file locations.
% modelling_inputs (structure): Contains the setting for a specific modelling run.
%
% Example: run_wake_simulation(mi, modelling_inputs)

% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.

% Move into the temporary folder.
old_loc = pwd;
tmp_location = move_into_tempororary_folder(paths.scratch_path);

temp_files('make')
construct_wake_gdf_file(paths.input_file_path, modelling_inputs)
% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',modelling_inputs.version);
if strcmp(modelling_inputs.precision, 'single')
    [status, ~] = system('single.gd1 < temp_data/model.gdf > temp_data/model_log');
elseif strcmp(modelling_inputs.precision, 'double')
    [status, ~] = system('gd1 < temp_data/model.gdf > temp_data/model_log');
end
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
if status ~= 0
    disp('Look at model log')
end

% create the required output directories.
if ~exist(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 'wake'),'dir')
    mkdir(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name), 'wake')
end

% Move the data to the storage area.
save(fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 'wake', 'run_inputs.mat'), 'modelling_inputs')
movefile('temp_data/*', fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 'wake'));
copyfile(fullfile(paths.input_file_path, [modelling_inputs.base_model_name, '_model_data']), ...
    fullfile(paths.storage_path, modelling_inputs.base_model_name, modelling_inputs.model_name, 'wake'));
temp_files('remove')
delete('SOLVER-LOGFILE');
delete('WHAT-GDFIDL-DID-SPIT-OUT');
cd(old_loc)
rmdir(tmp_location,'s');