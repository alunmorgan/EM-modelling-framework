function postprocess_wakes(modelling_inputs, log)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% ppi is a structure containing all the information required for the postprocessor
% modelling_inputs,log is
% wake_data is
%
%Example: wake_data = postprocess_wakes(ppi, modelling_inputs,log)

%% Write the wake post processing input file
GdfidL_write_pp_input_file(log);
% for folder_ind = 1:10
% GdfidL_write_wake_pp_input_file_E_field_history(1 + (folder_ind-1)*3000);
% end %for

%% run the wake postprocessor
a=dir_list_gen_tree(fullfile('pp_link', 'wake'), '',1);
c = a(contains(a, 'wake_post_processing'));
for kwe = 1:length(c)
    postprocess_core(fileparts(c{kwe}), modelling_inputs.version, 'wake', 0, 0, 'pp_input_file', c{kwe});
end %for
%% Extract the wake data
rename_port_files(fullfile('pp_link', 'wake'));
% % FIXME move the following two line into analysis so that separation between the
% % data folder and the analysis folder is clear.
% output_file_locations = GdfidL_find_ouput(wake_output_directory);
% data = extract_wake_data_from_pp_output_files(output_file_locations, log, modelling_inputs, tstart);


