function fs = gdf_wake_header_construction(loc, name, num_threads, mesh, sigma,...
    wake_length, materials, material_labels)
% Constructs the initial part of the gdf input file for GdfidL 
%
% fs is 
% loc gives the location of the output files
% name is the name of the model.
% num threads determines now many CPU threads to use.
% mesh is
% sigma is
% wake_length is
% materials is
% material_labels is
%
% Example: fs = gdf_wake_header_construction(loc, name, num_threads, mesh, sigma, wake_length, materials, material_labels)


% TEMP knock out PEC from the list as it is already dealt with.
% there is probably a better place to put it. 
ind = find(strcmp(materials, 'PEC')==1);
materials(ind) = [];
material_labels(ind) = [];


fs = {'###################################################'};
fs = cat(1,fs,'define(INF, 10000)');
fs = cat(1,fs,'define(LargeNumber, 1000)');
fs = cat(1,fs,['define(STPSZE, ',mesh,') # Step size of mesh']);
fs = cat(1,fs,['define(SIGMA, ',sigma,') # bunch length in mm']);
fs = cat(1,fs,'define(CHARGE, 1e-9) # Bunch charge in C');
fs = cat(1,fs,'define(vacuum, 0)');
fs = cat(1,fs,'define(PEC, 1)');
for ks = 1:length(materials)
    if ~strcmp(materials{ks}, 'PEC') && ~strcmp(materials{ks}, 'vacuum')
   fs = cat(1,fs,['define(',materials{ks},',',num2str(ks+2),')']) ;
    end
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
fs = cat(1,fs,'    text()= sigma= SIGMA');
fs = cat(1,fs,'    text()= charge= CHARGE');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'-fdtd');
fs = cat(1,fs,'-lcharge');
fs = cat(1,fs,'charge= CHARGE ');
fs = cat(1,fs,'shape = gaussian');
fs = cat(1,fs,'sigma= SIGMA');
fs = cat(1,fs,'xposition= 0');
fs = cat(1,fs,'yposition= 0');
fs = cat(1,fs,'direction = beam_dir');
fs = cat(1,fs,['shigh=',wake_length]);
fs = cat(1,fs,'showdata= no');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'#Material definitions');
for ne = 1:length(materials)
fs = cat(1,fs,generate_material_definitions_for_gdf(materials{ne}, material_labels{ne}));
end
fs = cat(1,fs,'###################################################');