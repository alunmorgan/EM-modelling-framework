function fs = gdf_wake_monitor_construction(dtsafety, mov, voltage_monitors, field_setup)
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

if mov == 1
    fs = cat(1,fs,'# Store field data.');
    fs = cat(1,fs,' define( FIRSTSAV, 20e-3  / @clight )');
    fs = cat(1,fs,' define( DISTSAV, 10e-3 / @clight )');
    fs = cat(1,fs,[' define( MODELLENTIME, ', field_setup.stop_time,')']);
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
    fs = cat(1,fs,'       bbzlow=-1E30');
    fs = cat(1,fs,'       bbzhigh=1E30');
    
    fs = cat(1,fs,'       what= h-fields');
    fs = cat(1,fs,'       firstsaved= FIRSTSAV');
    fs = cat(1,fs,'       lastsaved= MODELLENTIME');
    fs = cat(1,fs,'       distancesaved= DISTSAV');
    fs = cat(1,fs,'       outfile= ./hfieldsx');
    fs = cat(1,fs,'       bbylow=0');
    fs = cat(1,fs,'       bbyhigh=0');
    fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       outfile= ./hfieldsy');
    fs = cat(1,fs,'       bbylow=-1E30');
    fs = cat(1,fs,'       bbyhigh=1E30');
    fs = cat(1,fs,'       bbxlow=0');
    fs = cat(1,fs,'       bbxhigh=0');
    fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       outfile= ./hfieldsz');
    fs = cat(1,fs,'       bbxlow=-1E30');
    fs = cat(1,fs,'       bbxhigh=1E30');
    fs = cat(1,fs,'       bbzlow=0');
    fs = cat(1,fs,'       bbzhigh=0');
    fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       bbzlow=-1E30');
    fs = cat(1,fs,'       bbzhigh=1E30');
    if ~isempty(field_setup.full_field_snapshot_times)
        for wld = 1:length(field_setup.full_field_snapshot_times)
            fs = cat(1,fs,'    -fexport');
            fs = cat(1,fs,'       what= e-fields');
            fs = cat(1,fs,['       firstsaved=', field_setup.full_field_snapshot_times{wld}]);
            fs = cat(1,fs,['       lastsaved=', field_setup.full_field_snapshot_times{wld}, ' + DISTSAV']);
            fs = cat(1,fs,['       outfile= ./efields_full_snapshot_', field_setup.full_field_snapshot_times{wld}]);
            fs = cat(1,fs,'       doit');
            fs = cat(1,fs,'       what= h-fields');
            fs = cat(1,fs,['       outfile= ./hfields_full_snapshot_', field_setup.full_field_snapshot_times{wld}]);
            fs = cat(1,fs,'       doit');
            fs = cat(1,fs,'    -storefieldsat');
            fs = cat(1,fs,'       whattosave=both');
            fs = cat(1,fs,'       name=field_snapshots');
            fs = cat(1,fs,['       firstsaved=', field_setup.full_field_snapshot_times{wld}]);
            fs = cat(1,fs,['       lastsaved=', field_setup.full_field_snapshot_times{wld}, ' + DISTSAV']);
            fs = cat(1,fs,'       distancesaved= DISTSAV');
            fs = cat(1,fs,'       doit');  
        end %for
    end %if
    
else
    fs = cat(1,fs,'# No field output requested... not storing additional files.');
end %if

% fs = cat(1,fs,'-fdtd   ');
% % fs = cat(1,fs,'    doit');