function fs = gdf_eigenmode_monitor_construction(nsol, type)
% Constructs the initial part of the gdf input file for GdfidL 
%
% nsol determines the number of solutions to use.
% type is
%
% Example: fs = gdf_eigenmode_monitor_construction(nsol, type)

fs = {'###################################################'};
fs = cat(1,fs,'-eigenvalues');
fs = cat(1,fs,['    solutions = ',num2str(nsol)]);
fs = cat(1,fs,'    estimation = 11.25e9');
fs = cat(1,fs,['    lossy = ', type]);
fs = cat(1,fs,'    flowsearch = 1e9');
fs = cat(1,fs,'    fhighsearch = 15E9');
fs = cat(1,fs,'    doit');
fs = cat(1,fs,' ');
fs = cat(1,fs,'###################################################');
