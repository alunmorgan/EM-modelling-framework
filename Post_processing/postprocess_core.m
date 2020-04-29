function output_file_locations = postprocess_core(modelling_inputs,sim_type)


% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',modelling_inputs.version);
[~]=system(['gd1.pp < ',...
    fullfile('pp_link',sim_type,['model_', sim_type, '_post_processing']),...
    ' > ',...
    fullfile('pp_link', sim_type, ['model_', sim_type ,'_post_processing_log'])]);
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
% Check that the post processor has completed
data = read_file_full_line(fullfile('pp_link', sim_type , ['model_', sim_type ,'_post_processing_log']));
for hwa = 1:length(data)
    if ~isempty(strfind(data{hwa},'The End of File is reached'))
        disp(['Postprocess ',sim_type , ': The post processor has run to completion'])
        break
    end %if
    if hwa == length(data)
        warning(['Postprocess ',sim_type , ': The post processor has not completed properly'])
    end %if
end %for
%% find the location of all the required output files
output_file_locations = GdfidL_find_ouput('temp_scratch');

%% convert the gld files for the field output images to ps and move them to the output location.
    gld_files = dir_list_gen('temp_scratch', 'gld', 1);
    parfor fjh = 1:length(gld_files)
        [~,name,~] = fileparts(gld_files{fjh});
        system(['gd1.3dplot -colorps -geometry 800x600 -o ',fullfile('pp_link', sim_type, name), 'ps -i ' , gld_files{fjh}]);
    end %parfor

    %% move any png files to the output location.
    movefile('temp_scratch/*.png', fullfile('pp_link', sim_type))