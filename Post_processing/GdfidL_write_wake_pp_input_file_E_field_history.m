function GdfidL_write_wake_pp_input_file_E_field_history(start)
% Writes the post processing input file.

ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat('    infile= data_link/wake'));
ov = cat(1,ov,['    scratchbase = temp_scratch/field_history/',num2str(start),'/']);
ov = cat(1,ov,'    2dplotopts = -geometry 1024x768');
ov = cat(1,ov,'    plotopts = -geometry 1024x768');
ov = cat(1,ov,'    nrofthreads = 42');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-fmonitor');
ov = cat(1,ov,['    do pscan = ', num2str(start),', ', num2str(start + 2999)]);
ov = cat(1,ov,'        symbol = Efieldat_P(pscan)');
ov = cat(1,ov,'        freqdata = no');
ov = cat(1,ov,'        onlyplotfiles = yes');
ov = cat(1,ov,'        component = x');
ov = cat(1,ov,'        doit');
ov = cat(1,ov,'        component = y');
ov = cat(1,ov,'        doit');
ov = cat(1,ov,'        component = z');
ov = cat(1,ov,'        doit');
ov = cat(1,ov,'    enddo');
ov = cat(1,ov,'');
ov = cat(1,ov,'-general');

write_out_data( ov, ['pp_link/wake/model_wake_post_processing_EfieldHistory',num2str(start)] )
