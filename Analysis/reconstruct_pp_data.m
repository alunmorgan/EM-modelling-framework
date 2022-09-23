function reconstruct_pp_data(postprocess_folder, output_folder, ppi, number_of_wake_lengths_to_analyse)

% files = dir_list_gen_tree(fullfile(root_path, model_set), '', 1);
% wanted_files = files(contains(files, ['wake', filesep, 'data_analysed_wake.mat']));
% wanted_files = wanted_files(~contains(wanted_files, [filesep, 'old_data']));
% 
% 
% for ind = 1:length(wanted_files)
%     current_folder = fileparts(wanted_files{ind});
    if ~isfile(fullfile(output_folder, 'data_reconstructed_wake.mat'))
%         [a1,~,~]= fileparts(analysis_folder);
%         [~,name_of_model,~] = fileparts(a1);
%         disp(['Starting reconstruction <strong>', name_of_model, '</strong>'])
%         test = regexprep(current_folder, root_path, '');
%         test = regexp(test, filesep, 'split')';
%         wake_ind = find(cellfun(@isempty,(strfind(test, 'wake')))==0);
        run_logs = load(fullfile(postprocess_folder, 'data_from_run_logs.mat'), 'run_logs');
        run_logs = run_logs.run_logs;
        pp_logs = GdfidL_read_pp_wake_log(postprocess_folder);
        %         pp_logs = load(fullfile(current_folder, 'data_from_pp_logs.mat'), 'pp_logs');
        %         pp_logs = pp_logs.pp_logs;
        modelling_inputs = load(fullfile(postprocess_folder, 'run_inputs.mat'), 'modelling_inputs');
        modelling_inputs = modelling_inputs.modelling_inputs;
        
        output_file_locations = GdfidL_find_ouput(postprocess_folder);
        pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);
        
        %         pp_data = load(fullfile(current_folder, 'data_postprocessed.mat'), 'pp_data');
        %         pp_data = pp_data.pp_data;
        
        % Prepare for reconstruction
        pp_data_rearranged = rearrange_pp_data_structure(pp_data);
        % extracting the time domain info
        pp_reconstruction_data = pp_data_rearranged.time_series_data;
        % START HERE
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
        wake_lengths_to_analyse = wakelength;
        for ke = 2:number_of_wake_lengths_to_analyse
            wake_lengths_to_analyse = cat(1, wake_lengths_to_analyse, ke * wakelength/number_of_wake_lengths_to_analyse);
        end %for
        % putting everything on a common timebase
        timescale_common = pp_make_common_timebase(pp_reconstruction_data);
        pp_reconstruction_data = pp_apply_common_timebase(pp_reconstruction_data, timescale_common);
        
        wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_reconstruction_data, ppi, run_logs);
        %% Time domain analysis
        t_data = time_domain_analysis(pp_reconstruction_data, run_logs);
        %% Frequency domain analysis
        f_data = frequency_domain_analysis(t_data, run_logs, ppi.hfoi);
        
        %% Generating data for time slices
        time_slice_data = time_slices(t_data.timebase,t_data.wakepotential, ppi.hfoi);
        
        %% Calculating the losses for different bunch lengths
        bunch_length_sweep_data = variation_with_beam_sigma(ppi.bunch_lengths, t_data.timebase, ...
            f_data.Wake_Impedance_data, run_logs.charge);
        sigma_sweep = beam_sigma_sweep(t_data, f_data, run_logs.charge, run_logs.beam_sigma);

        %% and bunch charges.
        bunch_charge_sweep_data = loss_extrapolation(t_data, f_data, ppi);
        
        fprintf('Reconstructed ... Saving...')
        save(fullfile(output_folder, 'data_reconstructed_wake.mat'),...
            'wake_sweep_data', 'bunch_length_sweep_data', 'sigma_sweep', ...
            'bunch_charge_sweep_data', 'time_slice_data','-v7.3')
        fprintf('Saved\n')
        clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data' 'current_folder'
    else
        disp(['Reconstruction already exists... Skipping'])
    end %if
% end %for



