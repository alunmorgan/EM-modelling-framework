function postprocess_core(pp_input_file_path, version)


[pp_directory, pp_input_file] = fileparts(pp_input_file_path);
pp_log_file = [pp_input_file, '_log'];

%% creating file structure
if contains(pp_input_file, '_EfieldHistory')
    tag = regexp(pp_input_file,'.*_EfieldHistory([0-9]+)', 'tokens');
    mkdir([pp_directory,'/field_history/',tag{1}{1},'/'])
end %if

%% Running the postprocessor
% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',version);
tail = round(rand*1e4);
lnk_name = ['/scratch2/temp',num2str(tail)];
[~] = system(['ln -s ',pp_directory, ' ', lnk_name]);
% Setting the temp directory location for the scratch
setenv('TMPDIR', lnk_name)
[~]=system(['gd1.pp < ', lnk_name,'/', pp_input_file, ' > ', lnk_name, '/', pp_log_file]);
% restoring the original version.
fprintf('\n')
setenv('GDFIDL_VERSION',orig_ver);

%% Check that the post processor has completed
[~, data] = system(['tail ', lnk_name, '/', pp_log_file]);
if contains(data,'The End of File is reached') ||...
        contains(data,'The End of the File is reached') ||...
        contains(data,'This is the normal End')
    fprintf(['\nPostprocess ', pp_input_file, ': The post processor core has run to completion'])
    %         break
else
    fprintf(['\nPostprocess ', pp_input_file, ': The post processor core has not completed properly'])
end %if

%% fixing the arrow plot file naming.
[pic_names_temp ,~]= dir_list_gen(lnk_name,'gld',1);
arrowplot_names = pic_names_temp(contains(pic_names_temp, '3D-Arrowplot'));
new_arrowplot_names = regexprep(arrowplot_names, '.*3D-Arrowplot\.([0-9]+)\.gld', '3D-Arrowplot-$1.gld');
for jas = 1:length(arrowplot_names)
    % movefile crashes with unknown error so using a direct system call here
    % instead.
    [status1,cmdout1] = system(['mv ' fullfile(lnk_name, arrowplot_names{jas}), ' ', fullfile(lnk_name, new_arrowplot_names{jas})], '-echo');
    if status1==0
        fprintf('.')
    else
        fprintf(['\n',cmdout1, '\n'])
    end %if
end %for
fprintf('\n')
%% convert the gld files for the field output images to ps.
gld_files = dir_list_gen(lnk_name, 'gld', 1);
parfor fjh = 1:length(gld_files)
    [~,name,~] = fileparts(gld_files{fjh});
    [status2,cmdout2] = system(['gd1.3dplot -colorps -geometry 800x600 -o ',fullfile(lnk_name, name), '.ps -i ' , gld_files{fjh}]);
    if status2==0
        fprintf('.')
    else
        fprintf(['\n',cmdout2, '\n'])
    end %if
end %for
fprintf('\n')
delete([lnk_name,'/*.gld'])

%% convert ps to png
[pic_names ,~]= dir_list_gen(lnk_name,'ps',1);
parfor eh = 1:length(pic_names)
    pName = pic_names{eh}(1:end-3);
    [sFlag, ~] = system(['convert ',fullfile(lnk_name, pName),'.ps -rotate -90 ',fullfile(lnk_name, pName),'.png'], '-echo');
    if sFlag == 0
        delete(fullfile(lnk_name, [pName,'.ps'] ))
    end %if
end %for


% %% move any remaining files to the output location.
% % having to do it is seperate sections to avoid an 'Unknown error' in movefile.
% directories = dir_list_gen_tree('temp_scratch', 'dirs',1);
% if ~isempty(directories)
%     for seh = 1:length(directories)
%         new_dir = fullfile(pp_directory, regexprep(directories{seh}, 'temp_scratch/',''));
%         if ~exist(new_dir,'dir')
%             mkdir(new_dir)
%         end %if
%     end %for
% end %if

% files = dir_list_gen_tree('temp_scratch', '',1);
% if ~isempty(files)
%     for sen = 1:length(files)
%         new_location = fullfile(pp_directory, regexprep(files{sen}, 'temp_scratch/',''));
%         movefile(files{sen}, new_location )
%     end %for
% end %if

% temp_files('remove', '.')
[~] = system(['rm ', lnk_name]);
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');