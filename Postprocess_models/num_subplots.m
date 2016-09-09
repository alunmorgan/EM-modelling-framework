function [x, y] = num_subplots(num)
% calculates the arrangement of subplots.
%
% num is the total number of subplots required.
% x is the number horizontally.
% y is the number vertically.
%
% Example: [x, y] = num_subplots(num)
x = ceil(sqrt(num));
y = ceil(num/x);