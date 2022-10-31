function reconstruct_pp_data(postprocess_folder, output_folder, ppi, number_of_wake_lengths_to_analyse)


if ~isfile(fullfile(output_folder, 'data_reconstructed_wake.mat'))
    
    run_logs = load(fullfile(postprocess_folder, 'data_from_run_logs.mat'), 'run_logs');
    run_logs = run_logs.run_logs;
    pp_logs = GdfidL_read_pp_wake_log(postprocess_folder);
    modelling_inputs = load(fullfile(postprocess_folder, 'run_inputs.mat'), 'modelling_inputs');
    modelling_inputs = modelling_inputs.modelling_inputs;
    
    output_file_locations = GdfidL_find_ouput(postprocess_folder);
    pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);
    
    % Prepare for reconstruction
    pp_data_rearranged = rearrange_pp_data_structure(pp_data);
    % extracting the time domain info
    pp_reconstruction_data = pp_data_rearranged.time_series_data;
    pp_reconstruction_data.port_data = port_data_remove_non_transmitting(pp_reconstruction_data.port_data, run_logs);
    pp_reconstruction_data.port_data = port_data_separate_remnant(pp_reconstruction_data.port_data,...
        pp_reconstruction_data.port_timebase,modelling_inputs.beam_sigma);
    % Replicate the port signals as required. Dont run if only beam
    % ports are present.
    if length(pp_reconstruction_data.port_labels) > 2
        if isfield(pp_logs, 'start_times')
            % if they are not in the log then they have not been used.
            pp_reconstruction_data.port_t_start = pp_logs.start_times;
        else
            pp_reconstruction_data.port_t_start = num2cell(zeros(length(pp_reconstruction_data.port_labels),2));
        end %if
        pp_reconstruction_data = duplicate_ports(modelling_inputs.port_multiple, pp_reconstruction_data);
    end %if
    wakelength = str2double(modelling_inputs.wakelength);
    wake_lengths_to_analyse = [];
    for ke = 1:number_of_wake_lengths_to_analyse
        wake_lengths_to_analyse = cat(1, wake_lengths_to_analyse, ke * wakelength/number_of_wake_lengths_to_analyse);
    end %for
    % putting everything on a common timebase
    timescale_common = pp_make_common_timebase(pp_reconstruction_data);
    pp_reconstruction_data = pp_apply_common_timebase(pp_reconstruction_data, timescale_common);
    
    wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_reconstruction_data, run_logs);
    %% Single bunch
    % Time domain analysis
    t_data = time_domain_analysis(pp_reconstruction_data, run_logs);
    % Frequency domain analysis
    n_bunches_in_input_pattern = 1;
    f_data = frequency_domain_analysis(t_data, run_logs.charge, n_bunches_in_input_pattern);
    % Generating data for time slices
    time_slice_data = time_slices(t_data.timebase,t_data.wakepotential, ppi.hfoi);
    
    %% Calculating the losses for different bunch lengths
    bunch_length_sweep_data = variation_with_beam_sigma(ppi.bunch_lengths, t_data.timebase, ...
        f_data.Wake_Impedance_data, run_logs.charge);
%     %% Calculating the losses for different beam sigmas
%     sigma_sweep = beam_sigma_sweep(t_data, f_data, run_logs.charge, run_logs.beam_sigma);
    
    %% and bunch charges.
    bunch_charge_sweep_data = loss_extrapolation(t_data, run_logs, ppi);
    
    fprintf('Reconstructed ... Saving...')
    save(fullfile(output_folder, 'data_reconstructed_wake.mat'),...
        'wake_sweep_data', 'bunch_length_sweep_data', 't_data', 'f_data',...
        'bunch_charge_sweep_data', 'time_slice_data','-v7.3')
    fprintf('Saved\n')
    clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data' 'current_folder'
else
    disp('Reconstruction already exists... Skipping')
end %if



