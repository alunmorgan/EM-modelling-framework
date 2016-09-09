function pipe_length = get_pipe_length_from_defs(defs)
% Loads in the user definitions and finds how long the additional beam
% pipes are.
%
% Example: pipe_length = get_pipe_length_from_defs(defs)

pl = find_position_in_cell_lst(strfind( defs,'pipe_length'));
if isempty(pl)
    pipe_length = 0;
else
    pl = defs{pl};
    pl2 = regexp(pl,'define\([a-zA-Z0-9_]+\s*,\s*([0-9\.]+)\s*\).*','tokens');
    pipe_length = str2num(pl2{1}{1});
end