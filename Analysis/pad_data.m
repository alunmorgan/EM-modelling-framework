function [timescale_out, padded_output] = ...
    pad_data(timescale, input_data, new_lengths, length_type)
% Pads data with zeros at the end, while extending the associated
% timescale.
%
% Example: [timescale_out, padded_output] = pad_data(timescale, input_data, new_length, length_type)

% The Assumption is that both timescale and input data are vectors or a
% cell of vectors.
if length(new_lengths) == 1
    data_start = 0;
    data_end = new_lengths;
elseif length(new_lengths) == 2
    data_start = new_lengths(1);
    data_end = new_lengths(2);
else
    disp('Too many lengths to pad data with')
end

%% zero pad the time domain.
% This will improve the resolution of the frequency plots and better
% represent the shape of the response.
% This is adding true information as we know that there is no signal before
% the bunch arrives. However if we pad before, then the phase spins madly.
% We can pad afterwards as there is an implicit wrapping due to the finite
% extent of the FFT.

if strcmp(length_type,'points')
    % pad to a length of 2^N points.
    if iscell(input_data)
        for rn = 1:length(input_data) %number of sets.
            [padded_output{rn}, timescale_temp] = pad_vector(input_data{rn}, timescale, 'pos', new_lengths);
            % Use the timescale  of the first variable.
            if rn == 1
                timescale_out = timescale_temp;
            end %if
        end %for
    else
        [padded_output, timescale_out] = pad_vector(input_data, timescale, 'pos', new_lengths);
    end %if
    
elseif strcmp(length_type,'time')
    % pad to a set length in time
    % first find out the length of the original time data.
    %     t_length_orig = length(timescale);
    % Find the step size (this should not change).
    time_stepsize = abs(timescale(2) - timescale(1));
    % Create a new timescale using the original stepsize but with the length specified.
    timescale_out = linspace(data_start, data_end, (data_end - data_start)/time_stepsize + 1)';
    offset = find(timescale_out < timescale(1),1, 'last');
    % Calculate how much the original datasets need to be extended
    %     ext_needed = length(timescale_out) - t_length_orig;
    % padding the time domain data
    if iscell(input_data)
        for hse = length(input_data):-1:1 %number of sets.
            padded_output{hse} = zeros(length(timescale_out), 1);
            padded_output{hse}(offset + 1:length(input_data{hse}, 1)) = input_data{hse};
        end %for
    else
        padded_output = zeros(length(timescale_out), 1);
        padded_output(offset + 1:length(input_data), 1) = input_data;
    end %if
elseif strcmp(length_type,'samples')
    % pad to a set number of samples
    % Find the step size (this should not change).
    time_stepsize = abs(timescale(2) - timescale(1));
    data_start = timescale(1);
    data_end = timescale(1) + (new_lengths - 1) * time_stepsize;
    % Create a new timescale using the original stepsize but with the length specified.
    timescale_out = linspace(data_start, data_end, (data_end - data_start)/time_stepsize + 1)';
    % padding the time domain data
    if iscell(input_data)
        for hse = length(input_data):-1:1 %number of sets.
            padded_output{hse} = zeros(length(timescale_out), 1);
            padded_output{hse}(1:length(input_data{hse}, 1)) = input_data{hse};
        end %for
    else
        padded_output = zeros(length(timescale_out), 1);
        padded_output(1:length(input_data), 1) = input_data;
    end %if
end %if

