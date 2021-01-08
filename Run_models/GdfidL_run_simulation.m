function output_data_location = GdfidL_run_simulation(sim_type, paths, modelling_inputs, ow_behaviour)
% Takes the geometry specification, adds the setup for a  simulation and
% runs the simulation with the desired calculational precision.
%
% Args:
%       sim_type (str): geometry, wake or s-parameter
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

% 'geometry', 'wake', 's_parameters', 'eigenmode', 'lossy_eigenmode', 'shunt'

skip = strcmp(ow_behaviour, 'skip');
% Create the required top level output directories.
results_storage_location = fullfile(paths.storage_path, modelling_inputs.model_name);
run_sim = make_data_store(modelling_inputs.model_name, results_storage_location, sim_type, skip);

if run_sim == 1
    % If the simulation type is S-paramter then you need a simulation for
    % each excited port. For Shunt you need a simulation for each frequency.
    % For the other types you just need a single simulation.
    f_range = 1.3E9:5E7:1.9E9; % FIXME This needs to become a parameter
    if strcmp(sim_type, 's_parameter')
        active_port_inds = find(modelling_inputs.port_multiple ~= 0);
        if strcmp(modelling_inputs.beam, 'yes')
            active_port_inds = active_port_inds(3:end); % removing the beam ports from the list.
        end %if
        if isempty(active_port_inds)
            warning('no active ports found. Have you correctly set the presence of beam?')
        end %if
        active_ports = modelling_inputs.ports(active_port_inds);
        s_sets = length(modelling_inputs.s_param);
        n_cycles = length(active_ports) * s_sets;
        sparameter_set = repmat(1:s_sets, length(active_ports),1);
        sparameter_set = sparameter_set(:);
        active_ports = repmat(active_ports, 1, s_sets);
    elseif strcmp(sim_type, 'shunt')
        n_cycles = length(f_range);
        for hew = 1:n_cycles
            active_ports{hew} = 'NULL';
        end %for
        sparameter_set = NaN;
    else
        n_cycles = 1;
        active_ports = {'NULL'};
        sparameter_set = NaN;
    end %if
    
    output_data_location = cell(1,n_cycles);
    for nes = 1:n_cycles
        [old_loc, tmp_location] = move_into_tempororary_folder(paths.scratch_path);
        temp_files('make')
        if strcmp(sim_type, 'shunt')
        frequency = num2str(f_range(nes));
        else
            frequency = NaN;
        end %if
        arch_out = construct_storage_area_path(results_storage_location, sim_type, active_ports{nes}, sparameter_set(nes), frequency);
        construct_gdf_file(sim_type, modelling_inputs, active_ports(nes), sparameter_set(nes), frequency)
        disp(['Running ', sim_type,' simulation for ', modelling_inputs.model_name, '.'])
        GdfidL_simulation_core(modelling_inputs.version, modelling_inputs.precision)
        save(fullfile('temp_data', 'run_inputs.mat'), 'paths', 'modelling_inputs')
        if strcmp(sim_type, 'geometry')
            % Converting the images from ps to eps via png to reduce the file
            % size. For larger models keeping the ps files can break the
            % filesystem.
            [pic_names ,~]= dir_list_gen('.','ps',1);
            for ns = 1:length(pic_names)
                pic_nme = pic_names{ns}(1:end-3);
                [~] = system(['convert ',pic_nme,'.ps ',pic_nme,'.png']);
                [~] = system(['convert ',pic_nme,'.png ',pic_nme,'.eps']);
                delete([pic_nme,'.ps'])
            end
        end %if
        [status, message] = movefile('temp_data/*', arch_out);
        if status == 1
            temp_files('remove')
            output_data_location{1, nes} = arch_out;
            fileID = fopen(fullfile(arch_out, 'simulation_complete.txt'),'w');
            fclose(fileID);
            cd(old_loc)
            rmdir(tmp_location, 's')
        elseif status == 0
            disp(['Error in file transfer - data left in ', tmp_location])
            disp(message)
            output_data_location{1, nes} = tmp_location;
            cd(old_loc)
        end %if
    end %for
else
    output_data_location = {NaN};
end %if