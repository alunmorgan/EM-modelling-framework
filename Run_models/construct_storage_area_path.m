function arch_out = construct_storage_area_path(results_storage_location, sim_f_name, port_name_in, sparameter_set, frequency)

arch_out = define_instance_path(results_storage_location, sim_f_name, port_name_in, sparameter_set, frequency);

% construct output folder structure.
if ~exist(arch_out,'dir')
    mkdir(arch_out)
end %if