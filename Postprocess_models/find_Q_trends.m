function [swept_par, freqs, Qs, mags, bws] = find_Q_trends(frequency_domain_data, range, swept_par)
% Find the Q data and return the change in Q against the requested parameter. 
%
% frequency_domain_data is a structure containing the results of the
% postprocessing frequency analysis.
% range is the separation peaks have to have to be counted as separate.
% swept_par is paramter to plot Q against.
%
% Example: [swept_par, freqs, Qs, mags, bws] = find_Q_trends(frequency_domain_data, range, swept_par)

if nargin <3
    % Assume that we are sweeping over wake length.
    swept_par = NaN(length(frequency_domain_data),1);
    for whs = 1:length(frequency_domain_data)
        swept_par(whs) = frequency_domain_data{whs}.Wake_length;
    end
end

[swept_par, inds] = sort(swept_par, 'descend');
% extract the information on the peak frequencies and Qs for different wake
% lengths.

%initial setup
peaks = cell(length(frequency_domain_data),1);
Q = cell(length(frequency_domain_data),1);
mag = cell(length(frequency_domain_data),1);
bw = cell(length(frequency_domain_data),1);

for haw = 1:length(frequency_domain_data)
    peaks{haw} = frequency_domain_data{inds(haw)}.BLPS_peaks(:,1);
    Q{haw} = frequency_domain_data{inds(haw)}.BLPS_Qs;
    bw{haw} = frequency_domain_data{inds(haw)}.BLPS_bw;
    if isnan(frequency_domain_data{inds(haw)}.BLPS_peaks)
        mag{haw} = NaN;
    else
        mag{haw} = frequency_domain_data{inds(haw)}.BLPS_peaks(:,2);
    end
end

if isempty(peaks{1})
    Qs = NaN;
    freqs = NaN;
    mags = NaN;
    bws = NaN;
else
    % for each peak in the the longest wake model find it in the other models
    % find to range.
    
    % initial setup
    tp = 0;
    for hr = 1:length(peaks)
        tp = max(tp,length(peaks{hr}));
    end
    %     freqs = NaN(tp,length(peaks));
    %     Qs =  NaN(tp,length(peaks));
    %     bws =  NaN(tp,length(peaks));
    %     mags =  NaN(tp,length(peaks));
    peaks_2 = NaN(tp,length(peaks));
    %     ind_last_run(1:tp,1) = 1:tp;
    
    
    for hse = 1:length(peaks) % each run
        for esjh = 1:length(peaks{hse}) % each peak
            peaks_2(esjh,hse) = peaks{hse}(esjh);
        end
    end
    
    % for each peak found in the last run, track it back through the
    % earlier runs.
    ck = 1;
    for nes = 1:tp
        if isnan(peaks_2(nes,1))
            % no viable peak here... move on to the next one.
        else
            track_ind(ck,1:size(peaks_2,2)) = NaN;
            track_ind(ck,1) = nes;
            target_freq = peaks_2(nes, 1);
            for ena = 2:size(peaks_2,2)
                %         Find if the value is in the previous run (within range)
                tmp_ind = find(peaks_2(:,ena) < target_freq + range &...
                    peaks_2(:,ena) >= target_freq - range);
                if isempty(tmp_ind)
                    track_ind(ck,ena) = NaN;
                elseif length(tmp_ind) >1
                    lims = range;
                    while length(tmp_ind) >1
                        tmp_ind = find(peaks_2(:,ena) < target_freq + lims &...
                            peaks_2(:,ena) >= target_freq - lims);
                        lims = lims/2;
                    end
                track_ind(ck,ena) = tmp_ind;
%                 disp(['Temp value while', num2str(tmp_ind)])
                 target_freq = peaks_2(tmp_ind, ena);
                else
                    track_ind(ck,ena) = tmp_ind;
%                     disp(['Temp value ', num2str(tmp_ind)])
                     target_freq = peaks_2(tmp_ind, ena);
                end
               
            end
            ck = ck +1;
        end
    end
    if exist('track_ind', 'var')
        for enf = 1:size(track_ind,1) % each track
            for jes = 1:size(track_ind,2) % along each track
                if isnan(track_ind(enf,jes))
                    freqs(enf,jes) = NaN;
                    Qs(enf,jes) = NaN;
                    bws(enf,jes) = NaN;
                    mags(enf,jes) = NaN;
                else
                    freqs(enf,jes) = peaks{jes}(track_ind(enf,jes));
                    Qs(enf,jes) = Q{jes}(track_ind(enf,jes));
                    bws(enf,jes) = bw{jes}(track_ind(enf,jes));
                    mags(enf,jes) = mag{jes}(track_ind(enf,jes));
                end
            end
        end
    else
        freqs = NaN;
        Qs = NaN;
        bws = NaN;
        mags = NaN;
    end
end

swept_par = swept_par(1:size(Qs,2));

if isvector(Qs)
    % only one peak had been found. No further filtering is required.
else
    
    % Sort by peak magnitude for the longest wake.
%     [freqs, final_sort] = sort(freqs,1);
%     for jd = 1:size(freqs,2)
%         Qs(:,jd) = Qs(final_sort(:,jd),jd);
%         bws(:,jd) = bws(final_sort(:,jd),jd);
%         mags(:,jd) = mags(final_sort(:,jd),jd);
%     end
    
    % remove peaks which are less than 1% of the dominant peak.
%     cutoff = find(mags(:,1) < max(mags(:,1))./100, 1,'first');
%     freqs(cutoff:end,:) = [];
%     Qs(cutoff:end,:) = [];
%     bws(cutoff:end,:) = [];
%     mags(cutoff:end,:) =[];
end