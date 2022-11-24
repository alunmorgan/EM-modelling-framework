function fs = gdf_s_param_header_construction(out_loc, scratch_loc, restart_files_loc, npmls, num_threads, mesh, mesh_scaling, materials, material_labels)
% Constructs the initial part of the gdf input file for GdfidL 
%
% fs is a cell array of tect to form part of the postprocessing input file.
% out_loc gives the location of the output files
% scratch_loc gives the location of the scratch files
% num_threads determines now many CPU threads to use.
% mesh is
% port_name is
% materials is
% material_labels is
%
% Example: fs = gdf_s_param_header_construction(loc, name, num_threads, mesh, port_name, materials, material_labels)

fs = {'###################################################'};
fs = cat(1,fs,'define(INF, 10000)');
fs = cat(1,fs,'define(LargeNumber, 1000)');
fs = cat(1,fs,['define(STPSZE, ',num2str(mesh / mesh_scaling),') # Step size of mesh']);
fs = cat(1,fs,['define(NPMLs, ',npmls,') # number of perfectly matching layers']);
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
fs = cat(1,fs,['    outfile= ', out_loc]);
fs = cat(1,fs,['    scratch= ', scratch_loc]);
fs = cat(1,fs,['    nrofthreads= ', num_threads]);
fs = cat(1,fs,['    restartfiles = ',restart_files_loc]);
fs = cat(1,fs,'    t1restartfiles = 1440');
fs = cat(1,fs,'    dtrestartfiles = 1440');
fs = cat(1,fs,'    stopafterrestartfiles=1000000');
fs = cat(1,fs,'###################################################');
fs = cat(1,fs,'#Material definitions');
for ne = 1:length(materials)
fs = cat(1,fs,generate_material_definitions_for_gdf(materials{ne}, material_labels{ne}));
end
fs = cat(1,fs,'###################################################');