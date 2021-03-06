function ov = GdfidL_write_pp_s_param_input_file(s_set, excite)
% Writes the post processing input file for a single port S-parameter.
% 
% excite is a string representing a port number 
% for example '1'
%
% example: GdfidL_write_pp_s_param_input_file(excite)
ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat('    infile= data_link/s_parameter/set_', s_set,'_port_',excite,'_excitation'));
ov = cat(1,ov,strcat('    scratchbase = temp_scratch/'));
ov = cat(1,ov,'    2dplotopts = -geometry 1024x768');
ov = cat(1,ov,'    plotopts = -geometry 1024x768');
ov = cat(1,ov,'    nrofthreads = 32');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-sparameter');
ov = cat(1,ov,'    ports = all');
ov = cat(1,ov,'    modes = all');
ov = cat(1,ov,'    freqdata = yes');
ov = cat(1,ov,'    windowed = no');
ov = cat(1,ov,'    magnitude = yes');
ov = cat(1,ov,'    tfirst = 0');
% set the desired frequency step in the s-parameter to be 1MHz.
% This implies that the data will be zero padded if the ringdown is short.
ov = cat(1,ov,'    wantdf = 1e6');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    doit');

% fid = fopen(strcat('pp_link/model_s_param_',excite,'_post_processing'),'wt');
% for be = 1:length(ov)
%     mj = char(ov{be});
%     fwrite(fid,mj);
%     fprintf(fid,'\n','');
% end
% fclose(fid);