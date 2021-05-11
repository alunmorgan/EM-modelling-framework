function GdfidL_write_pp_eigenmode_input_file(log, pp_type, slices, subsections, scale)
% Writes the postprocessing input file for an eigenmode simulation.
%
% n_modes_range(list): the modes numbers to consider.
% log (struct): data extracted from postprocessing log file.
% slices(): selects which planes to plot
%
% example: GdfidL_write_pp_s_param_input_file(log '3')

ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat(['    infile= data_link/',pp_type]));
ov = cat(1,ov,strcat('    scratchbase = temp_scratch/'));
ov = cat(1,ov,'    2dplotopts = -geometry 1440x900');
ov = cat(1,ov,'    plotopts = -geometry 1440x900');
ov = cat(1,ov,'    nrofthreads = 40');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-3darrowplot');
ov = cat(1,ov,'    onlyplotfiles = no');
ov = reset_bounding_box(ov, log);
ov = cat(1,ov,['	 scale = ', scale]);
ov = cat(1,ov,'	 fonmaterials = yes');
if strcmpi(pp_type, 'eigenmode')
    ov = cat(1,ov,'    quantity = e');
elseif strcmpi(pp_type, 'lossy_eigenmode')
    ov = cat(1,ov,'    quantity = ere');
end %if
for jrd = 1:length(log.eigenmodes.nums)
    ov = cat(1,ov,'	 lenarrows= 1E-6');
    for kse = 1:length(subsections)
        ov = set_bounding_box(ov, subsections{kse});
        ov = cat(1,ov,'	 eyeposition = ( -1.0, -2.30, 0.50 )');
        ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/',pp_type,num2str(jrd),'subsection_',num2str(kse),'_plot.ps']);
        ov = cat(1,ov,['    solution = ', num2str(log.eigenmodes.nums(jrd))]);
        ov = cat(1,ov,'    doit');
        ov = cat(1,ov,'	 eyeposition = ( -2.30, -1.0, 0.50 )');
        ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/',pp_type,num2str(jrd),'subsection_',num2str(kse),'_x_plot.ps']);
        ov = cat(1,ov,'    doit');
        ov = cat(1,ov,'	 eyeposition = ( -1.0, -2.30, 0.50 )');
        ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/',pp_type,num2str(jrd),'subsection_',num2str(kse),'_y_plot.ps']);
        ov = cat(1,ov,'    doit');
        ov = cat(1,ov,'	 eyeposition = ( -1.0, ,0.50 ,-2.30 )');
        ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/',pp_type,num2str(jrd),'subsection_',num2str(kse),'_z_plot.ps']);
        ov = cat(1,ov,'    doit');
    end %for
    ov = cat(1,ov,'	 lenarrows= 1');
    ov = reset_bounding_box(ov, log);
    ov = cat(1,ov,'	 eyeposition = ( -1.0, -2.30, 0.50 )');
    ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/',pp_type,num2str(jrd),'_plot.ps']);
    ov = cat(1,ov,['    solution = ', num2str(log.eigenmodes.nums(jrd))]);
    ov = cat(1,ov,'    doit');
    for ndw = 1:size(slices,1)
        plane_loc = regexprep(slices{ndw,2}, ' ', '');
        plane_loc = regexprep(plane_loc, '+', '_plus_');
        plane_loc = regexprep(plane_loc, '-', '_minus_');
        if strcmp(slices{ndw, 1},'z')
            ov = reset_bounding_box(ov, log);
            ov = cat(1,ov,['	 bbzlow = ', slices{ndw, 2}]);
            ov = cat(1,ov,['    solution = ', num2str(log.eigenmodes.nums(jrd))]);
            ov = cat(1,ov,'	 eyeposition = ( -1.0, ,0.50 ,-2.30 )');
            ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/', pp_type, num2str(jrd),'_z_cut_',plane_loc,'_plot.ps']);
            ov = cat(1,ov,'    doit');
            ov = cat(1,ov,'	 eyeposition = ( 0, ,0 ,-1 )');
            ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/', pp_type, num2str(jrd),'_z_cut_',plane_loc,'_flat_plot.ps']);
            ov = cat(1,ov,'    doit');
        elseif strcmp(slices{ndw, 1},'x')
            ov = reset_bounding_box(ov, log);
            ov = cat(1,ov,['	 bbxlow = ', slices{ndw, 2}]);
            ov = cat(1,ov,['    solution = ', num2str(log.eigenmodes.nums(jrd))]);
            ov = cat(1,ov,'	 eyeposition = ( -2.30, -1.0, 0.50 )');
            ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/', pp_type, num2str(jrd),'_x_cut_',plane_loc,'_plot.ps']);
            ov = cat(1,ov,'    doit');
            ov = cat(1,ov,'	 eyeposition = ( -1, 0, 0 )');
            ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/', pp_type, num2str(jrd),'_x_cut_',plane_loc,'_flat_plot.ps']);
            ov = cat(1,ov,'    doit');
        elseif strcmp(slices{ndw, 1},'y')
            ov = reset_bounding_box(ov, log);
            ov = cat(1,ov,['	 bbylow = ', slices{ndw, 2}]);
            ov = cat(1,ov,['    solution = ', num2str(log.eigenmodes.nums(jrd))]);
            ov = cat(1,ov,'	 eyeposition = ( -1.0, -2.30, 0.50 )');
            ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/', pp_type, num2str(jrd),'_y_cut_',plane_loc,'_plot.ps']);
            ov = cat(1,ov,'    doit');
            ov = cat(1,ov,'	 eyeposition = ( 0, -1, 0 )');
            ov = cat(1,ov, ['	 plotopts = -colorps -o temp_scratch/', pp_type, num2str(jrd),'_y_cut_',plane_loc,'_flat_plot.ps']);
            ov = cat(1,ov,'    doit');
        end %if        
    end %if
end %for
% end %for
%
% ov = cat(1,ov,'-lineplot');
% ov = cat(1,ov,'    onlyplotfiles = yes');
% ov = cat(1,ov,'    quantity = e');
% ov = cat(1,ov,'    component = z');
% ov = cat(1,ov,'    direction = z');
% ov = cat(1,ov,'    startpoint = (0,0,@zmin)');
% for jrd = 1:n_modes
%     ov = cat(1,ov, ['	 plotopts = -colorps -o eigenmode',num2str(jrd),'_z_field_plot.ps']);
%     ov = cat(1,ov,['    solution = ',num2str(jrd)]);
%     ov = cat(1,ov,'    doit');
% end
if strcmpi(pp_type, 'eigenmode')
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
end %if

% Run macros
if strcmpi(pp_type, 'eigenmode')
    for hd = 1:length(log.eigenmodes.nums)
        ov = cat(1,ov,['call QValue(',num2str(hd),')']);
        ov = cat(1,ov,['call rshunt(',num2str(hd),')']');
    end% for
end %if

write_out_data( ov, fullfile('pp_link',pp_type,['model_', pp_type, '_post_processing']))

end %function

function ov = reset_bounding_box(ov, log)
ov = cat(1,ov,['	 bbxhigh = ',num2str(log.mesh_extent_xhigh)]);
ov = cat(1,ov,['	 bbxlow = ',num2str(log.mesh_extent_xlow)]);
ov = cat(1,ov,['	 bbyhigh = ',num2str(log.mesh_extent_yhigh)]);
ov = cat(1,ov,['	 bbylow = ',num2str(log.mesh_extent_ylow)]);
ov = cat(1,ov,['	 bbzhigh = ',num2str(log.mesh_extent_zhigh)]);
ov = cat(1,ov,['	 bbzlow = ',num2str(log.mesh_extent_zlow)]);
end % function

function ov = set_bounding_box(ov, subsection)
ov = cat(1,ov,['	 bbxhigh = ',num2str(subsection.xmax)]);
ov = cat(1,ov,['	 bbxlow = ',num2str(subsection.xmin)]);
ov = cat(1,ov,['	 bbyhigh = ',num2str(subsection.ymax)]);
ov = cat(1,ov,['	 bbylow = ',num2str(subsection.ymin)]);
ov = cat(1,ov,['	 bbzhigh = ',num2str(subsection.zmax)]);
ov = cat(1,ov,['	 bbzlow = ',num2str(subsection.zmin)]);
end % function