function run_wake_simulation(paths, modelling_inputs, arch_date)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% arch_date (str) : 
% paths (structure) : Contains all the paths and file locations.
% modelling_inputs (structure): Contains the setting for a specific modelling run.
%
% Example: arch_date = run_wake_simulation(mi, modelling_inputs, arch_date)

% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.

% Move into the temporary folder.
old_loc = pwd;
tmp_location = move_into_tempororary_folder(paths.scratch_path);

temp_files('make')
construct_wake_gdf_file(paths.input_file_path, modelling_inputs)
if strcmp(modelling_inputs.precision, 'single')
    [status, ~] = system('single.gd1 < temp_data/model.gdf > temp_data/model_log');
elseif strcmp(modelling_inputs.precision, 'double')
    [status, ~] = system('gd1 < temp_data/model.gdf > temp_data/model_log');
end
if status ~= 0 
    disp('Look at model log')
end

% create the required output directories.
if ~exist(fullfile(paths.storage_path, modelling_inputs.model_name), 'dir')
    mkdir(paths.storage_path, modelling_inputs.model_name)
end
if ~exist(fullfile(paths.storage_path, modelling_inputs.model_name, arch_date),'dir')
    mkdir(fullfile(paths.storage_path, modelling_inputs.model_name), arch_date)
    mkdir(fullfile(paths.storage_path, modelling_inputs.model_name, arch_date), 'wake')
end

% Move the data to the storage area.
save(fullfile(paths.storage_path, modelling_inputs.model_name, arch_date,'wake', 'run_inputs.mat'), 'modelling_inputs')
movefile('temp_data/*', fullfile(paths.storage_path, modelling_inputs.model_name, arch_date, 'wake'));
copyfile(fullfile(paths.input_file_path, [modelling_inputs.model_name, '_model_data']), ...
    fullfile(paths.storage_path, modelling_inputs.model_name, arch_date, 'wake'));
temp_files('remove')
delete('SOLVER-LOGFILE');
delete('WHAT-GDFIDL-DID-SPIT-OUT');
cd(old_loc)
rmdir(tmp_location,'s');