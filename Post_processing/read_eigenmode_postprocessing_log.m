function log = read_eigenmode_postprocessing_log(log_file)
%Reads in the eigenmode log file and extracts parameter data from it.
%
% Example: log = GdfidL_read_eigenmode_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

% find the GdfidL version.
ver_ind = find_position_in_cell_lst(strfind(data,'Version is '));
ver = regexp(data{ver_ind},'.*Version is\s*(.+)', 'tokens');
log.ver = ver{1}{1};


defs_ind = find_position_in_cell_lst(strfind(data,'### I am defining:'));
defs = cell(length(defs_ind), 2);
for fen = 1:length(defs_ind)
    defs_temp = regexp(data{defs_ind(fen)}, '^\s*### I am defining:\s*"@*(.*)"\s*to Value:\s*"(.*)"\s*$', 'tokens');
    defs{fen, 1} = defs_temp{1}{1};
    defs{fen, 2} = defs_temp{1}{2};
end %for
log.defs = defs;

redefs_ind = find_position_in_cell_lst(strfind(data,'### I am redefining:'));
redefs = cell(length(redefs_ind), 2);
for fen = 1:length(redefs_ind)
    redefs_temp = regexp(data{redefs_ind(fen)}, '^\s*### I am redefining:\s*"@*(.*)"\s*to Value:\s*"(.*)"\s*$', 'tokens');
    redefs{fen, 1} = redefs_temp{1}{1};
    redefs{fen, 2} = redefs_temp{1}{2};
end %for
log.redefs = redefs;

freq_inds = find_position_in_cell_lst(strfind(log.redefs(:,1), 'frequency'));
freq_ind = freq_inds(1:2:end); % The first value is real.
ifreq_ind = freq_inds(2:2:end); % The second value is imaginary.
f_inds = find_position_in_cell_lst(strfind(log.redefs(:,1), 'absfmax'));
e_inds = find_position_in_cell_lst(strfind(log.redefs(:,1), 'eenergy'));

for nes = 1:length(f_inds)
    fmax(nes, 3) = str2double(log.redefs(f_inds(nes), 2));
    temp_ind = find(freq_ind < f_inds(nes), 1, 'last');
    fmax(nes, 1) = str2double(log.redefs(freq_ind(temp_ind), 2));
    fmax(nes, 2) = str2double(log.redefs(ifreq_ind(temp_ind), 2));
end %for
uniq_f = unique(fmax(:,1));
for hes = 1:length(uniq_f)
    f_chunk = find(fmax(:,1)==uniq_f(hes));
    log.fmax(hes, 1:3) = fmax(f_chunk(1),:); % take the value form the first graph always
end %for

for nes = 1:length(e_inds)
    log.emax(nes, 3) = str2double(log.redefs(e_inds(nes), 2));
    temp_ind = find(freq_ind < e_inds(nes), 1, 'last');
    log.emax(nes, 1) = str2double(log.redefs(freq_ind(temp_ind), 2));
    log.emax(nes, 2) = str2double(log.redefs(ifreq_ind(temp_ind), 2));
end %for
disp("")