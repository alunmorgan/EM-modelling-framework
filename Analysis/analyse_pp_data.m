function analyse_pp_data(root_path, model_set, ppi, number_of_wake_lengths_to_analyse)

files = dir_list_gen_tree(fullfile(root_path, model_set), 'mat', 1);
wanted_files = files(contains(files, ['wake', filesep, 'data_from_pp_logs.mat']));

for ind = 1:length(wanted_files)
    current_folder = fileparts(wanted_files{ind});
    if ~isfile(fullfile(current_folder, 'data_analysed_wake.mat'))
        [a1,~,~]= fileparts(current_folder);
        [~,name_of_model,~] = fileparts(a1);
        disp(['Starting analysis <strong>', name_of_model, '</strong>'])
        test = regexprep(current_folder, root_path, '');
        test = regexp(test, filesep, 'split')';
        wake_ind = find(cellfun(@isempty,(strfind(test, 'wake')))==0);
        run_logs = load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
        run_logs = run_logs.run_logs;
        pp_logs = load(fullfile(current_folder, 'data_from_pp_logs.mat'), 'pp_logs');
        pp_logs = pp_logs.pp_logs;
        modelling_inputs = load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
        modelling_inputs = modelling_inputs.modelling_inputs;
        
        output_file_locations = GdfidL_find_ouput(current_folder);
        pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);   
        pp_data.port.data = port_data_fill_factor_scaling(pp_data.port.data, modelling_inputs.port_fill_factor);
        %separating time domain, frequency domain and material losses.
        save(fullfile(current_folder, 'data_postprocessed.mat'), 'pp_data','-v7.3')
        % Prepare for reconstruction
        pp_data = rearrange_pp_data_structure(pp_data);
        % extracting the time domain info
        pp_reconstruction_data = pp_data.time_series_data;
        pp_reconstruction_data.port_data = port_data_remove_non_transmitting(pp_reconstruction_data.port_data, run_logs);
        pp_reconstruction_data.port_data = port_data_separate_remnant(pp_reconstruction_data.port_data,...
            pp_reconstruction_data.port_timebase,modelling_inputs.beam_sigma);
        % Replicate the port signals as required. Dont run if only beam
        % ports are present.
        if length(pp_reconstruction_data.port_labels) > 2
            if isfield(pp_logs, 'start_times')
                % if they are not in the log then they have not been used.
                start_times = pp_logs.start_times;
            else
                start_times = num2cell(zeros(length(pp_data.port.t_start),2));
            end %if
            [pp_reconstruction_data.port_labels, ...
                pp_reconstruction_data.port_data, pp_reconstruction_data.port_t_start] = duplicate_ports(...
                modelling_inputs.port_multiple, pp_reconstruction_data.port_labels, ...
                pp_reconstruction_data.port_data,  start_times);
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
        fprintf('Analysed ... Saving...')
        save(fullfile(current_folder, 'data_analysed_wake.mat'), 'wake_sweep_data','-v7.3')
        fprintf('Saved\n')
        clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data' 'current_folder'
    else
        [a,b,~] = fileparts(current_folder);
        [~,c,~] = fileparts(a);
        disp(['Analysis for ', c, ' already exists... Skipping'])
    end %if
end %for



