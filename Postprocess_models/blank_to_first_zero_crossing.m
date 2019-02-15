function data = blank_to_first_zero_crossing(data)
%Returns the input data with the section between the start and the first
%zero crossing set to zero.
%
% Args:
%       data(list of floats): typically an oscillating input signal.
%
% example: data = blank_to_first_zero_crossing(data)
crossings1 = find(data > 0 & circshift(data,1) <= 0, 1, 'first');
crossings2 = find(data < 0 & circshift(data,1) >= 0, 1, 'first');
first_crossing = min(crossings1, crossings2);
data(1:first_crossing) = 0;

end

