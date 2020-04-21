function out = orient_vector(in,direction)
% orentate a vector in a particular dimension/direction.
% it leaves matricies alone.
% direction has values 1 or 2.
% only works for first 2 dimensions.
% Example: data along the first dimension
% out = orient_vector(in,1)

% Work out the current orientation copared to the requested one
if size(in,1) == 1
    if direction == 1
        out = in';
    elseif direction == 2
        out = in;
    end
elseif size(in,2) == 1
    if direction == 1
        out = in;
    elseif direction == 2
        out = in';
    end
    % Otherwise it is a matrix. Just pass it through.
else
    out = in;
end
