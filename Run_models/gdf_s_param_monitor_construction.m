function fs = gdf_s_param_monitor_construction(port_name, frequency, bandwidth, amplitude, tmax)
% Constructs the initial part of the gdf input file for GdfidL
%
% port_name (cell array of strings):  the names of the ports to be excited.
% frequency is the central frequency of the excitation. (eg 500E6)
% bandwidth is the bandwidth of the excitation. (eg 1E9)
% tmax is the length of time the monitor runs until.
%
% Example: fs = gdf_s_param_monitor_construction(port_name, frequency, bandwidth, tmax)
fs = {'###################################################'};
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'-pexcitation');
for kds = 1:length(port_name)
    fs = cat(1,fs,['port= ',port_name{kds}]);
    fs = cat(1,fs,'mode = 1');
    if kds ==1
        fs = cat(1,fs,['frequency = ',num2str(frequency)]);
        fs = cat(1,fs,['bandwidth = ', num2str(bandwidth)]);
    end %if
    fs = cat(1,fs,['amplitude = ', num2str(amplitude)]);
    fs = cat(1,fs,'    nextport');
end %for
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'-time');
fs = cat(1,fs,'tmin = 10e-15');
fs = cat(1,fs,['tmax = ', num2str(tmax)]);
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'    doit');
fs = cat(1,fs,' ');
fs = cat(1,fs,'###################################################');
