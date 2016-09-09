function fs = gdf_s_param_monitor_construction(port_name)
% Constructs the initial part of the gdf input file for GdfidL 
%
% port_name is the name of the port to be excited.
%
% Example: fs = gdf_s_param_monitor_construction(port_name)
fs = {'###################################################'};
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'-pexcitation');
fs = cat(1,fs,['port= ',port_name]);
fs = cat(1,fs,'mode = 1');
% TODO make the frequency and bandwidth user settable at the top level
% There needs to be very little power at 0Hz as this gives a DC component
% which is undesirable.
fs = cat(1,fs,'frequency = 5e9');
fs = cat(1,fs,'bandwidth = 10e9');
fs = cat(1,fs,'amplitude = 1');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'-time');
fs = cat(1,fs,'tmin = 10e-15');
fs = cat(1,fs,'tmax = 40e-9');
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'    doit');
fs = cat(1,fs,' ');
fs = cat(1,fs,'###################################################');
