function fs = gdf_wake_monitor_construction(dtsafety, voltage_monitors)
% Constructs the monitor part of the gdf input file for GdfidL
%
% Example: fs = gdf_wake_monitor_construction(dtsafety, voltage_monitors)

fs = {''};
fs = cat(1,fs,'     -voltages');
fs = cat(1,fs,'            logcurrent= yes');
fs = cat(1,fs,'            resistance= 1e10, ');
fs = cat(1,fs,'            amplitude= 1e-10,');
fs = cat(1,fs,'            risetime= 1e-10,');
fs = cat(1,fs,'            frequency= 0');
for nse = 1:length(voltage_monitors)
    fs = cat(1,fs,['         name= ', voltage_monitors{nse}.name]);
    fs = cat(1,fs,['            startpoint= ', voltage_monitors{nse}.startpoint]);
    fs = cat(1,fs,['            endpoint= ', voltage_monitors{nse}.endpoint]);
    fs = cat(1,fs,'         doit');
end %for

fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'       -time');
fs = cat(1,fs,['       dtsafety = ',dtsafety]);
fs = cat(1,fs,'       -pmonitor');
fs = cat(1,fs,'       name = TEIS');
fs = cat(1,fs,'       whattosave = energy');
fs = cat(1,fs,'       doit');
fs = cat(1,fs,'        ');
fs = cat(1,fs,'    -pmonitor');
fs = cat(1,fs,'        name = TEC');
fs = cat(1,fs,'        whattosave = pdielectrics');
fs = cat(1,fs,'        doit');
fs = cat(1,fs,'');

