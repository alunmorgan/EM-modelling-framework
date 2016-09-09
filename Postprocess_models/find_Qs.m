function [peaks, Q, bw] = find_Qs(f_raw, spectrum, num)
% takes the full spectrum (both sides) and find the peaks greater than num% of the largest peak. then
% calculates the Q value for each peak. Returns the num most highly resonant
% frequencies.
%
% Example: [peaks, Q, bw] = find_Qs(f_raw, spectrum, num)

tmp_f = f_raw(1:floor(length(f_raw)/2));
tmp = spectrum(1:floor(length(spectrum)/2));
peaks = findpeaks_n_point(tmp_f, tmp, 10);
Q = NaN(size(peaks,1),1);
bw = NaN(size(peaks,1),1);
bad_data = [];
tk = 1;
for nse = 1:size(peaks,1)
    ind = find(tmp_f == peaks(nse,1));
    ind2 = find(tmp(ind:end) < peaks(nse,2)/2,1,'first')+ind-1;
    ind3 = ind +1 - find(flipud(tmp(1:ind)) < peaks(nse,2)/2,1,'first');
    if  isempty(ind2) || isempty(ind3) || ind2 == 0 || ind3 == 0
        bad_data(tk) = nse;
        tk = tk +1;
    else
        %find the angle of the left side
        tanang_l = (tmp(ind3 +1) - tmp(ind3));
        % target y value (left side).
        hh_l = tmp(ind) ./ 2 - tmp(ind3);
        % frequency at target value (left side).
        ft_l = tmp_f(ind3) + hh_l ./ tanang_l;
        %find the angle of the left side
        tanang_r = (tmp(ind2 - 1) - tmp(ind2));
        % target y value (left side).
        hh_r = tmp(ind) ./ 2 - tmp(ind2);
        % frequency at target value (left side).
        ft_r = tmp_f(ind2) - hh_r ./ tanang_r ;
        
        % In the case of overlapping peaks the found indicies will be very
        % asymetric about the peak. In this case set the larger offset index to
        % the same distence from the peak as the smaller one.
        diff_left = tmp_f(ind) - ft_l;
        diff_right = ft_r - tmp_f(ind);
        if diff_left > 2*diff_right
            bw(nse) = 2 * diff_right;
        elseif diff_right > 2* diff_left
            bw(nse) = 2 * diff_left;
        else
            %bandwidth
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
    %     % sort into increasing Q
    %     [Q, ind] = sort(Q,'descend');
    %     peaks = peaks(ind,:);
    %     bw = bw(ind);
end

% try
% figure(1)
% range = floor(length(f_raw)/2);
% plot(f_raw(1:range), spectrum(1:range), ...
%     peaks(:,1) - bw/2, peaks(:,2),'.r', ...
%     peaks(:,1) + bw/2, peaks(:,2),'.b')
% catch
% end
