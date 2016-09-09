function [data, timescale] = pad_vector(data, timescale, loc, pwr)
% Pads the data with zeros to a 2^n length.
% if loc = 'pos' then at the end.
% if loc = 'neg' then at the begining.
% data is the data to be padded
% timescale is the associated timescale
% pwr is the desired power of 2 the data vector will be padded to.
% This is useful for time domain pulses which are later going to be
%Fourier transformed.

data_len = length(data);
step_size = abs(timescale(2) - timescale(1));

% if the no pwr is set or if the data length is longer than the set power.
% Then find the next largest power of 2.
if nargin <3 || 2^pwr < data_len
    % find the next largest power of 2
    pr = 0;
    tmp = 2^pr;
    while tmp < data_len
        tmp = 2^pr;
        pr = pr +1;
    end
    % increasing the power of 2 by 1
    pwr = pr +1;
end
padding_len = 2^pwr - data_len;
% Generate the additional timebase
pad_timebase = linspace(timescale(end) + step_size , timescale(end) + step_size * padding_len, padding_len)';
timescale = cat(1, timescale, pad_timebase);

% add the padding. Taking care to check the orientation of teh vector.
pad_data = zeros(padding_len,1);
if size(data,1) ==1 && size(data,2) > 1
    if strcmp(loc,'neg')
        data = cat(2, pad_data', data);
    else
        data = cat(2, data, pad_data');
    end
else
    if strcmp(loc,'neg')
        data = cat(1, pad_data, data);
    else
        data = cat(1, data, pad_data);
    end
end