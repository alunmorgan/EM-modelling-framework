function GdfidL_write_pp_shunt_input_file(freq)
% Writes the postprocessing input file for an shunt simulation.
% 
% freq is the frequency the simulation was done at.
%
% example: GdfidL_write_pp_shunt_input_file(freq)


ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat(['    infile= data_link/shunt/', freq]));
ov = cat(1,ov,strcat('    scratchbase = temp_scratch/'));
ov = cat(1,ov,'    2dplotopts = -geometry 1024x768');
ov = cat(1,ov,'    plotopts = -geometry 1024x768');
ov = cat(1,ov,'    nrofthreads = 25');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-lintegral');
ov = cat(1,ov,'    quantity = ef_e');
ov = cat(1,ov,'	   component = z');
ov = cat(1,ov,'	   direction = z');
ov = cat(1,ov,'    startpoint = (0, 0, @zmin)');
ov = cat(1,ov,'	   solution = 1');
ov = cat(1,ov,'	   doit');
ov = cat(1,ov,'-lintegral');
ov = cat(1,ov,'    quantity = ef_e');
ov = cat(1,ov,'	   component = z');
ov = cat(1,ov,'	   direction = z');
ov = cat(1,ov,'    startpoint = (0, 0, @zmin)');
ov = cat(1,ov,'	   solution = 2');
ov = cat(1,ov,'	   doit');

% ov = cat(1,ov,'-3darrowplot');
% ov = cat(1,ov,'    onlyplotfiles = no');
% ov = cat(1,ov,['	 bbzhigh = ',num2str(pp_inputs.logs.shunt.mesh_extent_zhigh),' - 200e-3']);
% ov = cat(1,ov,['	 bbzlow = ',num2str(pp_inputs.logs.shunt.mesh_extent_zlow),' + 200e-3']);
% ov = cat(1,ov,'	 bbyhigh = 0');
% ov = cat(1,ov,'	 bbylow = 0');
% ov = cat(1,ov,'	 eyeposition = (1E-8, 1, 1E-8)');
% ov = cat(1,ov,'	 nlscale= yes');
% ov = cat(1,ov,'	 nlexp=1');
% ov = cat(1,ov,'	 scale = 5');
% ov = cat(1,ov,'	 fonmaterials = yes');
% ov = cat(1,ov,'    quantity = ef_e');
% ov = cat(1,ov, ['	 plotopts = -colorps -o shunt',freq,'_1_x_cut_plot.ps']);
% ov = cat(1,ov,'    solution = 1');
% ov = cat(1,ov,'    doit');
% ov = cat(1,ov, ['	 plotopts = -colorps -o shunt',freq,'_2_x_cut_plot.ps']);
% ov = cat(1,ov,'    solution = 2');
% ov = cat(1,ov,'    doit');

% ov = cat(1,ov,'	 bbzhigh = 30E-3');
% ov = cat(1,ov,'	 bbzlow = -30E-3');
% ov = cat(1,ov,'	 bbxlow = -30E-3');
% ov = cat(1,ov,'	 bbxhigh = 30E-3');
% ov = cat(1,ov, ['	 plotopts = -colorps -o shunt',freq,'_1_x_cut_cavity_plot.ps']);
% ov = cat(1,ov,'    solution = 1');
% ov = cat(1,ov,'    doit');
% 
% ov = cat(1,ov,'	 bbzhigh = 30E-3');
% ov = cat(1,ov,'	 bbzlow = -30E-3');
% ov = cat(1,ov,'	 bbxlow = -30E-3');
% ov = cat(1,ov,'	 bbxhigh = 30E-3');
% ov = cat(1,ov, ['	 plotopts = -colorps -o shunt',freq,'_2_x_cut_cavity_plot.ps']);
% ov = cat(1,ov,'    solution = 2');
% ov = cat(1,ov,'    doit');
% 
% ov = cat(1,ov,'	 scale = 2.5');
% ov = cat(1,ov,'	 bbzhigh = 0');
% ov = cat(1,ov,['	 bbzlow = ',num2str(pp_inputs.logs.shunt.mesh_extent_zlow),' + 200e-3']);
% ov = cat(1,ov,'	 bbxlow = 0');
% ov = cat(1,ov,['	 bbxhigh = 80e-3',]);
% ov = cat(1,ov, ['	 plotopts = -colorps -o shunt',freq,'_1_x_cut_wg_plot.ps']);
% ov = cat(1,ov,'    solution = 1');
% ov = cat(1,ov,'    doit');
% 
% ov = cat(1,ov,'	 bbzhigh = 0');
% ov = cat(1,ov,['	 bbzlow = ',num2str(pp_inputs.logs.shunt.mesh_extent_zlow),' + 200e-3']);
% ov = cat(1,ov,'	 bbxlow = 0');
% ov = cat(1,ov,['	 bbxhigh = 70e-3']);
% ov = cat(1,ov, ['	 plotopts = -colorps -o shunt',freq,'_2_x_cut_wg_plot.ps']);
% ov = cat(1,ov,'    solution = 2');
% ov = cat(1,ov,'    doit');

% ov = cat(1,ov,'-lineplot');
% ov = cat(1,ov,'    onlyplotfiles = no');
% ov = cat(1,ov,'    quantity = ef_e');
% ov = cat(1,ov,'    component = z');
% ov = cat(1,ov,'    direction = z');
% ov = cat(1,ov,'    startpoint = (0,75e-3,@zmin)');
% ov = cat(1,ov, ['	 2dplotopts = -colorps -o shunt',freq,'_1_x_cut_coax_plot.ps']);
% ov = cat(1,ov,'    solution = 1');
% ov = cat(1,ov,'    doit');
% 
% ov = cat(1,ov, ['	 2dplotopts = -colorps -o shunt',freq,'_2_x_cut_coax_plot.ps']);
% ov = cat(1,ov,'    solution = 2');
% ov = cat(1,ov,'    doit');

write_out_data( ov, ['pp_link/shunt/model_shunt',freq ,'_post_processing'] )
