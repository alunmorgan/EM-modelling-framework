function parameters = get_parameters_from_sidecar_file(file_loc)
% Reads the parameters sidecar file gnerated by the STL model generation
% code.
% Make the output the same as for the approach using the GdfidL primatives.
% 
% file_loc (string): full path to the parameter file
%
% parameters (cell): cell array containing the names and valuse of the
% geometric parameters.

data = read_file_full_line(file_loc);
data = reduce_cell_depth(data);
vals = reduce_cell_depth(reduce_cell_depth(...
    regexp(data, '(.*)\s:\s(.*)', 'tokens')));
tmp = cellfun(@str2num, vals(:,2));
for nse = 1:length(tmp)
parameters{nse}{1} = vals{nse, 1};
parameters{nse}{2} = {tmp(nse)};
parameters{nse}{3} = '';
end %if
