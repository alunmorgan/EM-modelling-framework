function [start_ind, final_ind] = get_trim_inds(data, trim_fraction)
% Trim fraction controls how much data is trimmed from the ends. This is often required as it contains artifacts.
% It ranges from 0 to 0.49 which correcsponds to nothing to the middle 2% 
% it is capped to within that range
if trim_fraction < 0
    trim_fraction = 0;
end %if
if trim_fraction > 0.49
    trim_fraction = 0.49;
end %if

start_ind = ceil(length(data) * trim_fraction) + 1;
final_ind = floor(length(data) - length(data) * trim_fraction);

if start_ind > final_ind
    start_ind = final_ind;
end %if
end

