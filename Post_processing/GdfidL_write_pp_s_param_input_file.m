function pp_output_name = GdfidL_write_pp_s_param_input_file(data_loc, pp_loc, scratch_dir)
% Writes the post processing input file for a single port S-parameter.
%
% example: GdfidL_write_pp_s_param_input_file(data_loc)
ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat('    infile= ', data_loc));
ov = cat(1,ov,strcat(['    scratchbase = ',scratch_dir,'/']));
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

% find the port number of the excitation
excite = regexp(data_loc, 'port_(.*)_excitation', 'tokens');
excite = excite{1}{1};
s_set = regexp(data_loc, 'set_(.*)_port_.*_excitation', 'tokens');
s_set = s_set{1}{1};
mkdirtree(pp_loc)
pp_output_name = fullfile(pp_loc ,['model_s_param_set_',s_set, '_',excite,'_post_processing_input_file']);
write_out_data(ov, pp_output_name )