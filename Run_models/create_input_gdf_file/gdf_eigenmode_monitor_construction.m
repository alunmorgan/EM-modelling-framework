function fs = gdf_eigenmode_monitor_construction(estimation_freq, nsol, type, f_range, passes)
% Constructs the initial part of the gdf input file for GdfidL
%
% nsol determines the number of solutions to use.
% type is
%
% Example: fs = gdf_eigenmode_monitor_construction(estimation_freq, nsol, type, f_range)

fs = {'###################################################'};
fs = cat(1,fs,'-eigenvalues');
fs = cat(1,fs,['    solutions = ',num2str(nsol)]);
fs = cat(1,fs,['    estimation = ', num2str(estimation_freq)]);
fs = cat(1,fs,['    lossy = ', type]);
fs = cat(1,fs,['    passes = ', num2str(passes)]);
if strcmp(type, 'yes')
    fs = cat(1,fs,['    flowsearch = ', num2str(f_range(1))]);
    fs = cat(1,fs,['    fhighsearch = ', num2str(f_range(2))]);
end%if
fs = cat(1,fs,'    doit');
fs = cat(1,fs,' ');
fs = cat(1,fs,'###################################################');
