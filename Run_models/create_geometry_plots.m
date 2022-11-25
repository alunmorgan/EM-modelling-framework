function model_file = create_geometry_plots(modelling_inputs, out_loc)
% Write the geometry plotting part of the gdf file.

model_file = {'###################################################'};

model_file = cat(1, model_file,'-volumeplot');
model_file = cat(1, model_file, 'rotx=-90');
model_file = cat(1, model_file, 'roty=180');
model_file = cat(1, model_file, 'rotz=180');
eyepos.twodxeyepos = '   eyeposition= (-1, 0, 0)';
eyepos.twodyeyepos = '   eyeposition= (0, 0, 1)';
eyepos.twodzeyepos = '   eyeposition= (0, -1, 0)';
eyepos.threedxeyepos = '   eyeposition= (-2.3, 1, 0.5)';
eyepos.threedyeyepos = '   eyeposition= (-0.5, 1, 2.3)';
eyepos.threedzeyepos = '   eyeposition= (-1, 2.3, 0.5)';

model_file_3Dvols = create_3D_volume_plots(modelling_inputs, eyepos, '', out_loc);
model_file_subvols = create_subvolume_plots(modelling_inputs, eyepos, '', out_loc);
model_file_2Dvols = create_2D_geometry_plots(modelling_inputs, eyepos, '', out_loc);
model_file_cutplots = create_cut_plot_plots (modelling_inputs, eyepos, '', out_loc);
model_file = cat(1, model_file, model_file_3Dvols);
model_file = cat(1, model_file, model_file_subvols);
model_file = cat(1, model_file, model_file_2Dvols);
model_file = cat(1, model_file, model_file_cutplots);
model_file = cat(1, model_file, '###################################################');





