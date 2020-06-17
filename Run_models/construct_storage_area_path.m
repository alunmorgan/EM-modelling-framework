function arch_out = construct_storage_area_path(results_storage_location, sim_f_name, port_name_in, frequency)
% Constructs the output path for the final storage of the simulation
% results. The details of this depend on the simulation type.
% if the folder does not exist it is made.
if iscell(port_name_in) == 0
    port_name = port_name_in;
elseif length(port_name_in) >1
    port_name = '';
    for kfn = 1:length(port_name_in)
        port_name = cat(2, port_name, port_name_in{kfn});
    end %for
end %if

if strcmp(sim_f_name, 's_parameter')
    % Create the required sub structure output directories.
    arch_out = fullfile(results_storage_location, sim_f_name,['port_',port_name, '_excitation']);
    elseif strcmp(sim_f_name, 'shunt')
    % Create the required sub structure output directories.
    arch_out = fullfile(results_storage_location, sim_f_name, frequency);
else
    arch_out = fullfile(results_storage_location, sim_f_name);
end %if

% construct output folder structure.
if ~exist(arch_out,'dir')
    mkdir(arch_out)
end %if