function data = trim_to_hfoi(data, f_raw,  hfoi)
% Trims a vector based on the freqency scale and highest freqency of
% interest.
% assumes it is a double sided frequency signal.
hf_possible = f_raw(end) /2;
if hfoi <= hf_possible
    hf_ind_lower = find(f_raw > hfoi, 1, 'first');
    hf_ind_upper = length(f_raw) - hf_ind_lower;
    if size(data,1) == 1 || size(data,2) == 1
        % if it is a vector
        data(hf_ind_lower:hf_ind_upper) = 0;
    else
        %     Truncate the first dimension
        data(hf_ind_lower:hf_ind_upper,:) = 0;
    end %if
end %if

