
function locs = find_quotes_loc_in_string(string_in)
% Finds the location of " in a string.
%
% Example: locs = find_quotes_loc_in_string(string_in)
locs = strfind(string_in,'"');
if length(locs) > 2
    locs = locs(end-1:end);
end