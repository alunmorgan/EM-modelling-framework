function run_wake_simulation(paths, modelling_inputs, ow_behaviour, stl_flag)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% paths (structure) : Contains all the paths and file locations.
% modelling_inputs (structure): Contains the setting for a specific modelling run.
% ow_behaviour (string): optional. If set to 'no_skip' any existant data
% will be moved to a folder called old data. The default is for the simulation
% to be skipped.
%
% Example: run_wake_simulation(mi, modelling_inputs, 'no_skip')

% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.
% if nargin == 3 && ~strcmp(ow_behaviour, 'STL')
%     stl_flag = '';
% end %if
% if nargin == 3 && strcmp(ow_behaviour, 'STL')
%     stl_flag = 'STL';
% end %if

% skip = 0;
% create the required output directories, and move any existing data out of
% the way.
skip = strcmp(ow_behaviour, 'no_skip');
results_storage_location = fullfile(paths.storage_path, modelling_inputs.model_name);
run_sim = make_data_store(results_storage_location, 'wake', skip);

if run_sim == 1
    mkdir(results_storage_location, 'wake')
    % Move into the temporary folder.
    old_loc = pwd;
    tmp_location = move_into_tempororary_folder(paths.scratch_path);
    
    temp_files('make')
    
    if strcmp(stl_flag, 'STL')
        path_to_model = fullfile(paths.storage_path, ...
            modelling_inputs.model_name,...
            [modelling_inputs.model_name, '_model_data']);
    else
        path_to_model = fullfile(paths.input_file_path, ...
            [modelling_inputs.base_model_name, '_model_data']);
    end %if
    construct_wake_gdf_file(path_to_model, modelling_inputs)
    disp(['Running wake simulation for ', modelling_inputs.model_name, '.'])
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
    
    % Move the data to the storage area.
    save(fullfile(results_storage_location, 'wake', 'run_inputs.mat'), 'modelling_inputs')
    movefile('temp_data/*', fullfile(results_storage_location, 'wake'));
    copyfile(path_to_model, ...
        fullfile(results_storage_location, 'wake'));
    temp_files('remove')
    delete('SOLVER-LOGFILE');
    delete('WHAT-GDFIDL-DID-SPIT-OUT');
    cd(old_loc)
    rmdir(tmp_location,'s');
end %if