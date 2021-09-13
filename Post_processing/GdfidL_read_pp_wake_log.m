function lg  = GdfidL_read_pp_wake_log( log_file )
%Reads in the log file and extracts parameter data from it.
%
% log file is a string containing the full path to the file.
% Returns a structure containing the extracted data.
%
% Example: log  = GdfidL_read_wake_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);
if isempty(data)
    disp('Wake log file is empty... aborting')
    return
end %if
if strcmp(data{end}, ' rc:  -1')
    disp('Wake simulation did not exit cleanly')
    lg = data;
    return
end
lg = struct;

% 
% %% Remove the commented out parts of the input file
% cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
% data(cmnt_ind) = [];
% del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
% data(del_ind) = [];
% clear del_ind cmnt_ind
%% Analyse the data

% Find the variable values.
variable_regexp = '.*\s+defining:\s*"(.*)",\s+Value:\s+"(.*)"';
test= regexp(data, variable_regexp, 'tokens');
test_ind = cellfun(@isempty,test);
test2=test(~test_ind);
for hs = 1:length(test2)
    test3{hs,1} = test2{hs,1}{1}{1};
    test3{hs,2} = test2{hs}{1}{2};
end %for
% tfirsts
tfirst_regexp = 'sparameter>\s+tfirst\s*=\s*(.*)';
test_tfirst = regexp(data, tfirst_regexp, 'tokens');
test_tfirst_ind = cellfun(@isempty,test_tfirst);
test_tfirst2 = test_tfirst(~test_tfirst_ind);
portnames_regexp = 'sparameter>\s+ports\s*=\s*(.*)';
test_portnames = regexp(data, portnames_regexp, 'tokens');
test_portnames_ind = cellfun(@isempty,test_portnames);
test_portnames2 = test_portnames(~test_portnames_ind);
for nse = 1:ceil(length(test_tfirst2)/2)
    start_times{nse, 1} = test_portnames2{nse}{1}{1};
    start_times{nse, 2} = eval(test_tfirst2{nse}{1}{1});
end %for
lg.start_times = start_times;
