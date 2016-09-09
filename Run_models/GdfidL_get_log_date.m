function log = GdfidL_get_log_date( log_file )
%Reads in the log file and extracts parameter data from it.
%
% Example:  log = GdfidL_get_log_date( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

% find the date and time the simulation was run.
dte_ind = find_position_in_cell_lst(strfind(data,'Start Date : '));
dte = regexp(data{dte_ind},'.*Start\s+Date\s*:\s*(\d\d/\d\d/\d\d\d\d)', 'tokens');
log.dte = char(dte{1});
tme_ind = find_position_in_cell_lst(strfind(data,'Start Time : '));
tme = regexp(data{tme_ind},'.*Start\s+Time\s*:\s*(\d\d:\d\d:\d\d)', 'tokens');
log.tme = char(tme{1});