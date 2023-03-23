function fs = gdf_wake_voltage_sources(voltage_sources)
% Constructs the monitor part of the gdf input file for GdfidL
%
% fs is a cell array of strings containing the GdfidL code for setting up
% the voltage sources.

%
% Example: fs = gdf_wake_voltage_sources(voltage_monitors)

fs = {''};
fs = cat(1,fs,'     -voltages');

for nse = 1:length(voltage_sources)
    fs = cat(1,fs,['         name= ', voltage_sources{nse}.name]);
    fs = cat(1,fs,['            startpoint= ', voltage_sources{nse}.startpoint]);
    fs = cat(1,fs,['            endpoint= ', voltage_sources{nse}.endpoint]);
    fs = cat(1,fs,['            resistance= ', voltage_sources{nse}.resistance]);
    fs = cat(1,fs,['            inductance= ', voltage_sources{nse}.inductance]);
    fs = cat(1,fs,['            amplitude= ', voltage_sources{nse}.voltage]');
    fs = cat(1,fs,['            risetime= ', voltage_sources{nse}.risetime]);
%     fs = cat(1,fs,['            frequency= ', voltage_sources{nse}.frequency]');
    fs = cat(1,fs,'         doit');
end %for

