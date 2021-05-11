function eigenmode_data = postprocess_eigenmode(modelling_inputs, run_log, pp_type)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% pp_inputs is a structure containing all the information required for the
%  postprocessor
% eigenmode_data is 
%
%Example: eigenmode_data = postprocess_eigenmode(modelling_inputs, run_log)

%% Write the wake post processing input file
% pipe_length = get_pipe_length_from_defs(modelling_inputs.geometry_defs);
pp_settings = analysis_model_settings_library(modelling_inputs.base_model_name);
GdfidL_write_pp_eigenmode_input_file(run_log, pp_type, pp_settings.eigenmode.cuts, ...
    pp_settings.eigenmode.subsections, pp_settings.eigenmode.scale)

%% run the wake postprocessor
eigenmode_output_directory = fullfile('pp_link', pp_type);
postprocess_core(eigenmode_output_directory, modelling_inputs.version, pp_type, 0, 0);

%% Extract parameters from the log.
eigenmode_data = GdfidL_read_eigenmode_log(fullfile('data_link', pp_type, 'model_log'), pp_type);
log = GdfidL_read_eigenmode_postprocessing_log(fullfile('pp_link',pp_type, ['model_',pp_type,'_post_processing_log']));
if isfield(log, 'qs')
eigenmode_data.qs = log.qs;
end
if isfield(log, 'rqs')
eigenmode_data.rqs = log.rqs;
end
% eigenmode_data.z_fields = z_field_data;
