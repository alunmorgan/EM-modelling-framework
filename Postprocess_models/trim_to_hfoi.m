function [data_out, f_raw] = trim_to_hfoi(data_in, f_raw,  hfoi)
% Trims a vector based on the freqency scale and highest freqency of
% interest.

hf_ind = find(f_raw > hfoi, 1, 'first');
f_raw = f_raw(1:hf_ind);
if size(data_in,1) == 1 || size(data_in,2) == 1
    % if it is a vector
data_out = data_in(1:hf_ind);
else
%     Truncate the first dimension
  data_out = data_in(1:hf_ind,:);
end

