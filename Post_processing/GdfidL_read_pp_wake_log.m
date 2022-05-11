function lg  = GdfidL_read_pp_wake_log( logs_location )
%Reads in the log file and extracts parameter data from it.
%
% log file is a string containing the full path to the file.
% Returns a structure containing the extracted data.
%
% Example: log  = GdfidL_read_wake_log( log_file )

lg = struct;
nse =1;

a = dir_list_gen_tree(logs_location, '',1);
b = find(contains(a, ['model_wake_post_processing_log']));
logs = a(b);

for lse = 1:length(logs)
    log_file = logs{lse};
    [p, ~, ~] = fileparts(log_file);
    [~, f, ~] = fileparts(p);
    %% read in the file put the data into a cell array.
    data = read_in_text_file(log_file);
    if isempty(data)
        disp('Wake log file is empty... aborting')
        return
    end %if
    if strcmp(data{end}, ' rc:  -1')
        disp('Wake simulation did not exit cleanly')
        return
    end
    
    %% Analyse the data
    if strcmp(f, 'wake')
        % Find the variable values.
        variable_regexp = '.*\s+defining:\s*"(.*)"\s*[,to]+\s+Value:\s+"(.*)"';
        test= regexp(data, variable_regexp, 'tokens');
        test_ind = cellfun(@isempty,test);
        test2=test(~test_ind);
        for hs = 1:length(test2)
            val_name_temp = regexprep(test2{hs,1}{1}{1}, '@', '');
            lg.(val_name_temp)= test2{hs}{1}{2};
        end %for
    else
        % tfirsts
        tfirst_regexp = 'sparameter>\s+tfirst\s*=\s*(.*)';
        test_tfirst = regexp(data, tfirst_regexp, 'tokens');
        test_tfirst_ind = cellfun(@isempty,test_tfirst);
        test_tfirst2 = test_tfirst(~test_tfirst_ind);
        portnames_regexp = 'sparameter>\s+ports\s*=\s*(.*)';
        test_portnames = regexp(data, portnames_regexp, 'tokens');
        test_portnames_ind = cellfun(@isempty,test_portnames);
        test_portnames2 = test_portnames(~test_portnames_ind);
        lg.start_times{nse, 1} = test_portnames2{1}{1}{1};
        lg.start_times{nse, 2} = eval(test_tfirst2{1}{1}{1});
        nse = nse +1;
    end %if
end %for
