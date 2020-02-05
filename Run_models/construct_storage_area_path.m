function arch_out = construct_storage_area_path(results_storage_location, sim_f_name, port_name, frequency)
% Constructs the output path for the final storage of the simulation
% results. The details of this depend on the simulation type.
% if the folder does not exist it is made.


if strcmp(sim_name, 'S-parameter')
    % Create the required sub structure output directories.
    arch_out = fullfile(results_storage_location, sim_f_name,['port_',port_name, '_excitation']);
elseif strcmp(sim_name, 'Wake')
    arch_out = fullfile(results_storage_location, sim_f_name);
elseif strcmp(sim_name, 'Eigenmode')
    arch_out = fullfile(results_storage_location, sim_f_name);
elseif strcmp(sim_name, 'Lossy eigenmode')
    arch_out = fullfile(results_storage_location, sim_f_name);
elseif strcmp(sim_name, 'Shunt')
    % Create the required sub structure output directories.
    arch_out = fullfile(results_storage_location, sim_f_name, frequency);
end %if

% construct output folder structure.
if ~exist(arch_out,'dir')
    mkdir(arch_out)
end %if