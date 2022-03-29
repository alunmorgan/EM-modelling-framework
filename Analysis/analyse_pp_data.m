function analyse_pp_data(root_path, model_sets, ppi)

for sts = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{sts}), 'mat', 1);
    wanted_files = files(contains(files, ['wake', filesep, 'data_postprocessed.mat']));
    
    for ind = 1:length(wanted_files)
        current_folder = fileparts(wanted_files{ind});
        if ~isfile(fullfile(current_folder, 'data_analysed_wake.mat'))
            [a1,~,~]= fileparts(current_folder);
            [~,name_of_model,~] = fileparts(a1);
            disp(['Starting analysis <strong>', name_of_model, '</strong>'])
            test = regexprep(current_folder, root_path, '');
            test = regexp(test, filesep, 'split')';
            wake_ind = find(cellfun(@isempty,(strfind(test, 'wake')))==0);
%             pp_data = load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
%             pp_data = pp_data.pp_data;
            run_logs = load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
            run_logs = run_logs.run_logs;
            pp_logs = load(fullfile(current_folder, 'data_from_pp_logs.mat'), 'pp_logs');
            pp_logs = pp_logs.pp_logs;
            modelling_inputs = load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
            modelling_inputs = modelling_inputs.modelling_inputs;
            
            % FIXME move the following two line into analysis so that separation between the
            % data folder and the analysis folder is clear.
            output_file_locations = GdfidL_find_ouput(current_folder);
            pp_data = extract_wake_data_from_pp_output_files(output_file_locations, run_logs, modelling_inputs);
            
            pp_data.port.data = port_data_fill_factor_scaling(pp_data.port.data, modelling_inputs.port_fill_factor);
            pp_data.port.data = port_data_remove_non_transmitting(pp_data.port.data, run_logs);
            pp_data.port.data.time = port_data_separate_remnant(pp_data.port.data.time, pp_data.port.timebase, modelling_inputs.beam_sigma);
            % Replicate the port signals as required. Dont run if only beam
            % ports are present.
            if length(pp_data.port.labels) > 2
                if isfield(pp_logs, 'start_times')
                    % if they are not in the log then they have not been used.
                    start_times = pp_logs.start_times;
                else
                    start_times = num2cell(zeros(length(pp_data.port.t_start),2));
                end %if
                [pp_data.port.labels, ...
                    pp_data.port.data, pp_data.port.t_start] = duplicate_ports(...
                    modelling_inputs.port_multiple, pp_data.port.labels, ...
                    pp_data.port.data,  start_times);
            end %if
            %             wake_lengths_to_analyse = [];
            %             for ke = 1:6
            %                 wake_lengths_to_analyse = cat(1, wake_lengths_to_analyse, wakelength);
            %                 wakelength = wakelength ./2;
            %             end %for
            wakelength = str2double(modelling_inputs.wakelength);
            wake_lengths_to_analyse = wakelength;
           
            wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_data, ppi, run_logs);
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
end %for



