function analyse_sparameter_data(postprocess_folder, output_folder)

[s_mat, sparameter_data.excitation_list, sparameter_data.reciever_list] = ...
    GdfidL_find_s_parameter_ouput(postprocess_folder);
[sparameter_data.scale,  sparameter_data.data] = read_s_param_datafiles(s_mat);

fprintf('Analysed ... Saving...')
save(fullfile(output_folder, 'data_analysed_sparameter.mat'), 'sparameter_data','-v7.3')
fprintf('Saved\n')
clear sparameter_data s_mat
