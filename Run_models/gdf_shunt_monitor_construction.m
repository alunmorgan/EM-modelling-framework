function fs = gdf_shunt_monitor_construction
% Constructs the initial part of the gdf input file for GdfidL 
%
% fs is
%
% Example: fs = gdf_shunt_monitor_construction

fs = {'###################################################'};
fs = cat(1,fs,'-time');
fs = cat(1,fs,'    tmin = 25/FREQ');
fs = cat(1,fs,'    tmax = 25.1/FREQ');
fs = cat(1,fs,'-storefieldsat');
fs = cat(1,fs,'    name = ef');
fs = cat(1,fs,'    whattosave = e-fields');
fs = cat(1,fs,'    firstsaved = 24/FREQ');
fs = cat(1,fs,'    lastsaved = 25/FREQ');
fs = cat(1,fs,'    distance = 1/4/FREQ');
fs = cat(1,fs,'    doit');
fs = cat(1,fs,' ');
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'    doit');
fs = cat(1,fs,'###################################################');
