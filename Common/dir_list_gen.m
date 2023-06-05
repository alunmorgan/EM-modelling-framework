function [names,directory_name]=dir_list_gen(directory_name,file_type,quiet_flag)
%takes in a directory name and outputs the list of files
%as a cell array of strings filtered by file type.
% if a file type of 'dirs' is input it will output a list of directories.
% asks for a file if a name is not provided
% the 3 input makes it quiet or verbose (1 = quiet) if not given assume
% verbose.
% if 1 output given give absolute paths, if 2 are given outputs absolute
% directory and a list of filenames.
% example
% [names,directory_name]=dir_list_gen('U:\','mat',1)
%% Input conditioning
if nargin ==1
    file_type = directory_name;
    directory_name = uigetdir ;
    quiet_flag = 0;
elseif nargin == 2
    if ischar(file_type) ~= 1
        % no directory name is given so all inputs shifted by one
        quiet_flag = file_type;
        file_type = directory_name;
        directory_name = uigetdir;
    else
        % no flag given assume noisy
        quiet_flag = 0;
    end
    
end
%removes leading . of file_type if present
if isempty(file_type) ==0 && strcmp(file_type(1), '.') == 1
    file_type = file_type(2:end);
end

% adding a trailing / to the directory name if running under linux
% adding a trailing \ to the directory name if running under windows
if ispc == 0
    if strcmp(directory_name(end),'/') == 0
        directory_name = [directory_name '/'];
    end
else
    if strcmp(directory_name(end),'\') == 0
        directory_name = [directory_name '\'];
    end
end

%% Getting intial list
a = dir(directory_name);
if isempty(a)
    fprinf('\nDirectory does not exist')
    names = [];
    directory_name = '';
    return
end
dir_state = NaN(length(a),1);
names = a(1).name;
dir_state(1,1) = a(1).isdir;
for fa =2:length(a)
    names = cat_multi_dim(1,names,a(fa).name);
    dir_state(fa,1) = a(fa).isdir;
end


%% Formatting the output
if nargout == 1
    % making the file path absolute
    names = strcat(repmat(directory_name,size(names,1),1), names);
elseif nargout == 2
else
    error('Wrong number of outputs (should be 1 or 2)')
end
names = cellstr(names);

%% Finding the apropriate filetype in the list
if strcmp(file_type,'dirs')
    dirs = names(dir_state == 1);
    %Remove the . and .. directories from the list.
    for kw = 1:length(dirs)
        [~, ~, ext] = fileparts(dirs{kw});
        if strcmp(ext, '.')
            to_remove(kw) = 1;
        else
            to_remove(kw) = 0;
        end %if
    end %for
    dirs(to_remove == 1) = [];
    if isempty(dirs)
        names = [];
        if quiet_flag ~= 1
            fprinf('\nNo directories found');
        end %if
    else
        names = dirs;
        if quiet_flag ~= 1
            fprinf(['\n', num2str(size(names,1)) ' directories found']);
        end %if
    end %if
elseif strcmp(file_type,'')
    % Need to remove directories from the list
    names = names(dir_state ~= 1);
else
    if isempty(file_type)
        ind = regexpi(names,'.$');
    else
        ind = regexpi(names,['\.' file_type '$']);
    end
    fk = 1;
    for kjsd = 1:size(ind,1)
        if isempty(cell2mat(ind(kjsd))) ~= 1
            ind2(fk) = kjsd;
            fk = fk +1;
        end
    end
    if exist('ind2','var') == 0
        if quiet_flag ~= 1
            fprinf(['\nNo files with extension ' file_type ' found']);
        end
        names = [];
    else
        names = names(ind2);
        if quiet_flag ~= 1
            fprinf(['\n', num2str(size(names,1)) ' files with extension ' file_type ' found']);
        end
    end
end
