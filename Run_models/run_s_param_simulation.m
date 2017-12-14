function run_s_param_simulation(paths, modelling_inputs, ow_behaviour, stl_flag)
% Takes the geometry specification, adds the setup for a wake simulation and
% runs a wake field simulation with the desired calculational precision.
%
% paths (structure) : Contains all the paths and file locations.
% modelling_inputs (structure): Contains the setting for a specific modelling run.
% ow_behaviour (string): optional. If set to 'no_skip' any existant data
% will be moved to a folder called old data. The default is for the simulation
% to be skipped.
%
% Example: run_s_param_simulation(paths, modelling_inputs)

% The code does not write directly to the storage area as often you want to
% have long term storage on a network drive, but during the modelling this
% will kill performance. So initially write to a local drive and then move
% it.
if nargin == 3 && ~strcmp(ow_behaviour, 'STL')
        stl_flag = '';
end %if
if nargin == 3 && strcmp(ow_behaviour, 'STL')
    stl_flag = 'STL';
end %if

skip = 0;
% Create the required top leveloutput directories.
results_storage_location = fullfile(paths.storage_path, modelling_inputs.model_name);
if exist(fullfile(results_storage_location, 's_parameters'),'dir')
    if nargin ==3 && strcmp(ow_behaviour, 'no_skip')
        old_store = ['old_data', datestr(now,30)];
        mkdir(results_storage_location, old_store)
        movefile(fullfile(results_storage_location, 's_parameters'),...
            fullfile(results_storage_location, old_store))
        disp(['S-parameter data already exists for ',...
            modelling_inputs.model_name, ...
            '. However the overwrite flag is set so the simulation will be run anyway. Old data moved to ',...
            fullfile(results_storage_location, old_store)])
    else
        disp(['Skipping ', modelling_inputs.model_name, '. S-parameter data already exists'])
        skip = 1;
    end %if
end %if

if skip == 0
    mkdir(results_storage_location, 's_parameters')
    % Move into the temporary folder.
    old_loc = pwd;
    tmp_location = move_into_tempororary_folder(paths.scratch_path);
    
    for nes = 1:length(modelling_inputs.s_param_ports)
        port_name = modelling_inputs.s_param_ports{nes};
        temp_files('make')
        if strcmp(stl_flag, 'STL')
            path_to_model_file = fullfile(paths.storage_path, ...
                modelling_inputs.model_name,...
                [modelling_inputs.model_name, '_model_data']);
        else
            path_to_model_file = fullfile(paths.input_file_path, ...
                [modelling_inputs.base_model_name, '_model_data']);
        end %if
        construct_s_param_gdf_file(path_to_model_file, modelling_inputs, port_name)
        disp(['Running S-parameter simulation for ', modelling_inputs.model_name, '.'])
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
        
        % Create the required sub structure output directories.
        arch_out = fullfile(results_storage_location,'s_parameters',['port_',port_name, '_excitation']);
        if ~exist(arch_out,'dir')
            mkdir(arch_out)
        end %if
        
        % Move the data to the storage area.
        save(fullfile(results_storage_location, 's_parameters', 'run_inputs.mat'), 'paths', 'modelling_inputs')
        movefile('temp_data/*', arch_out);
        copyfile(path_to_model_file, arch_out);
        temp_files('remove')
        delete('SOLVER-LOGFILE');
        delete('WHAT-GDFIDL-DID-SPIT-OUT');
    end %for
    cd(old_loc)
    rmdir(tmp_location,'s');
end