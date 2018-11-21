function [timescale_out, padded_output] = ...
    pad_data(timescale, new_length, length_type, input_data)
% Pads data with zeros at the end, while extending the associated
% timescale.
%
% Example: [timescale_out, padded_output] = pad_data(timescale, new_length, length_type, input_data)

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
            for dsi = 1:size(input_data{rn},2) % number of vectors
                [ tmp(:,dsi), timescale_temp] = pad_vector(input_data{rn}(:,dsi), timescale, 'pos', new_length);
            end %for
            padded_output{rn} = tmp;
            clear tmp
            % Use the timescale  of the first variable.
            if rn == 1
                timescale_out = timescale_temp;
            end %if
        end %for
    else
        for dsi = 1:size(input_data, 2) % number of vectors
            [ tmp(:,dsi), timescale_temp] = pad_vector(input_data(:,dsi), timescale, 'pos', new_length);
            % Use the timescale  of the first variable.
            if dsi == 1
                timescale_out = timescale_temp;
            end %if
        end %for
        padded_output = tmp;
        clear tmp
    end %if
    
elseif strcmp(length_type,'time')
    % pad to a set length in time
    % first find out the length of the original time data.
    %     t_length_orig = length(timescale);
    % Find the step size (this should not change).
    time_stepsize = abs(timescale(2) - timescale(1));
    % Create a new timescale using the original stepsize but with the length specified.
    timescale_out = linspace(0,new_length,round(new_length/time_stepsize))';
    % Calculate how much the original datasets need to be extended
    %     ext_needed = length(timescale_out) - t_length_orig;
    % padding the time domain data
    if iscell(input_data)
        for hse = length(input_data):-1:1 %number of sets.
            padded_output{hse} = zeros(length(timescale_out), size(input_data{hse}, 2));
            for hef = 1:size(input_data{hse},2)
                padded_output{hse}(1:length(input_data{hse}(:,hef)), hef) = input_data{hse}(:,hef);
            end %for
        end %for
    else
        padded_output = zeros(length(timescale_out), size(input_data, 2));
        for hef = 1:size(input_data, 2)
            padded_output(1:length(input_data(:,hef)), hef) = input_data(:,hef);
        end %for
    end
end
end
