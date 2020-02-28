function pipe_length = get_pipe_length_from_defs(defs)
% Loads in the user definitions and finds how long the additional beam
% pipes are.
%
% Example: pipe_length = get_pipe_length_from_defs(defs)
test = flatten_nest(defs);
pl = find(strcmp( test(:,1),'pipe_length'));
if isempty(pl)
    pipe_length = 0;
else
    pipe_length = test{pl, 2};
end