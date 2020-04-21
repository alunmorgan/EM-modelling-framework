function GdfidL_write_pp_eigenmode_lossy_input_file(n_modes, pp_inputs)
% Writes the postprocessing input file for an lossy eigenmode simulation.
% 
% n_modes is the number of modes to consider.
% pp_inputs is a structure containing the various settings for the
% postprocessing.
%
% example: GdfidL_write_pp_s_param_input_file('3')
 pipe_length = get_pipe_length_from_defs(pp_inputs);

ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat('    infile= data_link/eigenmode_lossy'));
ov = cat(1,ov,strcat('    scratchbase = temp_scratch/'));
ov = cat(1,ov,'    2dplotopts = -geometry 1024x768');
ov = cat(1,ov,'    plotopts = -geometry 1024x768');
ov = cat(1,ov,'    nrofthreads = 25');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-3darrowplot');
ov = cat(1,ov,'    onlyplotfiles = no');
ov = cat(1,ov,['	 bbzhigh = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_zhigh),' - ',num2str(pipe_length)]);
ov = cat(1,ov,['	 bbzlow = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_zlow),' + ',num2str(pipe_length)]);
ov = cat(1,ov,'	 roty= -90');
ov = cat(1,ov,'	 rotz=-90');
ov = cat(1,ov,'	 nlscale= yes');
ov = cat(1,ov,'	 nlexp=1');
ov = cat(1,ov,'	 scale = 5');
ov = cat(1,ov,'	 fonmaterials = yes');
ov = cat(1,ov,'    quantity = e');
for jrd = 1:n_modes
    ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_plot.ps']);
    ov = cat(1,ov,['    solution = ',num2str(jrd)]);
    ov = cat(1,ov,'    doit');
end
ov = cat(1,ov,'	 bbzlow = 0');
ov = cat(1,ov,'	 bbzhigh = 0');
ov = cat(1,ov,'	 scale = 2');
ov = cat(1,ov,'	 eyeposition = (1, 1E-8, 1E-8)');
for jrd = 1:n_modes
    ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_z_cut_plot.ps']);
    ov = cat(1,ov,['    solution = ',num2str(jrd)]);
    ov = cat(1,ov,'    doit');
end
ov = cat(1,ov,'	 bbzlow = 22.5e-3');
ov = cat(1,ov,'	 bbzhigh = 22.5E-3');
ov = cat(1,ov,'	 scale = 2');
ov = cat(1,ov,'	 eyeposition = (1, 1E-8, 1E-8)');
for jrd = 1:n_modes
    ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_z_cut_wg_entrance_plot.ps']);
    ov = cat(1,ov,['    solution = ',num2str(jrd)]);
    ov = cat(1,ov,'    doit');
end
ov = cat(1,ov,['	 bbzhigh = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_zhigh),' - ',num2str(pipe_length)]);
ov = cat(1,ov,['	 bbzlow = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_zlow),' + ',num2str(pipe_length)]);
ov = cat(1,ov,'	 bbxlow = 0');
ov = cat(1,ov,'	 bbxhigh = 0');
ov = cat(1,ov,'	 scale = 5');
ov = cat(1,ov,'	 eyeposition = (1E-8, 1, 1E-8)');
for jrd = 1:n_modes
    ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_x_cut_plot.ps']);
    ov = cat(1,ov,['    solution = ',num2str(jrd)]);
    ov = cat(1,ov,'    doit');
end

ov = cat(1,ov,['	 bbzhigh = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_zhigh),' - ',num2str(pipe_length)]);
ov = cat(1,ov,['	 bbzlow = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_zlow),' + ',num2str(pipe_length)]);
ov = cat(1,ov,['	 bbxlow = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_xlow)]);
ov = cat(1,ov,['	 bbxhigh = ',num2str(pp_inputs.logs.eigenmode.mesh_extent_xhigh)]);
ov = cat(1,ov,'	 bbylow = 0');
ov = cat(1,ov,'	 bbyhigh = 0');
ov = cat(1,ov,'	 scale = 5');
ov = cat(1,ov,'	 eyeposition = (1E-8, 1E-8, 1)');
for jrd = 1:n_modes
    ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_y_cut_plot.ps']);
    ov = cat(1,ov,['    solution = ',num2str(jrd)]);
    ov = cat(1,ov,'    doit');
end

ov = cat(1,ov,'-lineplot');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    quantity = e');
ov = cat(1,ov,'    component = z');
ov = cat(1,ov,'    direction = z');
ov = cat(1,ov,'    startpoint = (0,0,@zmin)');
for jrd = 1:n_modes
    ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_z_field_plot.ps']);
    ov = cat(1,ov,['    solution = ',num2str(jrd)]);
    ov = cat(1,ov,'    doit');
end
% Macro to calculate the Q from complex fields
ov = cat(1,ov,'macro perQValue');
ov = cat(1,ov,'  pushflags, noprompt, nomenu, nomessage');
ov = cat(1,ov,'  define(perQValue_PATH, @path)               # remember current section');
ov = cat(1,ov,'  -base                                       # goto the base of the branch-tree');
ov = cat(1,ov,'  -energy                                     # compute stored energy');
ov = cat(1,ov,'      quantity= hre                           # ... we dont need to compute the');
ov = cat(1,ov,'      solution= @arg1                         #     energy in the electric field');
ov = cat(1,ov,'      doit                                    #     -- it has to be the same');
ov = cat(1,ov,'# echo *** W_h of real part is @henergy');
ov = cat(1,ov,'      define(hre_energy, @henergy)');
ov = cat(1,ov,'      quantity= him');
ov = cat(1,ov,'      doit');
ov = cat(1,ov,'      define(him_energy, @henergy)');
ov = cat(1,ov,'define(htot_energy, eval(hre_energy+him_energy) )');
ov = cat(1,ov,'  -wlosses                                    # Wall-losses');
ov = cat(1,ov,'      quantity= hre, doit');
ov = cat(1,ov,'      define(hre_metalpower, @metalpower)');
ov = cat(1,ov,'      quantity= him, doit');
ov = cat(1,ov,'      define(him_metalpower, @metalpower)');
ov = cat(1,ov,'      define(htot_metalpower, eval(hre_metalpower+him_metalpower))');
ov = cat(1,ov,'# echo *** total h-Energy   is htot_energy');
ov = cat(1,ov,'# echo *** total metalpower is htot_metalpower');
ov = cat(1,ov,'  define(perQValue_value, eval(2*@pi*@frequency*2*htot_energy/htot_metalpower))');
ov = cat(1,ov,'  echo');
ov = cat(1,ov,'  echo *** mode number       is @arg1');
ov = cat(1,ov,'  echo *** frequency         is @frequency {Hz}');
ov = cat(1,ov,'  echo *** QValue            is perQValue_value {1}');
ov = cat(1,ov,'# echo return path is : perQValue_PATH');
ov = cat(1,ov,'  perQValue_PATH                              # back to where we came from ...');
ov = cat(1,ov,'  undefine(perQValue_PATH)');
ov = cat(1,ov,'  popflags');
ov = cat(1,ov,'endmacro');
% Macro to calculate the Q from real fields
ov = cat(1,ov,'macro QValue');
ov = cat(1,ov,'  pushflags, noprompt, nomenu, nomessage');
ov = cat(1,ov,'  define(QValue_PATH, @path)                  # remember current section');
ov = cat(1,ov,'  -base                                       # goto the base of the branch-tree');
ov = cat(1,ov,'  -energy                                     # compute stored energy');
ov = cat(1,ov,'      quantity= h                             # ... we dont need to compute the');
ov = cat(1,ov,'      solution= @arg1                         #     energy in the electric field');
ov = cat(1,ov,'      doit                                    #     -- it has to be the same');
ov = cat(1,ov,'  -wlosses                                    # Wall-losses');
ov = cat(1,ov,'      doit');
ov = cat(1,ov,' echo');
ov = cat(1,ov,'echo *** h-Energy   is @henergy');
ov = cat(1,ov,'echo *** metalpower is @metalpower');
ov = cat(1,ov,'  return');
ov = cat(1,ov,'  define(QValue_value, eval(2*@pi*@frequency*2*@henergy/@metalpower))');
ov = cat(1,ov,'  echo *** mode number       is @arg1');
ov = cat(1,ov,'  echo *** frequency         is @frequency {Hz}');
ov = cat(1,ov,'  echo *** QValue            is QValue_value {1}');
ov = cat(1,ov,'# echo return path is : QValue_PATH');
ov = cat(1,ov,'  QValue_PATH                                 # back to where we came from ...');
ov = cat(1,ov,'  undefine(QValue_PATH)');
ov = cat(1,ov,'  popflags');
ov = cat(1,ov,'endmacro');

% Macro to calulate the R/Q
ov = cat(1,ov,'macro rshunt');
ov = cat(1,ov,'  pushflags, noprompt, nomenu, nomessage');
ov = cat(1,ov,'  define(rshunt_PATH, @path)                # remember current section');
ov = cat(1,ov,'  -base                                     # goto the base of the branch-tree');
ov = cat(1,ov,'  -energy                                   # compute stored energy');
ov = cat(1,ov,'      quantity= e                           # ... we dont need to compute the');
ov = cat(1,ov,'      solution= @arg1                       #     energy in the magnetic field');
ov = cat(1,ov,'      doit                                  #     -- it has to be the same');
ov = cat(1,ov,'# echo *** W_e is @eenergy');
ov = cat(1,ov,'  return');
ov = cat(1,ov,'  -lintegral                                # accelerating voltage');
ov = cat(1,ov,'      direction= z, component= z');
ov = cat(1,ov,'      startpoint= (0,0, @zmin)');
ov = cat(1,ov,'      length= auto');
ov = cat(1,ov,'      doit');
ov = cat(1,ov,'# echo *** vabs is @vabs');
ov = cat(1,ov,'  return');
ov = cat(1,ov,'  define(rshunt_value_a, eval(@vabs **2/(2*@pi*@frequency*(2*2*@eenergy))))');
ov = cat(1,ov,'  define(rshunt_value_r, eval(@vreal**2/(2*@pi*@frequency*(2*2*@eenergy))))');
ov = cat(1,ov,'  define(rshunt_value_i, eval(@vimag**2/(2*@pi*@frequency*(2*2*@eenergy))))');
ov = cat(1,ov,'  echo');
ov = cat(1,ov,'  echo *** mode number         is @arg1');
ov = cat(1,ov,'  echo *** frequency           is @frequency {Hz}');
ov = cat(1,ov,'  echo ***');
ov = cat(1,ov,'  echo *** shunt impedances as computed from | U * conjg(U) | :');
ov = cat(1,ov,'  echo *** Shunt Impedance/Q   is rshunt_value_a {Ohms}');
ov = cat(1,ov,'  echo *** Shunt Impedance/Q/m is eval(rshunt_value_a/@length) {Ohms/m}');
ov = cat(1,ov,'  echo ***');
ov = cat(1,ov,'  echo *** shunt impedances as computed from | Re(U) * Re(U) | :');
ov = cat(1,ov,'  echo *** Shunt Impedance/Q   is rshunt_value_r {Ohms}');
ov = cat(1,ov,'  echo *** Shunt Impedance/Q/m is eval(rshunt_value_r/@length) {Ohms/m}');
ov = cat(1,ov,'  echo ***');
ov = cat(1,ov,'  echo *** shunt impedances as computed from | Im(U) * Im(U) | :');
ov = cat(1,ov,'  echo *** Shunt Impedance/Q   is rshunt_value_i {Ohms}');
ov = cat(1,ov,'  echo *** Shunt Impedance/Q/m is eval(rshunt_value_i/@length) {Ohms/m}');
ov = cat(1,ov,' ');
ov = cat(1,ov,'## echo return path is : rshunt_PATH');
ov = cat(1,ov,'  rshunt_PATH                               # back to where we came from ...');
ov = cat(1,ov,'  undefine(rshunt_PATH)');
ov = cat(1,ov,'## echo return path is : rshunt_PATH');
ov = cat(1,ov,'  popflags');
ov = cat(1,ov,'endmacro');


% Run macros
for hd = 1:n_modes
ov = cat(1,ov,['call QValue(',num2str(hd),')']);
ov = cat(1,ov,['call rshunt(',num2str(hd),')']');
end



write_out_data( ov, 'pp_link/model_eigenmode_lossy_post_processing' )
% fid = fopen('pp_link/model_eigenmode_post_processing','wt');
% for be = 1:length(ov)
%     mj = char(ov{be});
%     fwrite(fid,mj);
%     fprintf(fid,'\n','');
% end
% fclose(fid);