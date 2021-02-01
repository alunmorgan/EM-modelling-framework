function eigenmode_data = postprocess_eigenmode(modelling_inputs, run_log)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% pp_inputs is a structure containing all the information required for the
%  postprocessor
% eigenmode_data is 
%
%Example: eigenmode_data = postprocess_eigenmode(pp_inputs)

%% Write the wake post processing input file
% pipe_length = get_pipe_length_from_defs(modelling_inputs.geometry_defs);
GdfidL_write_pp_eigenmode_input_file(run_log, [1,100])

%% run the wake postprocessor
eigenmode_output_directory = fullfile('pp_link', 'eigenmode');
postprocess_core(eigenmode_output_directory, modelling_inputs.version, 'eigenmode', 0, 0);

%% find the location of all the required output files
% [eigenmodes] = GdfidL_find_eigenmode_ouput('temp_scratch');

%% Extract the eigenmode data
% Converting the images from ps to eps via png to reduce the file size.
% [pic_names ,~]= dir_list_gen(eigenmode_output_directory,'',1);

% Fixing a problem with output file naming.
% for eh = 1:length(pic_names)
%     if strcmp(pic_names{eh}(end-1:end),'ps')
%         pName = pic_names{eh}(1:end-2);
%         movefile(fullfile(eigenmode_output_directory, [pName, 'ps']),...
%             fullfile(eigenmode_output_directory, [pName, '.ps']))
%     end %if
% end %for


% z_field = GdfidL_find_output_eigenmode('temp_scratch');
% for shw = 1:length(z_field)
%     z_field_data{shw} = GdfidL_read_graph_datafile( z_field{shw});
% end

%% Extract parameters from the log.
eigenmode_data = GdfidL_read_eigenmode_log('data_link/eigenmode/model_log' );
log = GdfidL_read_eigenmode_postprocessing_log( 'pp_link/eigenmode/model_eigenmode_post_processing_log');
if isfield(log, 'qs')
eigenmode_data.qs = log.qs;
end
if isfield(log, 'rqs')
eigenmode_data.rqs = log.rqs;
end
% eigenmode_data.z_fields = z_field_data;
