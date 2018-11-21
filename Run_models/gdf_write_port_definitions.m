function fs = gdf_write_port_definitions( names, planes, modes)
% Writes the port_definition.txt input file for a GdfidL simulation. 


fs = {'-fdtd'};
fs = cat(1,fs, '    -ports');
fs = cat(1,fs,'        name = port_bp_in');
fs = cat(1,fs,'        plane = zlow');
fs = cat(1,fs,'        npml = NPMLs');
fs = cat(1,fs,'        modes = 10');
fs = cat(1,fs,'        doit');
fs = cat(1,fs,' ');
    fs = cat(1,fs,'    -ports');
fs = cat(1,fs,'        name = port_bp_out');
fs = cat(1,fs,'        plane = zhigh');
fs = cat(1,fs,'        npml = NPMLs');
fs = cat(1,fs,'        modes = 10');
fs = cat(1,fs,'        doit');
fs = cat(1,fs,' ');

for prt = 1:length(names)
fs = cat(1,fs,'    -ports');
fs = cat(1,fs,['        name = ', names{prt}]);
fs = cat(1,fs,['        plane = ', planes{prt}]);
fs = cat(1,fs,'        npml = NPMLs');
fs = cat(1,fs,['        modes = ', num2str(modes(prt))]);
fs = cat(1,fs,'        doit');
fs = cat(1,fs,' ');
end %for


