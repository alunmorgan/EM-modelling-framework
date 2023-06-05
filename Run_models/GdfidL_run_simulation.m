function GdfidL_run_simulation(sim_type, paths, modelling_inputs, restart)
% Takes the geometry specification, adds the setup for a  simulation and
% runs the simulation with the desired calculational precision.
%
% Args:
%       sim_type (str): geometry, wake or s-parameter
%       paths (structure): Contains all the paths and file locations.
%       modelling_inputs (structure): Contains the setting for a specific modelling run.
%
% Example: GdifL_run_simulation('wake' paths, modelling_inputs, '')

% If the simulation type is S-parameter then you need a simulation for
% each excited port. For Shunt you need a simulation for each frequency.
% For the other types you just need a single simulation.
f_range = 1.3E9:5E7:1.9E9; % FIXME This needs to become a parameter
if strcmp(sim_type, 'sparameter')
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
    frequency = NaN;
elseif strcmp(sim_type, 'shunt')
    n_cycles = length(f_range);
    for hew = 1:n_cycles
        active_ports{hew} = 'NULL';
    end %for
    sparameter_set = NaN;
    frequency = num2str(f_range(nes));
else
    n_cycles = 1;
    active_ports = {'NULL'};
    sparameter_set = NaN;
    frequency = NaN;
end %if

for nes = 1:n_cycles
    restart_root = fullfile(paths.restart_files_path, modelling_inputs.base_model_name, modelling_inputs.model_name);
    scratch_root = fullfile(paths.scratch_loc, modelling_inputs.base_model_name, modelling_inputs.model_name);
    out_root = fullfile(paths.data_loc, modelling_inputs.base_model_name, modelling_inputs.model_name);
    out_loc = define_instance_path(out_root, sim_type, active_ports(nes), sparameter_set(nes), frequency);
    
    if ~exist(out_loc, 'dir')
        restart_loc = construct_storage_area_path(restart_root, sim_type, active_ports(nes), sparameter_set(nes), frequency);
        out_loc = construct_storage_area_path(out_root, sim_type, active_ports(nes), sparameter_set(nes), frequency);
        scratch_loc = construct_storage_area_path(scratch_root, sim_type, active_ports(nes), sparameter_set(nes), frequency);
        % Using soft links to truncate the file paths as this causes problems
        % with the underlying FORTRAN.
        current_out = fullfile(paths.data_loc, 'current_out');
        current_scratch = fullfile(paths.data_loc, 'current_scratch');
        current_restart = fullfile(paths.data_loc, 'current_restart');
        system(['ln -s ', out_loc, ' ' , current_out]);
        system(['ln -s ', scratch_loc, ' ', current_scratch]);
        system(['ln -s ', restart_loc, ' ', current_restart]);
        construct_gdf_file(paths, sim_type, modelling_inputs, current_out, current_scratch, current_restart, active_ports(nes), sparameter_set(nes), frequency)
        save(fullfile(out_loc,'run_inputs.mat'), 'paths', 'modelling_inputs')
        fprinf(['\nRunning ', sim_type,' simulation for ', modelling_inputs.model_name, '.'])
        GdfidL_simulation_core(current_out, modelling_inputs.version, modelling_inputs.precision, restart)
        % Converting any images from ps to png to reduce the file
        % size. For larger models keeping the ps files can break the
        % filesystem.
        pic_names = dir_list_gen(out_loc,'ps',1); % CHECK does this work now it is not a local folder?
        if ~isempty(pic_names)
            for ns = 1:length(pic_names)
                pic_nme = pic_names{ns}(1:end-3);
                [~] = system(['convert ',pic_nme,'.ps -rotate -90 ',pic_nme,'.png']);
                delete([pic_nme,'.ps'])
            end %for
        end %if
        system(['unlink ', current_out]);
        system(['unlink ', current_scratch]);
        system(['unlink ', current_restart]);
    else
        if strcmp(sim_type, 'sparameter')
            fprinf(strcat('\n', sim_type, ' data already exists (', active_ports(nes), ')'))
        else
            fprinf(strcat('\n', sim_type, ' data already exists '))
        end %if
    end %if
end %for
