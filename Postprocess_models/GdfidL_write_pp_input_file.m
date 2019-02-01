function tfirst = GdfidL_write_pp_input_file(log, pipe_length)
% Writes the post processing input file.
%
% log is a structure containing the information extracted from the log
% files.
% pipe_length is the length of the beam pipe extensions used in the model
%
% Assume that the 1st port in the list is the beam input port.
% the second is the beam output port, and all the others are signal ports.
%
% Example: tfirst = GdfidL_write_pp_input_file(log, pipe_length)


%determine the values for tfirst.
% 9 sigmas is enough for the input charge to have fully passed through the
% port. If you do not leave enough time then there is an enhancement in
% what is accounted for. And a sharp pling which messes up the FFT later in
% the processing chain.
tfirst(1) = log.beam_sigma*9 ./299792458; % beam entering the model.
tfirst(2) = ( log.mesh_extent_zhigh - log.mesh_extent_zlow + log.beam_sigma .* 9) ./ 299792458; 
for ek = 3:length(log.port_name)
    % HAVING ODD BEHAVIOR FOR DDBA BUTTONS WITH LARGE SIGNAL WHILE THE BEAM
    % IS PASSING THROUGH THE PORTS.
    % FOR NOW SET TO tfirst(2)
    tfirst(ek) =tfirst(2);
end

ov{1} = '';
ov = cat(1,ov,'-general');
ov = cat(1,ov,strcat('    infile= data_link/wake'));
ov = cat(1,ov,strcat('    scratchbase = temp_scratch/'));
ov = cat(1,ov,'    2dplotopts = -geometry 1024x768');
ov = cat(1,ov,'    plotopts = -geometry 1024x768');
ov = cat(1,ov,'    nrofthreads = 25');
ov = cat(1,ov,'    ');
ov = cat(1,ov,'-wakes');
ov = cat(1,ov,'    watq = yes');
ov = cat(1,ov,'    awtatq = yes');
ov = cat(1,ov,'    impedances = yes');
% ov = cat(1,ov,'    peroffset = yes');
% ov = cat(1,ov,'    window = no');
% ov = cat(1,ov,'    wxatxy = (-3e-3, 3e-3)');
% ov = cat(1,ov,'    wyatxy = (-3e-3, 3e-3)');
% ov = cat(1,ov,'    wxatxy = (3e-3, 3e-3)');
% ov = cat(1,ov,'    wyatxy = (3e-3, 3e-3)');
ov = cat(1,ov,'    showchargemax = yes');
ov = cat(1,ov,'    onlyplotfiles = yes');
% ov = cat(1,ov,'    watsfiles = yes');
ov = cat(1,ov,'    doit');
ov = cat(1,ov,'');
ov = cat(1,ov,'-pmonitor');
ov = cat(1,ov,'    symbol = TEIS');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    doit');
ov = cat(1,ov,'');
ov = cat(1,ov,'-pmonitor');
ov = cat(1,ov,'    symbol = TEC');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    doit');
ov = cat(1,ov,'');
for lae = 1:length(log.port_name)
ov = cat(1,ov,'-sparameter, showeh=no');
ov = cat(1,ov,strcat('    ports = ', log.port_name{lae}));
ov = cat(1,ov,'    modes = all');
ov = cat(1,ov,'    timedata = yes');
ov = cat(1,ov,'    ignoreexc = yes');
ov = cat(1,ov,strcat('    tfirst = ',num2str(tfirst(lae))));
%ov = cat(1,ov,strcat('    tfirst = 0'));
ov = cat(1,ov,'    tintpower = yes');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    doit');
end
% tk = 1;
% for kes = log.mesh_extent_zlow + pipe_length:50e-3:log.mesh_extent_zhigh - pipe_length
% cut_planes = {'z',num2str(kes)};
% fs = gdf_loss_plots_construction(cut_planes, tk, pipe_length);
% tk = tk +1;
% ov = cat(1,ov,fs);
% end

write_out_data( ov, 'pp_link/wake/model_wake_post_processing' )