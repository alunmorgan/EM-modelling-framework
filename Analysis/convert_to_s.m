function [lab, data] = convert_to_s(lab, data)
% Converts GdfidL data measured in meters into measured in seconds.
%
% lab is a string which determines if the data is measured in time [s] or
% distance s[m].
% Outputs the correct label and the converted data.
%
% Example: [lab, data] = convert_to_s(lab, data)

if strfind(lab,'s[m]')
    % data is in length units .. convert to time units.
    data(:,1) = (data(:,1) ./ 299792458);
    lab = 'Time [s]';
elseif strfind(lab,'[s]')
    % makes the labeling consistent
    data(:,1) = data(:,1);
    lab = 'Time [s]';
end
