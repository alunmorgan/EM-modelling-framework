function fs = gdf_wake_monitor_construction(wake_length)
% Constructs the monitor part of the gdf input file for GdfidL 
%
% fs is
% wake_length is 
%
% Example: fs = gdf_wake_monitor_construction(wake_length)

fs = {'-fdtd'};
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
fs = cat(1,fs,'    -storefieldsat');
fs = cat(1,fs,'        name= ED');
fs = cat(1,fs,'        whattosave = e-fields');
% reducing the wake length as sometimes the simulation stops just before
% the defined wake length, and then the power monitors are not triggered.
fs = cat(1,fs,['           firstsaved= ',num2str(str2num(wake_length)-0.2),' / @clight']);
fs = cat(1,fs,'           lastsaved= INF');
fs = cat(1,fs,'           distance= 10 / @clight');
fs = cat(1,fs,'        doit');
fs = cat(1,fs,'    -storefieldsat');
fs = cat(1,fs,'        name= EF');
fs = cat(1,fs,'        whattosave = both');
fs = cat(1,fs,['           firstsaved= (',num2str(str2num(wake_length)),' / @clight - 1e-9)']);
fs = cat(1,fs,'           lastsaved= INF');
fs = cat(1,fs,'           distance= 100e-12');
fs = cat(1,fs,'        doit');
fs = cat(1,fs,'-fdtd   ');
fs = cat(1,fs,'    doit');