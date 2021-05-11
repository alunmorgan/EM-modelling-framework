function temp_files(in, restart_files_path)
% make or remove sets of temp folders for GdfidL output.
%
% in is either 'make' or 'remove'
%
% Example: temp_files('make')

if strcmp(in,'make')
    if ~exist('temp_scratch','dir')
        mkdir('temp_scratch');
    end
    if ~exist('temp_data','dir')
        mkdir('temp_data');
    end
    if ~exist(fullfile(restart_files_path,'temp_restart'),'dir')
        mkdir(fullfile(restart_files_path,'temp_restart'));
    end
elseif strcmp(in,'remove')
    if exist('temp_scratch','dir')
        rmdir('temp_scratch','s');
    end
    if exist('temp_data','dir')
        rmdir('temp_data','s');
    end
    if exist(fullfile(restart_files_path,'temp_restart'),'dir')
        rmdir(fullfile(restart_files_path,'temp_restart'),'s');
    end
end
% Sometimes the filesystems take time to propogate the update
% especially after deleting a large number of files.
% This puase gives the system a chance to catch up.
pause(10)