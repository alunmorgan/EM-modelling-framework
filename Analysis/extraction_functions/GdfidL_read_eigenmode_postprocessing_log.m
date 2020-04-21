function log = GdfidL_read_eigenmode_postprocessing_log( log_file )
%Reads in the eigenmode log file and extracts parameter data from it.
%
% Example: log = GdfidL_read_eigenmode_log( log_file )

log = struct;

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

%% Remove the commented out parts of the input file
cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
data(cmnt_ind) = [];
del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
data(del_ind) = [];
clear del_ind cmnt_ind
%% Analyse the data

% find the eigenvalues
q_ind = find_position_in_cell_lst(regexp(data,'^\s*\*\*\*\s*QValue\s*is\s*([0-9eE-+\.]*)'));
if ~isempty(q_ind)
    for seh = 1:length(q_ind)
        toks_tmp1 = regexp(data{q_ind(seh)},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp2 = regexp(data{q_ind(seh)-1},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp3 = regexp(data{q_ind(seh)-2},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        log.qs.mode(seh) = str2num(toks_tmp3{1}{1});
        log.qs.freq(seh) = str2num(toks_tmp2{1}{1});
        log.qs.q(seh) = str2num(toks_tmp1{1}{1});
    end
end

% find the R/Q
rq_ind = find_position_in_cell_lst(regexp(data,'^\s*\*\*\*\s*shunt impedances as computed from \| Re\(U\) \* Re\(U\)'));
if ~isempty(rq_ind)
    for seh = 1:length(rq_ind)
        toks_tmp1 = regexp(data{rq_ind(seh)-7},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp2 = regexp(data{rq_ind(seh)-6},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp3 = regexp(data{rq_ind(seh)-3},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp4 = regexp(data{rq_ind(seh)-2},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp5 = regexp(data{rq_ind(seh)+1},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp6 = regexp(data{rq_ind(seh)+2},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp7 = regexp(data{rq_ind(seh)+5},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        toks_tmp8 = regexp(data{rq_ind(seh)+6},'^\s*\*\*\*\s*.*\s*is\s*([0-9eE-+\.]*)','tokens');
        log.rqs.mode(seh) = str2num(toks_tmp1{1}{1});
        log.rqs.freq(seh) = str2num(toks_tmp2{1}{1});
        log.rqs.r_over_q_complex(seh) = str2num(toks_tmp3{1}{1});
        log.rqs.r_over_q_per_m_complex(seh) = str2num(toks_tmp4{1}{1});
        log.rqs.r_over_q_real(seh) = str2num(toks_tmp5{1}{1});
        log.rqs.r_over_q_per_m_real(seh) = str2num(toks_tmp6{1}{1});
        log.rqs.r_over_q_imag(seh) = str2num(toks_tmp7{1}{1});
        log.rqs.r_over_q_per_m_imag(seh) = str2num(toks_tmp8{1}{1});
    end
end