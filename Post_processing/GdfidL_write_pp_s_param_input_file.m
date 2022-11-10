function ov = GdfidL_write_pp_s_param_input_file(data_loc)
% Writes the post processing input file for a single port S-parameter.
% 
% example: GdfidL_write_pp_s_param_input_file(data_loc)
ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat('    infile= ', data_loc));
ov = cat(1,ov,strcat('    scratchbase = temp_scratch/'));
ov = cat(1,ov,'    2dplotopts = -geometry 1024x768');
ov = cat(1,ov,'    plotopts = -geometry 1024x768');
ov = cat(1,ov,'    nrofthreads = 40');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-sparameter');
ov = cat(1,ov,'    ports = all');
ov = cat(1,ov,'    modes = all');
ov = cat(1,ov,'    freqdata = yes');
ov = cat(1,ov,'    windowed = no');
ov = cat(1,ov,'    magnitude = yes');
ov = cat(1,ov,'    tfirst = 0');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    doit');
