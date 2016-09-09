function val_out = find_val_in_cell_nest(nest_in)
% Works through a set of nested cells until the required value is found.
% some functions output a cell array and using a set of these functions
% leads to a nest. Also sometimes the level of nesting it difficult to
% determine or variable, so this function just tries to bottom out the
% nesting.

while iscell(nest_in)
    nest_in = nest_in{1};
end
val_out = nest_in;