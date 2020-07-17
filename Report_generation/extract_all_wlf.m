function [extracted_data] = extract_all_wlf(root_path, model_sets)


for sts = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{sts}), 'mat', 1);
    wanted_files = files(contains(files, 'data_analysed_wake.mat'));
    if isempty(wanted_files)
        disp(['No analysed files found for ',model_sets{sts},', please run analyse_pp_data.'])
        continue
    else
        disp(['Getting wake loss factors for ',model_sets{sts}])
    end %if
    split_str = regexp(wanted_files, ['\',filesep], 'split');
    for ind = 1:length(wanted_files)
        current_folder = fileparts(wanted_files{ind});
        load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
        load(fullfile(current_folder, 'data_analysed_wake'),'wake_sweep_data');
        load(fullfile(current_folder, 'run_inputs'), 'modelling_inputs');
        load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
        extracted_data.model_names{sts,ind} = split_str{ind}{end - 2};
        extracted_data.wlf(sts,ind) = wake_sweep_data.time_domain_data{end}.wake_loss_factor;
        extracted_data.wake_length(sts,ind) = wake_sweep_data.raw{1, 1}.wake_setup.Wake_length;
        extracted_data.mesh_density(sts, ind) = modelling_inputs.mesh_stepsize;
        extracted_data.mesh_scaling(sts, ind) = modelling_inputs.mesh_density_scaling;
        extracted_data.n_cores(sts, ind) = str2num(modelling_inputs.n_cores);
        extracted_data.simulation_time(sts, ind) = run_logs.wall_time;
        extracted_data.number_of_cells(sts, ind) = run_logs.Ncells;
        extracted_data.timestep(sts, ind) = run_logs.Timestep;
        extracted_data.memory_usage(sts, ind) = run_logs.memory;
        extracted_data.beam_sigma(sts, ind) = run_logs.beam_sigma;
        extracted_data.fractional_loss_beam_ports(sts, ind) = wake_sweep_data.frequency_domain_data{end}.fractional_loss_beam_ports;
        extracted_data.fractional_loss_signal_ports(sts, ind) = wake_sweep_data.frequency_domain_data{end}.fractional_loss_signal_ports;
        extracted_data.fractional_loss_structure(sts, ind) = wake_sweep_data.frequency_domain_data{end}.fractional_loss_structure;
        port_energy = wake_sweep_data.time_domain_data{end}.port_data.port_energy;
        total_energy = wake_sweep_data.time_domain_data{end}.loss_from_beam;
        extracted_data.beam_port_loss(sts, ind) = (port_energy(1) + port_energy(2)) / total_energy;
        extracted_data.signal_port_loss(sts, ind) = sum(port_energy(3:end)) / total_energy;
        extracted_data.structure_loss(sts, ind) = (total_energy - sum(port_energy(1:end))) / total_energy;
        clear pp_data wake_sweep_data run_logs modelling_inputs
    end %for
end %for