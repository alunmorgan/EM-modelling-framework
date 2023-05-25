function [max_field_components, data_rearranged,data_timestamps] =  rearrange_fexport_data(data)
% Rearranges the data structure to have the data in vectors of time.

field_types = fieldnames(data);
slices = {'x','y','z'};
field_components = {'Fx','Fy','Fz'};
max_field_components = struct;
data_rearranged = struct;
data_timestamps = struct;

for sdw = 1:length(field_types)
    time_samples = fieldnames(data.(field_types{sdw}));
    for kfd = 1:length(time_samples)
        timestamps_temp = regexprep(time_samples{kfd}, 'T', '');
        timestamps_temp = regexprep(timestamps_temp, 'p', '\.');
        timestamps_temp = regexprep(timestamps_temp, 'm', '-');
        timestamps_temp = str2num(timestamps_temp);
        for bea = 1:length(slices)
            for snw = 1:length(field_components)
                data_temp = data.(field_types{sdw}).(time_samples{kfd}).(slices{bea}).(field_components{snw});
                max_field_components.(field_types{sdw}).(slices{bea}).(field_components{snw})(kfd) = max(max(data_temp));
                data_rearranged.(field_types{sdw}).(slices{bea}).(field_components{snw})(kfd, 1:size(data_temp,1), 1:size(data_temp,2)) = data_temp;
                data_timestamps.(field_types{sdw}).(slices{bea}).(field_components{snw})(kfd) = timestamps_temp;
            end %for
        end %for
    end %for
end %for
clear data_temp