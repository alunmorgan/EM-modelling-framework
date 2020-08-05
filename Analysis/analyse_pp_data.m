function analyse_pp_data(root_path, model_sets, ppi, port_modes_override, ...
    analysis_override)

if nargin <5
    analysis_override = 0;
end %if

for sts = 1:length(model_sets)
    files = dir_list_gen_tree(fullfile(root_path, model_sets{sts}), 'mat', 1);
    wanted_files = files(contains(files, ['wake', filesep, 'data_postprocessed.mat']));
    
    for ind = 1:length(wanted_files)
        current_folder = fileparts(wanted_files{ind});
        if ~isfile(fullfile(current_folder, 'data_analysed_wake.mat')) || analysis_override == 1
            disp(['Starting analysis ', current_folder])
            test = regexprep(current_folder, root_path, '');
            test = regexp(test, filesep, 'split')';
            wake_ind = find(cellfun(@isempty,(strfind(test, 'wake')))==0);
            model_variant = regexprep(test{wake_ind -1}, [model_sets{sts}, '_'],'');
            %             port_truncation_ind = find(contains(port_truncation_all(:,1), model_variant));
            %             if isempty(port_truncation_ind)
            %                 %variant not found just use Base.
            %                 port_truncation_ind = find(contains(port_truncation_all(:,1), 'Base'));
            %                 disp('Bespoke port signal truncation not found for this variant... defaulting to Base.')
            %             end %if
            %             port_truncation = port_truncation_all{port_truncation_ind, 2};
            pp_data = load(fullfile(current_folder, 'data_postprocessed'), 'pp_data');
            pp_data = pp_data.pp_data;
            run_logs = load(fullfile(current_folder, 'data_from_run_logs.mat'), 'run_logs');
            run_logs = run_logs.run_logs;
            modelling_inputs = load(fullfile(current_folder, 'run_inputs.mat'), 'modelling_inputs');
            modelling_inputs = modelling_inputs.modelling_inputs;
            wakelength = str2double(modelling_inputs.wakelength);
            %             wake_lengths_to_analyse = [];
            %             for ke = 1:6
            %                 wake_lengths_to_analyse = cat(1, wake_lengths_to_analyse, wakelength);
            %                 wakelength = wakelength ./2;
            %             end %for
            wake_lengths_to_analyse = wakelength;
            % truncation of begining of port signals.
            for dlw = 1:length(pp_data.port.data)
                for shf = 1:size(pp_data.port.data{dlw}, 2)
                    [cut_inds(shf)]= separate_bunch_from_remenent_field(...
                        pp_data.port.timebase, pp_data.port.data{dlw}(:,shf), modelling_inputs.beam_sigma , 4);
                end %for
                % The earliest one shoudl be due to the bunch. 
                cut_ind = min(cut_inds);
                pp_data.port.bunch_signal{dlw} = pp_data.port.data{dlw};
                if size(pp_data.port.data{dlw}, 1) > cut_ind
                    pp_data.port.data{dlw}(1:cut_ind, :) = 0;
                    pp_data.port.bunch_signal{dlw}(cut_ind + 1:end, :) = 0;
                else
                    pp_data.port.data{dlw}(:, :) = 0;
                end %if
                [~,I] = max(abs(pp_data.port.bunch_signal{dlw}), [], 1);
                for hxf = 1:length(I)
                    pp_data.port.bunch_amplitude{dlw}(hxf) = pp_data.port.bunch_signal{dlw}(I(hxf), hxf);
                end %for  
            end %for
            wake_sweep_data = wake_sweep(wake_lengths_to_analyse, pp_data, ppi, run_logs, port_modes_override);
            disp('Analysed ... Saving...')
            save(fullfile(current_folder, 'data_analysed_wake.mat'), 'wake_sweep_data','-v7.3')
            disp('Saved')
            clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data' 'current_folder'
        else
            disp(['Analysis for ', current_folder, ' already exists... Skipping'])
        end %if
    end %for
end %for



