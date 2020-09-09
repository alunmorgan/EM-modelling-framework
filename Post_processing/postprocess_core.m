function postprocess_core(pp_data_directory, version, sim_type, s_set, excitation)

disp(['GdfidL_post_process_models: Post processing ', sim_type, ' data.'])
if strcmpi(sim_type, 'wake') || strcmpi(sim_type, 'eigenmode')
%     pp_data_directory = fullfile('pp_link',sim_type);
    pp_input_file = ['model_', sim_type, '_post_processing'];
    pp_log_file = ['model_', sim_type ,'_post_processing_log'];
elseif strcmpi(sim_type, 's_parameter')
%     pp_data_directory = fullfile('pp_link', 's_parameter',['model_s_param_set_',s_set,'_',excitation,'_post_processing']);
    pp_input_file = ['model_s_param_set_',s_set, '_',excitation,'_post_processing_input_file'];
    pp_log_file = ['model_s_param_set_',s_set, '_',excitation,'_post_processing_log'];
end %if
temp_files('make')
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
    if ~isempty(strfind(data{hwa},'The End of File is reached'))
        disp(['Postprocess ',sim_type , ': The post processor has run to completion'])
        break
    end %if
    if hwa == length(data)
        warning(['Postprocess ',sim_type , ': The post processor has not completed properly'])
    end %if
end %for


%% convert the gld files for the field output images to ps.
gld_files = dir_list_gen('temp_scratch', 'gld', 1);
parfor fjh = 1:length(gld_files)
    [~,name,~] = fileparts(gld_files{fjh});
    system(['gd1.3dplot -colorps -geometry 800x600 -o ',fullfile('temp_scratch', name), 'ps -i ' , gld_files{fjh}]);
end %parfor
delete *.gld

%% move any remaining files to the output location.
movefile('temp_scratch/*', pp_data_directory)

temp_files('remove')
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');