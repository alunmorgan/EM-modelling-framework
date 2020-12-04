function [peaks, Q, bw] = find_Qs(f_raw, spectrum, num, data_type)
% takes the full spectrum (both sides) and find the peaks greater than num% of the largest peak. then
% calculates the Q value for each peak. Returns the num most highly resonant
% frequencies.
%
% data_type (str): selects if the data is single sided or not (single_sided,
%                  double_sided). Defaults to double sided.
%
% Example: [peaks, Q, bw] = find_Qs(f_raw, spectrum, num)

if nargin == 3
    tmp_f = f_raw(floor(length(f_raw)/2):end);
    tmp = spectrum(floor(length(spectrum)/2:end));
else
    tmp_f = f_raw;
    tmp = spectrum;
end %if
peaks = findpeaks_n_point(tmp_f, tmp, 10);
Q = NaN(size(peaks,1),1);
bw = NaN(size(peaks,1),1);
bad_data = [];
tk = 1;
for nse = 1:size(peaks,1)
    ind_peak = find(tmp_f == peaks(nse,1));
    ind_rhs = find(tmp(ind_peak:end) < peaks(nse, 2)/2, 1, 'first')+ ind_peak - 1;
    ind_lhs = find(tmp(1:ind_peak) < peaks(nse, 2)/2, 1, 'last');
    if  isempty(ind_rhs) || isempty(ind_lhs) || ind_rhs == 0 || ind_lhs == 0
        bad_data(tk) = nse;
        tk = tk +1;
    else
        f_adj_range_l = (tmp(ind_lhs +1) - tmp(ind_lhs));
        % fractional adjustment (left side).
        adj_l = (tmp(ind_peak) ./ 2 - tmp(ind_lhs)) ./ (tmp(ind_lhs +1) - tmp(ind_lhs));
        % frequency at target value (left side).
        ft_l = tmp_f(ind_lhs) + adj_l .* f_adj_range_l;

        f_adj_range_r = (tmp(ind_rhs - 1) - tmp(ind_rhs));
        % fractional adjustment (right side).
        adj_r = (tmp(ind_rhs) - tmp(ind_peak) ./ 2) ./ (tmp(ind_rhs -1) - tmp(ind_rhs)) ;
        % frequency at target value (left side).
        ft_r = tmp_f(ind_rhs) - (1 - adj_r .* f_adj_range_r);
        
        % In the case of overlapping peaks the found indicies will be very
        % asymetric about the peak. In this case set the larger offset index to
        % the same distence from the peak as the smaller one.
        diff_left = tmp_f(ind_peak) - ft_l;
        diff_right = ft_r - tmp_f(ind_peak);
        if diff_left > 2*diff_right
            bw(nse) = 2 * diff_right;
        elseif diff_right > 2* diff_left
            bw(nse) = 2 * diff_left;
        else
            %bandwidth (FWHM)
            bw(nse) = diff_left + diff_right;
        end
        % Q factor
        Q(nse) = peaks(nse,1) ./bw(nse);
    end
end

% removing any bad peaks.
Q(bad_data) = [];
bw(bad_data) = [];
peaks(bad_data,:) = [];

if isempty(Q)
    Q =NaN;
    bw = NaN;
    peaks = [NaN,NaN];
else
    % sort by peak height
    [~ , ind_ph] = sort(peaks(:,2),'descend');
    peaks = peaks(ind_ph,:);
    bw = bw(ind_ph);
    Q = Q(ind_ph);
    
    % Only take the ones above num%.
    ind_ph = find(peaks(:,2) > num/100 .* peaks(1,2));
    Q = Q(ind_ph);
    bw = bw(ind_ph);
    peaks = peaks(ind_ph,:);
end

% try
% figure(1)
% range = floor(length(f_raw)/2);
% plot(f_raw(1:range), spectrum(1:range), ...
%     peaks(:,1) - bw/2, peaks(:,2),'.r', ...
%     peaks(:,1) + bw/2, peaks(:,2),'.b')
% catch
% end
if nargin >3
    Q = abs(Q);
    bw = abs(bw);
end %if

