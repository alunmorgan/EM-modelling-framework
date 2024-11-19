function mkdirtree(full_folder_name, previous_folders)
% makes the full directory tree of a given path.
% creates any intermediated folders as needed.
%
% Example: mkdir("/scratch/me/mydata/tests")
if nargin ==1
previous_folders ={};
end %if

[stub, end_folder, ~] = fileparts(full_folder_name);
if ~exist(full_folder_name, "dir")
    if exist(stub)
        status = mkdir(full_folder_name);
        previous_path = full_folder_name;
        for nse = length(previous_folders):-1:1
            current_path = fullfile(previous_path, previous_folders{nse});
            status = mkdir(current_path);
            previous_path = current_path;
        end %for
    else
        previous_folders{end+1} = end_folder;
        mkdirtree(stub, previous_folders);
    end% if
end %if
