function [timescale_out,varargout] = ...
    pad_data(timescale, new_length, length_type, varargin)
% Pads data with zeros at the end, while extending the associated
% timescale.
%
% Example: [timescale_out,varargout] = pad_data(timescale, new_length, length_type, varargin)

%% zero pad the time domain.
% This will improve the resolution of the frequency plots and better
% represent the shape of the response.
% This is adding true information as we know that there is no signal before
% the bunch arrives. However if we pad before, then the phase spins madly.
% We can pad afterwards as there is an implicit wrapping due to the finite
% extent of the FFT.

if strcmp(length_type,'points')
    % pad to a length of 2^N points.
    for esh = 1:length(varargin)
        if iscell(varargin{esh})
            for rn = 1:length(varargin{esh})
                for dsi = 1:size(varargin{esh}{rn},2)
                  [ tmp(:,dsi), timescale_temp] = pad_vector(varargin{esh}{rn}(:,dsi), timescale, 'pos', new_length);
                end
                varargout{esh}{rn} = tmp;
            end
        else
            [varargout{esh}, timescale_temp] = pad_vector(varargin{esh}, timescale, 'pos', new_length);
        end
        % Use the timescale  of the first variable.
        if esh == 1
            timescale_out = timescale_temp;
        end
    end
elseif strcmp(length_type,'time')
    % pad to a set length in time
    % first find out the length of the original time data.
    t_length_orig = length(timescale);
    % Find the step size (this should not change).
    time_stepsize = abs(timescale(2) - timescale(1));
    % Create a new timescale using the original stepsize but with the length specified.
    timescale_out = linspace(0,new_length,round(new_length/time_stepsize))';
    % Calculate how much the original datasets need to be extended
    ext_needed = length(timescale_out) - t_length_orig;
    % padding the time domain data
    for hse = 1:length(varargin)
        if iscell(varargin{hse})
            for rn = 1:length(varargin{hse})
                varargout{hse}{rn} = varargin{hse}{rn};
                varargout{hse}{rn} = cat(1,varargout{hse}{rn}, zeros(length(timescale_out) - ...
                        size(varargin{hse}{rn},1), size(varargin{hse}{rn},2)));           
            end
        else
            varargout{hse} = cat(1, varargin{hse}, zeros(ext_needed,1));
        end
    end
end
