function run_wake_simulation(mi, modelling_inputs, arch_date)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% arch_date is
% mi is
% modelling_inputs is
%
% Example: arch_date = run_wake_simulation(mi, modelling_inputs, arch_date)

% Move into the temporary folder.
old_loc = pwd;
tmp_name = tempname;
tmp_name = tmp_name(6:12);
mkdir(mi.scratch_path,tmp_name)
cd([mi.scratch_path,tmp_name])
temp_files('make')
construct_wake_gdf_file(mi, modelling_inputs)
if strcmp(mi.precision, 'single')
    [~] = system('single.gd1 < temp_data/model.gdf > temp_data/model_log');
elseif strcmp(mi.precision, 'double')
    [~] = system('gd1 < temp_data/model.gdf > temp_data/model_log');
end

% Move the data to the storage area.
% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.

% create the required output directories.
if ~exist([mi.storage_path, mi.model_name], 'dir')
    mkdir(mi.storage_path, mi.model_name)
end
if ~exist([mi.storage_path, mi.model_name,'/',arch_date],'dir')
    mkdir([mi.storage_path, mi.model_name],arch_date)
    mkdir([mi.storage_path, mi.model_name,'/', arch_date], 'wake')
end
save([mi.storage_path, mi.model_name,'/', arch_date,'/wake/run_inputs.mat'], 'mi', 'modelling_inputs')
movefile('temp_data/*', [mi.storage_path, mi.model_name,'/',arch_date,'/wake/']);
copyfile([mi.input_file_path, mi.model_name, '_model_data'], [mi.storage_path, mi.model_name,'/',arch_date,'/wake/']);
temp_files('remove')
delete('SOLVER-LOGFILE');
delete('WHAT-GDFIDL-DID-SPIT-OUT');
cd(old_loc)
rmdir([mi.scratch_path, tmp_name],'s');