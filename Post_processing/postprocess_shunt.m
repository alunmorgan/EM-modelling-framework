function shunt_data = postprocess_shunt
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% pp_inputs is a structure containing all the information required for the
%  postprocessor
% shunt_data is
%
%Example: shunt_data = postprocess_shunt(pp_inputs)


[names ,~] = dir_list_gen('data_link/shunt', 'dirs', 1);
names = names(3:end);


%% SHUNT POSTPROCESSING
for gss = 1:length(names)
    freq = num2str(names{gss});
    % run the eigenmode postprocessor
    GdfidL_write_pp_shunt_input_file(freq)
    temp_files('make')
    [~]=system(['gd1.pp < pp_link/shunt/model_shunt',freq ,'_post_processing > pp_link/shunt/model_shunt_',freq,'_post_processing_log']);
    
    [pic_names ,~]= dir_list_gen('.','ps',1);
    for ns = 1:length(pic_names)
        pic_nme = pic_names{ns}(1:end-3);
        [~] = system(['convert ',pic_nme,'.ps ',pic_nme,'.png']);
        [~] = system(['convert ',pic_nme,'.png ',pic_nme,'.eps']);
        movefile([pic_nme,'.png'], 'pp_link/shunt');
        movefile([pic_nme,'.eps'], 'pp_link/shunt');
        delete([pic_nme,'.ps'])
    end
    
    temp_files('remove')
    delete('POSTP-LOGFILE');
    delete('WHAT-PP-DID-SPIT-OUT');
    
    %% Extract parameters from the log.
    
    [freq_temp, shunt_data_temp] = GdfidL_read_pp_shunt_log(['pp_link/shunt/model_shunt_',freq,'_post_processing_log']);
    freq_out(gss) = freq_temp;
    shunt(gss,1:length(shunt_data_temp)) = shunt_data_temp;
end
shunt_data.freq = freq_out;
shunt_data.fields = shunt;

% Converting the images from ps to eps via png to reduce the file size.
