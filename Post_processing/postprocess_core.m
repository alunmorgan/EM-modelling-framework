function postprocess_core(pp_data_directory, version, sim_type, s_set, excitation, varargin)

p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
% valid_string = @(x) ischar(x);
addRequired(p, 'pp_data_directory');
addRequired(p, 'version');
addRequired(p, 'sim_type');
addRequired(p, 's_set');
addRequired(p, 'excitation');
addParameter(p, 'pp_input_file', '');
parse(p, pp_data_directory, version, sim_type, s_set, excitation, varargin{:});

pp_input_file = p.Results.pp_input_file;
pp_log_file = [pp_input_file, '_log'];

%% creating file structure
temp_files('make', '.')
if contains(pp_input_file, '_EfieldHistory')
    tag = regexp(pp_input_file,'.*_EfieldHistory([0-9]+)', 'tokens');
    mkdir(['temp_scratch/field_history/',tag{1}{1},'/'])
end %if

%% Running the postprocessor
% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',version);
[~]=system(['gd1.pp < ', pp_input_file, ' > ', pp_log_file]);
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);

%% Check that the post processor has completed
data = read_file_full_line(pp_log_file);
for hwa = 1:length(data)
    if ~isempty(strfind(data{hwa},'The End of File is reached')) ||...
            ~isempty(strfind(data{hwa},'The End of the File is reached')) ||...
            ~isempty(strfind(data{hwa},'This is the normal End'))
        fprintf(['\nPostprocess ',sim_type , ': The post processor core has run to completion'])
        break
    end %if
    if hwa == length(data)
        fprintf(['\nPostprocess ',sim_type , ': The post processor core has not completed properly'])
    end %if
end %for

if ~strcmpi(sim_type, 'eigenmode') && ~strcmpi(sim_type, 'lossy_eigenmode')
    %% convert the gld files for the field output images to ps.
    gld_files = dir_list_gen('temp_scratch', 'gld', 1);
    for fjh = 1:length(gld_files)
        [~,name,~] = fileparts(gld_files{fjh});
        [status,cmdout] = system(['gd1.3dplot -colorps -geometry 800x600 -o ',fullfile('temp_scratch', name), 'ps -i ' , gld_files{fjh}]);
        fprintf(cmdout)
    end %parfor
end %if
delete temp_scratch/*.gld

%% fixing the arrow plot file naming.
[pic_names_temp ,~]= dir_list_gen('temp_scratch','',1);
arrowplot_names = pic_names_temp(contains(pic_names_temp, '3D-Arrowplot'));
new_arrowplot_names = regexprep(arrowplot_names, '3D-Arrowplot\.([0-9]+)ps', '3D-Arrowplot-$1.ps');
for jas = 1:length(arrowplot_names)
    % movefile crashes with unknown error so using a direct system call here
    % instead.
    [status1,cmdout1] = system(['mv ' fullfile('temp_scratch',arrowplot_names{jas}), ' ', fullfile('temp_scratch',new_arrowplot_names{jas})], '-echo');
    fprintf(cmdout1)
end %for
%% convert ps to png
[pic_names ,~]= dir_list_gen('temp_scratch','ps',1);
for eh = 1:length(pic_names)
    pName = pic_names{eh}(1:end-3);
    [sFlag, ~] = system(['convert ',fullfile('temp_scratch', pName),'.ps -rotate -90 ',fullfile('temp_scratch', pName),'.png'], '-echo');
    if sFlag == 0
        delete(fullfile('temp_scratch', [pName,'.ps'] ))
    end %if
end %for


%% move any remaining files to the output location.
% having to do it is seperate sections to avoid an 'Unknown error' in movefile.
directories = dir_list_gen_tree('temp_scratch', 'dirs',1);
if ~isempty(directories)
    for seh = 1:length(directories)
        new_dir = fullfile(pp_data_directory, regexprep(directories{seh}, 'temp_scratch/',''));
        if ~exist(new_dir,'dir')
            mkdir(new_dir)
        end %if
    end %for
end %if

files = dir_list_gen_tree('temp_scratch', '',1);
if ~isempty(files)
    for sen = 1:length(files)
        new_location = fullfile(pp_data_directory, regexprep(files{sen}, 'temp_scratch/',''));
        movefile(files{sen}, new_location )
    end %for
end %if

temp_files('remove', '.')
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');