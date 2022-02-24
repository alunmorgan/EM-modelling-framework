function fs = gdf_wake_monitor_construction(mesh_data, dtsafety, mov)
% Constructs the monitor part of the gdf input file for GdfidL
%
% fs is
% wake_length is
% mov is a flag as to whether to export files for movie generation.
%
% Example: fs = gdf_wake_monitor_construction(wake_length)

if nargin < 2
    mov = 0; % defaulting to no movie generation.
end

fs = {'-fdtd'};
fs = cat(1,fs,'       -time');
fs = cat(1,fs,['       dtsafety = ',dtsafety]);
% fs = cat(1,fs,'       -fmonitor');
% fs = cat(1,fs,'       whattosave = ecomponents');
% field_step = '0.5E-3';
% fs = cat(1,fs,'      define(pos_index, 1)');
% fs = cat(1,fs,['      do yscan = ',mesh_data.pylow,', ', mesh_data.pyhigh, ', ', field_step]);
% fs = cat(1,fs,['          do zscan = ',mesh_data.pzlow,', ', mesh_data.pzhigh, ', ', field_step]);
% fs = cat(1,fs,'              name = Efieldat_P(pos_index)');
% fs = cat(1,fs,'              position = (0, yscan, zscan)');
% fs = cat(1,fs,'              doit');
% fs = cat(1,fs,'              define(pos_index, eval(pos_index + 1))');
% fs = cat(1,fs,'          enddo');
% fs = cat(1,fs,'      enddo');
% fs = cat(1,fs,['      do zscan = ',mesh_data.pzlow,', ', mesh_data.pzhigh, ', ', field_step]);
% fs = cat(1,fs,['          do xscan = ',mesh_data.pxlow,', ', mesh_data.pxhigh, ', ', field_step]);
% fs = cat(1,fs,'              name = Efieldat_P(pos_index)');
% fs = cat(1,fs,'              position = (xscan, 0, zscan)');
% fs = cat(1,fs,'              doit');
% fs = cat(1,fs,'              define(pos_index, eval(pos_index + 1))');
% fs = cat(1,fs,'          enddo');
% fs = cat(1,fs,'      enddo');
% fs = cat(1,fs,['      define(z_field_plane, eval(',mesh_data.pzlow,') + (eval(', mesh_data.pzhigh, ') - eval(',mesh_data.pzlow,'))/2)']);
% fs = cat(1,fs,['      do yscan = ',mesh_data.pylow,', ', mesh_data.pyhigh, ', ', field_step]);
% fs = cat(1,fs,['          do xscan = ',mesh_data.pxlow,', ', mesh_data.pxhigh, ', ', field_step]);
% fs = cat(1,fs,'              name = Efieldat_P(pos_index)');
% fs = cat(1,fs,'              position = (xscan, yscan, eval(z_field_plane))');
% fs = cat(1,fs,'              doit');
% fs = cat(1,fs,'              define(pos_index, eval(pos_index + 1))');
% fs = cat(1,fs,'          enddo');
% fs = cat(1,fs,'      enddo');
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
    fs = cat(1,fs,' define( DISTSAV, 3e-3 / @clight )');
    fs = cat(1,fs,' define( MODELLENTIME, INF)');%50E-3 / @clight )');%( @zmax - @zmin) / @clight )');
%     fs = cat(1,fs,'    -storefieldsat');
%     fs = cat(1,fs,'        name= IMP');
%     fs = cat(1,fs,'        whattosave = jimpedance');
%     fs = cat(1,fs,['           firstsaved= FIRSTSAV']);
%     fs = cat(1,fs,'           lastsaved= MODELLENTIME');
%     fs = cat(1,fs,'           distancesaved= DISTSAV');
%     fs = cat(1,fs,'        doit');
    fs = cat(1,fs,'    -fexport');
    fs = cat(1,fs,'       outfile= temp_data/efieldsx');
    fs = cat(1,fs,'       what= e-fields');
    fs = cat(1,fs,'       bbylow=0'); 
    fs = cat(1,fs,'       bbyhigh=0'); 
    fs = cat(1,fs,'       firstsaved= FIRSTSAV');
    fs = cat(1,fs,'       lastsaved= MODELLENTIME');
    fs = cat(1,fs,'       distancesaved= DISTSAV');
    fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       outfile= temp_data/efieldsy');
    fs = cat(1,fs,'       bbylow=-1E30');
    fs = cat(1,fs,'       bbyhigh=1E30');
    fs = cat(1,fs,'       bbxlow=0');
    fs = cat(1,fs,'       bbxhigh=0');
    fs = cat(1,fs,'       doit');
        fs = cat(1,fs,'       doit');
    fs = cat(1,fs,'       outfile= temp_data/efieldsz');
    fs = cat(1,fs,'       bbxlow=-1E30');
    fs = cat(1,fs,'       bbxhigh=1E30');
    fs = cat(1,fs,'       bbzlow=0');
    fs = cat(1,fs,'       bbzhigh=0');
    fs = cat(1,fs,'       doit');
else
    fs = cat(1,fs,'# No movie requested... not storing additional files.');
end %if

fs = cat(1,fs,'-fdtd   ');
fs = cat(1,fs,'    doit');