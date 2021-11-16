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
    for ind = 1:length(wanted_files) % for each model in set.
        current_folder = fileparts(wanted_files{ind});
        %         load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
        load(fullfile(current_folder, 'data_analysed_wake'),'wake_sweep_data');
        load(fullfile(current_folder, 'run_inputs'), 'modelling_inputs');
        load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
        if strcmp(modelling_inputs.model_name(end-4:end), '_Base')
            extracted_data{sts}.basename = modelling_inputs.base_model_name;
            for nwd = 1:length(modelling_inputs.geometry_defs)
                extracted_data{sts}.geometry_values.(modelling_inputs.geometry_defs{nwd}{1}) =...
                    modelling_inputs.geometry_defs{nwd}{2}{1};
            end %for
        end %if
        extracted_data{sts}.model_names{ind} = split_str{ind}{end - 2};
        extracted_data{sts}.wlf(ind) = wake_sweep_data.time_domain_data{end}.wake_loss_factor;
        extracted_data{sts}.wake_length(ind) = str2double(modelling_inputs.wakelength);
        extracted_data{sts}.mesh_density(ind) = modelling_inputs.mesh_stepsize;
        extracted_data{sts}.mesh_scaling(ind) = modelling_inputs.mesh_density_scaling;
        extracted_data{sts}.n_cores(ind) = str2double(modelling_inputs.n_cores);
        extracted_data{sts}.Geometry_fraction(ind) = modelling_inputs.geometry_fraction;
        extracted_data{sts}.version(ind) = str2double(modelling_inputs.version);
        extracted_data{sts}.simulation_time(ind) = run_logs.wall_time;
        extracted_data{sts}.number_of_cells(ind) = run_logs.Ncells;
        extracted_data{sts}.timestep(ind) = run_logs.Timestep;
        extracted_data{sts}.memory_usage(ind) = run_logs.memory;
        extracted_data{sts}.beam_sigma(ind) = run_logs.beam_sigma;
        extracted_data{sts}.fractional_loss_beam_ports(ind) = sum(wake_sweep_data.time_domain_data{end}.port_data.power_port_mode.remnant_only.port_energy(1:2))/wake_sweep_data.time_domain_data{end}.loss_from_beam;
        if length(wake_sweep_data.time_domain_data{end}.port_data.power_port_mode.remnant_only.port_energy) > 2
            extracted_data{sts}.fractional_loss_signal_ports(ind) = sum(wake_sweep_data.time_domain_data{end}.port_data.power_port_mode.remnant_only.port_energy(3:end))/wake_sweep_data.time_domain_data{end}.loss_from_beam;
        else
            extracted_data{sts}.fractional_loss_signal_ports(ind) = 0;
        end %if
        extracted_data{sts}.fractional_loss_structure(ind) = 1- extracted_data{sts}.fractional_loss_beam_ports(ind) - extracted_data{sts}.fractional_loss_signal_ports(ind);
            port_energy = wake_sweep_data.time_domain_data{end}.port_data.power_port_mode.remnant_only.port_energy;

        total_energy = wake_sweep_data.time_domain_data{end}.loss_from_beam;
        extracted_data{sts}.beam_port_loss(ind) = (port_energy(1) + port_energy(2)) / total_energy;
        extracted_data{sts}.signal_port_loss(ind) = sum(port_energy(3:end)) / total_energy;
        extracted_data{sts}.structure_loss(ind) = (total_energy - sum(port_energy(1:end))) / total_energy;
        all_bunch_signals = wake_sweep_data.time_domain_data{1, 1}.port_data.power_port_mode.remnant_only.port_mode_signals;
        for hwhs = 1:size(all_bunch_signals,1) %ports
            [extracted_data{sts}.port{ind}.dominant_signal_amplitude(hwhs), extracted_data{sts}.port{ind}.dominant_mode(hwhs)] = max(sum(all_bunch_signals(hwhs,:,:),3),[], 2);
        end %for
        extracted_data{sts}.port{ind}.labels = wake_sweep_data.time_domain_data{1, 1}.port_lables;
        for jd = 1:size(run_logs.mat_losses.single_mat_data,1)
            extracted_data{sts}.material_loss{ind}.(regexprep(run_logs.mat_losses.single_mat_data{jd,2},' ', '_')) = ...
                run_logs.mat_losses.single_mat_data{jd,4}(end,2);
        end
        extracted_data{sts}.material_loss{ind}.total_loss = run_logs.mat_losses.total_loss(end);
        clear pp_data wake_sweep_data run_logs modelling_inputs all_bunch_signals
    end %for
end %for