function fs = gdf_shunt_header_construction(loc, name, num_threads, mesh, materials, material_labels, frequency)
% Constructs the initial part of the gdf input file for GdfidL 
%
% fs is 
% loc gives the location of the output files
% name is the name of the model.
% num threads determines now many CPU threads to use.
% mesh is
% materials is
% material_labels is
% frequency is
%
% Example: fs = gdf_shunt_header_construction(loc, name, num_threads, mesh, materials, material_labels, frequency)

fs = {'###################################################'};
fs = cat(1,fs,'define(INF, 10000)');
fs = cat(1,fs,'define(LargeNumber, 1000)');
fs = cat(1,fs,['define(STPSZE, ',mesh,') # Step size of mesh']);
fs = cat(1,fs,'define(vacuum, 0)');
fs = cat(1,fs,'define(PEC, 1)');
for ks = 1:length(materials)
   fs = cat(1,fs,['define(',materials{ks},',',num2str(ks+2),')']) ;
end
fs = cat(1,fs,'define(beam_dir, +z)');
fs = cat(1,fs,' ');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'-general');
fs = cat(1,fs,['    outfile= ',loc, name,'_data/']);
fs = cat(1,fs,['    scratch= ',loc, name,'_scratch/']);
fs = cat(1,fs,['    nrofthreads= ', num_threads]);
fs = cat(1,fs,['    restartfiles = ',loc, name,'_restart/']);
fs = cat(1,fs,'    t1restartfiles = 720');
fs = cat(1,fs,'    dtrestartfiles = 360');
fs = cat(1,fs,'    stopafterrestartfiles=1000000');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'#Material definitions');
for ne = 1:length(materials)
fs = cat(1,fs,generate_material_definitions_for_gdf(materials{ne}, material_labels{ne}));
end
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,['define(FREQ, ', frequency,')']);
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'-pexcitation');
fs = cat(1,fs,'port= signal_1');
fs = cat(1,fs,'mode = 1');
fs = cat(1,fs,'frequency = FREQ');
fs = cat(1,fs,'amplitude = 1');
fs = cat(1,fs,['risetime = 1 / ', frequency]);
fs = cat(1,fs,'nextport');
fs = cat(1,fs,'port= signal_3');
fs = cat(1,fs,'mode = 1');
fs = cat(1,fs,'amplitude = 1');
fs = cat(1,fs,'phase = 0');
fs = cat(1,fs,'nextport');
fs = cat(1,fs,'port= signal_5');
fs = cat(1,fs,'mode = 1');
fs = cat(1,fs,'amplitude = 1');
fs = cat(1,fs,'phase = 0');
fs = cat(1,fs,'nextport');
fs = cat(1,fs,'port= signal_7');
fs = cat(1,fs,'mode = 1');
fs = cat(1,fs,'amplitude = 1');
fs = cat(1,fs,'phase = 0');
fs = cat(1,fs,'###################################################');