function out = reduce_cell_depth(in)
% Converts nested cell arrays into multidimensional cell arrays.
%
% Example: out = reduce_cell_depth(in)
if isempty(in)
    out = in;
else
    for sh = 1:length(in)
        if isempty(in{sh}) == 0
            for jaw = 1:length(in{sh})
                out{sh,jaw} = in{sh}{jaw};
            end
        end
    end
end
if exist('out','var') == 0
    out = in;
end
