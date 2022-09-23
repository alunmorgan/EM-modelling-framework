function analyse_sparameter_data(postprocess_folder, output_folder)

% files = dir_list_gen_tree(fullfile(root_path, model_set), '', 1);
% wanted_files = files(~contains(files, [filesep,'old_data']));
% wanted_files = wanted_files(contains(wanted_files, [filesep,'sparameter', filesep]));
% sets = unique(fileparts(fileparts(fileparts(wanted_files))));
% disp(['Starting S parameter analysis <strong>', model_set, '</strong>'])
% for kaw = 1:length(sets)
%     [~, sparameter_data.set] = fileparts(sets{kaw});
%     disp(sparameter_data.set)
    [s_mat, sparameter_data.excitation_list, sparameter_data.reciever_list] = ...
        GdfidL_find_s_parameter_ouput(postprocess_folder);
    [sparameter_data.scale,  sparameter_data.data] = read_s_param_datafiles(s_mat);
    
    fprintf('Analysed ... Saving...')
    save(fullfile(output_folder, 'data_analysed_sparameter.mat'), 'sparameter_data','-v7.3')
    fprintf('Saved\n')
    clear sparameter_data s_mat
% end %for




%         clear 'pp_data' 'run_logs' 'modelling_inputs' 'wake_sweep_data' 'current_folder'
%     else
%         [a,~,~] = fileparts(current_folder);
%         [~,c,~] = fileparts(a);
%         disp(['Analysis for ', c, ' already exists... Skipping'])
%     end %if
% end %for
%
%
%
