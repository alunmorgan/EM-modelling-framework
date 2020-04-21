function [freq, shunt] = GdfidL_read_pp_shunt_log( log_file )
%Reads in the eigenmode log file and extracts parameter data from it.
%
% Example: log = GdfidL_read_eigenmode_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

%% Remove the commented out parts of the input file
cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
data(cmnt_ind) = [];
del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
data(del_ind) = [];
clear del_ind cmnt_ind
%% Analyse the data


% find the frequency.
freq_ind = find_position_in_cell_lst(strfind(data,'defining: "FREQ"'));
 tokf_tmp = regexp(data{freq_ind},'###\s*defining:\s*"FREQ"\s*,\s*Value:\s*"\s*([\d.+-e]+)\s*"','tokens');
        freq = str2num(tokf_tmp{1}{1});

% find the field values
field_ind = find_position_in_cell_lst(strfind(data,'redefining: "@vreal"'));
% The results occour twice in the logs. Removing one instance of each.
% field_ind((1:2:(length(field_ind)-1))+1) = [];
    for ja = 1:length(field_ind)
        toks_tmp = regexp(data{field_ind(ja)},'###\s*redefining:\s*"@vreal"\s*,\s*Value:\s*"\s*([\d.+-e]+)\s*"','tokens');
        shunt(ja) = str2num(toks_tmp{1}{1});

    end
end
