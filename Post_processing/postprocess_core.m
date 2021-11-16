function postprocess_core(pp_data_directory, version, sim_type, s_set, excitation)

if strcmpi(sim_type, 'wake') || strcmpi(sim_type, 'eigenmode')|| strcmpi(sim_type, 'lossy_eigenmode')
    pp_input_file = ['model_', sim_type, '_post_processing'];
    pp_log_file = ['model_', sim_type ,'_post_processing_log'];
elseif strcmpi(sim_type, 's_parameter')
    pp_input_file = ['model_s_param_set_',s_set, '_',excitation,'_post_processing_input_file'];
    pp_log_file = ['model_s_param_set_',s_set, '_',excitation,'_post_processing_log'];
end %if
temp_files('make', '.')
% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',version);
[~]=system(['gd1.pp < ',...
    fullfile(pp_data_directory,pp_input_file),...
    ' > ',...
    fullfile(pp_data_directory, pp_log_file)]);
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
% Check that the post processor has completed
data = read_file_full_line(fullfile(pp_data_directory , pp_log_file));
for hwa = 1:length(data)
    if ~isempty(strfind(data{hwa},'The End of File is reached')) ||...
            ~isempty(strfind(data{hwa},'The End of the File is reached')) ||...
            ~isempty(strfind(data{hwa},'This is the normal End'))
        disp(['Postprocess ',sim_type , ': The post processor core has run to completion'])
        break
    end %if
    if hwa == length(data)
        disp(['Postprocess ',sim_type , ': The post processor core has not completed properly'])
    end %if
end %for

if ~strcmpi(sim_type, 'eigenmode') && ~strcmpi(sim_type, 'lossy_eigenmode')
    %% convert the gld files for the field output images to ps.
    gld_files = dir_list_gen('temp_scratch', 'gld', 1);
    parfor fjh = 1:length(gld_files)
        [~,name,~] = fileparts(gld_files{fjh});
        system(['gd1.3dplot -colorps -geometry 800x600 -o ',fullfile('temp_scratch', name), 'ps -i ' , gld_files{fjh}]);
    end %parfor
end %if
delete temp_scratch/*.gld
[pic_names ,~]= dir_list_gen('temp_scratch','ps',1);
for eh = 1:length(pic_names)
    pName = pic_names{eh}(1:end-3);
    [sFlag, ~] = system(['convert ',fullfile('temp_scratch', pName),'.ps -rotate -90 ',fullfile('temp_scratch', pName),'.png']);
    if sFlag == 0
        delete(fullfile('temp_scratch', [pName,'.ps'] ))
    end %if
end %for


%% move any remaining files to the output location.
movefile('temp_scratch/*', pp_data_directory)

temp_files('remove', '.')
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');