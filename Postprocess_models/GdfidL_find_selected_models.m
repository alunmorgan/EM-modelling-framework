function arc_names = GdfidL_find_selected_models(input_folder, requested_range)
% Finds the names of the modelling runs which are in the desired range and
% from the requested folder.
%
% input_folder is a string containing the full path to the desired folder. 
% requested_range is a cell array of strings. Either 'last' or 1 or 2 date
% strings with the format 'yyyymmddTHHMMSS'.
%
% Example: arc_names = GdfidL_find_selected_models(input_folder, requested_range)


% find all the separate runs for the selected model.
arcs = dir_list_gen(input_folder,'dirs',1);
% remove the paths.
arc_chop = strfind(arcs, '/');
arc_mark = cellfun(@max,arc_chop);
% create lists of names and dates for the found files.
clk = 1;
for wn = 1:size(arcs,1);
    temp_arc = arcs{wn}(arc_mark(wn)+1:end);
    if regexp(temp_arc, '\d{8}T\d{6}') == 1
        arc_names{clk} = temp_arc;
        arc_dates(clk) = datenum(temp_arc, 'yyyymmddTHHMMSS');
        clk = clk +1;
    end
end

% Work out the date range of files to process.
if strcmp(requested_range{1}, 'last')
    % Find the latest folder
    [~,ind] = max(arc_dates);
elseif length(requested_range) ==1
    start{1} = datestr(requested_range{1},'yyyymmddTHHMMSS');
    wch_date = datenum(start{1}, 'yyyymmddTHHMMSS');
    % find all files on or after this date.
    ind = find(arc_dates == wch_date);
elseif length(requested_range) >1
    start{1} = datestr(requested_range{1},'yyyymmddTHHMMSS');
    start{2} = datestr(requested_range{2},'yyyymmddTHHMMSS');
    wch_date1 = datenum(start{1}, 'yyyymmddTHHMMSS');
    % find all files on or after this date.
    ind1 = find(arc_dates >= wch_date1);
    wch_date2 = datenum(start{2}, 'yyyymmddTHHMMSS');
    % find all files on or after this date.
    ind2 = find(arc_dates <= wch_date2);
    ind = intersect(ind1, ind2);
end
if isempty(ind)
    error('GdfidL_post_process_models: No file with that datestamp is present in the data.');
end

arc_names = arc_names(ind);
