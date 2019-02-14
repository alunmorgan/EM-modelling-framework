function fs = gdf_wake_header_construction(loc, name, npmls, num_threads, mesh, sigma,...
    beam_offset_x, beam_offset_y, wake_length, materials, material_labels)
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

% set bunch charge to 1E-9C. This couls be settable but I have a feeling
% that some later analysis assumes it is 1nC. Needs further investigation
% before changing it.
charge = '1E-9';

fs = {'###################################################'};
fs = cat(1,fs,'define(INF, 10000)');
fs = cat(1,fs,'define(LargeNumber, 1000)');
fs = cat(1,fs,['define(STPSZE, ',mesh,') # Step size of mesh']);
fs = cat(1,fs,['define(SIGMA, ',sigma,') # bunch length in mm']);
fs = cat(1,fs,['define(NPMLs, ',npmls,') # number of perfect matching layers used']);
fs = cat(1,fs,['define(CHARGE, ', charge,') # Bunch charge in C']);
fs = cat(1,fs,'define(vacuum, 0)');
fs = cat(1,fs,'define(PEC, 1)');
if ~isempty(materials)
    for ks = 1:length(materials)
        if ~strcmp(materials{ks}, 'PEC') && ~strcmp(materials{ks}, 'vacuum')
            fs = cat(1,fs,['define(',materials{ks},',',num2str(ks+2),')']) ;
        end
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
fs = cat(1,fs,['xposition= ', beam_offset_x]);
fs = cat(1,fs,['yposition= ', beam_offset_y]);
fs = cat(1,fs,'direction = beam_dir');
fs = cat(1,fs,['shigh=',wake_length]);
fs = cat(1,fs,'showdata= no');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'#Material definitions');
if ~isempty(materials)
    for ne = 1:length(materials)
        fs = cat(1,fs,generate_material_definitions_for_gdf(materials{ne}, material_labels{ne}));
    end
end
fs = cat(1,fs,'###################################################');