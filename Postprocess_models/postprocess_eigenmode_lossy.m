function eigenmode_data = postprocess_eigenmode_lossy(pp_inputs)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% pp_inputs is a structure containing all the information required for the
%  postprocessor
% eigenmode_data is 
%
%Example: eigenmode_data = postprocess_eigenmode_lossy(pp_inputs)

%% EIGENMODE POSTPROCESSING
% run the eigenmode postprocessor
GdfidL_write_pp_eigenmode_input_file(30, pp_inputs)
temp_files('make')
[~]=system('gd1.pp < pp_link/lossy_eigenmode/model_eigenmode_lossy_post_processing > pp_link/lossy_eigenmode/model_eigenmode_lossy_post_processing_log');
%% find the location of all the required output files
% [eigenmodes] = GdfidL_find_eigenmode_ouput('temp_scratch');

%% Extract the eigenmode data

% Converting the images from ps to eps via png to reduce the file size.
[pic_names ,~]= dir_list_gen('.','ps',1);
for ns = 1:length(pic_names)
    pic_nme = pic_names{ns}(1:end-3);
    [~] = system(['convert ',pic_nme,'.ps ',pic_nme,'.png']);
    [~] = system(['convert ',pic_nme,'.png ',pic_nme,'.eps']);
    movefile([pic_nme,'.png'], 'pp_link/lossy_eigenmode');
    movefile([pic_nme,'.eps'], 'pp_link/lossy_eigenmode');
    delete([pic_nme,'.ps'])
end
z_field = GdfidL_find_output_eigenmode('temp_scratch');
for shw = 1:length(z_field)
    z_field_data{shw} = GdfidL_read_graph_datafile( z_field{shw});
end

temp_files('remove')
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');

%% Extract parameters from the log.
eigenmode_data = GdfidL_read_eigenmode_log('data_link/eigenmode_lossy/model_log' );
log = GdfidL_read_eigenmode_postprocessing_log( 'pp_link/lossy_eigenmode/model_eigenmode_lossy_post_processing_log');
if isfield(log, 'qs')
eigenmode_data.qs = log.qs;
end
if isfield(log, 'rqs')
eigenmode_data.rqs = log.rqs;
end
eigenmode_data.z_fields = z_field_data;
