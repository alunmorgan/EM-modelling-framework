function eigenmode_data = postprocess_eigenmode(modelling_inputs, pp_settings, run_log, pp_type, data_directory, pp_directory)
% Runs the GdfidL postprocessor on the selected data.
%
%Example: eigenmode_data = postprocess_eigenmode(modelling_inputs, pp_settings, run_log, pp_type, data_directory, pp_directory)

%% Write the wake post processing input file
GdfidL_write_pp_eigenmode_input_file(data_directory, pp_directory, run_log, pp_type, pp_settings)

%% run the wake postprocessor
% postprocess_core(pp_directory, modelling_inputs.version, pp_type, 0, 0);

%% Extract parameters from the log.
eigenmode_data = GdfidL_read_eigenmode_log(fullfile(data_directory, 'model_log'), pp_type);
log = GdfidL_read_eigenmode_postprocessing_log(fullfile(pp_directory, ['model_',pp_type,'_post_processing.gd1pp_log']));
if isfield(log, 'qs')
eigenmode_data.qs = log.qs;
end
if isfield(log, 'rqs')
eigenmode_data.rqs = log.rqs;
end
% eigenmode_data.z_fields = z_field_data;
