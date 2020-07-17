function raw_data = postprocess_wakes(modelling_inputs, log)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% ppi is a structure containing all the information required for the postprocessor
% modelling_inputs,log is
% wake_data is
%
%Example: wake_data = postprocess_wakes(ppi, modelling_inputs,log)

%% Write the wake post processing input file
transverse_quadrupole_wake_offset = '1E-3';
tstart = GdfidL_write_pp_input_file(log, transverse_quadrupole_wake_offset, str2double(modelling_inputs.version(1:6)));


%% run the wake postprocessor
wake_output_directory = fullfile('pp_link', 'wake');
postprocess_core(wake_output_directory, modelling_inputs.version, 'wake', 0, 0);
%% Extract the wake data
output_file_locations = GdfidL_find_ouput(wake_output_directory);
raw_data = extract_wake_data_from_pp_output_files(output_file_locations, log, modelling_inputs, tstart);
% raw_data.port.t_start = tstart;

