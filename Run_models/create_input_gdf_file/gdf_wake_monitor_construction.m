function fs = gdf_wake_monitor_construction(dtsafety, mov)
% Constructs the monitor part of the gdf input file for GdfidL
%
% fs is
% wake_length is
% mov is a flag as to whether to export files for movie generation.
%
% Example: fs = gdf_wake_monitor_construction(dtsafety, mov)

if nargin < 2
    mov = 0; % defaulting to no movie generation.
end

fs = {'-fdtd'};
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

if mov == 1
    fs = cat(1,fs,'# Store data for the Movie.');
    fs = cat(1,fs,' define( FIRSTSAV, 1e-3  / @clight )');
    fs = cat(1,fs,' define( DISTSAV, 10e-3 / @clight )');
    fs = cat(1,fs,' define( MODELLENTIME, INF)');%50E-3 / @clight )');%( @zmax - @zmin) / @clight )');
    fs = cat(1,fs,'    -fexport');
    fs = cat(1,fs,'       what= e-fields');
    fs = cat(1,fs,'       firstsaved= FIRSTSAV');
    fs = cat(1,fs,'       lastsaved= MODELLENTIME');
    fs = cat(1,fs,'       distancesaved= DISTSAV');
    fs = cat(1,fs,'       outfile= ./efieldsx');
    fs = cat(1,fs,'       bbylow=0'); 
    fs = cat(1,fs,'       bbyhigh=0'); 
    fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       outfile= ./efieldsy');
    fs = cat(1,fs,'       bbylow=-1E30');
    fs = cat(1,fs,'       bbyhigh=1E30');
    fs = cat(1,fs,'       bbxlow=0');
    fs = cat(1,fs,'       bbxhigh=0');
    fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       outfile= ./efieldsz');
    fs = cat(1,fs,'       bbxlow=-1E30');
    fs = cat(1,fs,'       bbxhigh=1E30');
    fs = cat(1,fs,'       bbzlow=0');
    fs = cat(1,fs,'       bbzhigh=0');
    fs = cat(1,fs,'       doit');
else
    fs = cat(1,fs,'# No movie requested... not storing additional files.');
end %if

% fs = cat(1,fs,'-fdtd   ');
% % fs = cat(1,fs,'    doit');