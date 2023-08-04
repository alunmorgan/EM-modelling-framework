function postprocess_wakes(modelling_inputs, log, data_directory, pp_directory)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% ppi is a structure containing all the information required for the postprocessor
% modelling_inputs,log is
% wake_data is
%
%Example: wake_data = postprocess_wakes(ppi, modelling_inputs,log)

%% Write the wake post processing input file
GdfidL_write_pp_input_file(log, data_directory, pp_directory);

%% run the wake postprocessor
a=dir_list_gen_tree(pp_directory, '',1);
c = a(contains(a, 'wake_post_processing'));
pp_instances = fileparts(c);
for kwe = 1:length(pp_instances)
    temp = dir_list_gen(pp_instances{kwe}, '', 1);
    in_file_temp = temp(contains(temp, 'model_wake_post_processing'));
    postprocess_core(pp_instances{kwe}, modelling_inputs.version, 'wake', 0, 0, 'pp_input_file', in_file_temp{1});
end %for
fprintf('\n');
%% Extract the wake data
rename_port_files(pp_directory);
