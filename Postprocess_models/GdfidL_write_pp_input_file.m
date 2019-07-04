function tfirst = GdfidL_write_pp_input_file(log, pipe_length, tqw_offset, ver)
% Writes the post processing input file.
%
% log is a structure containing the information extracted from the log
% files.
% pipe_length is the length of the beam pipe extensions used in the model
%
% tqw_offset is the offset to look at the transverse quadrupole wake at (in m)
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
ov = cat(1,ov,['    wxatxy = (-', tqw_offset,',', tqw_offset,')']);
ov = cat(1,ov,['    wyatxy = (-', tqw_offset,',', tqw_offset,')']);
ov = cat(1,ov,'    showchargemax = yes');
ov = cat(1,ov,'    onlyplotfiles = yes');
ov = cat(1,ov,'    watsfiles = yes');
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
    if ver > 170000 % output changed between versions.
        ov = cat(1,ov,'-sparameter, showeh=no');
    else
        ov = cat(1,ov,'-sparameter');
    end
    ov = cat(1,ov,strcat('    ports = ', log.port_name{lae}));
    ov = cat(1,ov,'    modes = all');
    ov = cat(1,ov,'    timedata = yes');
    ov = cat(1,ov,'    ignoreexc = yes');
    ov = cat(1,ov,strcat('    tfirst = ',num2str(tfirst(lae))));
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

% ov = cat(1,ov,'-fexport');
% field_type = 'e';
% for solution = 1:20
%     ov = cat(1,ov,['    symbol = ALL_', field_type, '_', num2str(solution)]);
%     ov = cat(1,ov,['    quantity = ALL_', field_type]);
%     ov = cat(1,ov,['    solution = ', num2str(solution)]);
%     sol = ['000000000',num2str(solution)];
%     ov = cat(1,ov,['    outfile = pp_link/wake/fexport_e_',sol(end-8:end)]);
%     ov = cat(1,ov,'    doit');
% end %for

% ov = cat(1,ov,'-2dmanygifs');
% ov = cat(1,ov,'   1stinfile = pp_link/wake/fexport_e_000000001');
% ov = cat(1,ov,'   outfiles = pp_link/wake/2Dgifs');
% ov = cat(1,ov,['    mpegfile = ',field_type,'_', num2str(solution), '_2D.mpeg']);
% ov = cat(1,ov,'    show = yes');
% ov = cat(1,ov,'    doit');
%
% ov = cat(1,ov,'-3dmanygifs');
% ov = cat(1,ov,'    1stinfile = pp_link/wake/fexport_e_000000001');
% ov = cat(1,ov,'   outfiles = pp_link/wake/3Dgifs');
% ov = cat(1,ov,['    mpegfile = ',field_type, '_', num2str(solution), '_3D.mpeg']);
% ov = cat(1,ov,'    show = yes');
% ov = cat(1,ov,'    doit');
% find the first stored field after the bunch has passed out of the
% structure
% model_length = log.mesh_extent_zhigh - log.mesh_extent_zlow;
% model_length_time = model_length ./ 3E8;
% field_start = find(log.field_data.ALL(:,1) > model_length_time, 1, 'first');

%  ov = cat(1,ov,'-3darrowplot');
%  ov = cat(1,ov,'    lenarrows= 2');
%  ov = cat(1,ov,'    scale= 4');
%  ov = cat(1,ov,'    fcolour= 7');
%  ov = cat(1,ov,'    arrows= 10');
%  ov = cat(1,ov,'    fonmat= yes');
%  ov = cat(1,ov,'    eyeposition= ( 1.0, 2.3, 0.5 )');
%  ov = cat(1,ov,'    roty=-90'); % make the beam horizontal
%  ov = cat(1,ov,'    rotx=180');
%  ov = cat(1,ov,'    logfonmat=yes');
%  ov = cat(1,ov,'    onlyplotfile= yes');
%  ov = cat(1,ov,'    quantity= ALL_e');
%  ov = cat(1,ov,'    bbylow=0'); % cutting in half
%  ov = cat(1,ov,'    #');
%  ov = cat(1,ov,'    # A first Pass through the Results.');
%  ov = cat(1,ov,'    # We want to know what the max-Values of the Fields are ,');
%  ov = cat(1,ov,'    # after the bunch has passed out of the structure.');
%  ov = cat(1,ov,'    # to not use autoscaling of the Arrow-Lengths and fonmat Patches.');
%  ov = cat(1,ov,'    #');
%  ov = cat(1,ov,'define( FARROWMAX, 1e-6 )');
%  ov = cat(1,ov,'define( FMAXONMAT, 1e-6 )');
% %  ov = cat(1,ov,['define( NUMSETS, ','50',' )']);
%  ov = cat(1,ov,['define( NUMSETS, ',num2str(length(log.field_data.ALL)),' )']);
%  ov = cat(1,ov,['    do ii= ',num2str(field_start),', NUMSETS']);
%  ov = cat(1,ov,'       solution= ii');
%  ov = cat(1,ov,'# Just to not occupy too much FileSpace.');
%  ov = cat(1,ov,'system( rm -f ./*-3D-Arrowplot.*.gld )');
%  ov = cat(1,ov,'       doit');
%  ov = cat(1,ov,'define( FARROWMAX, max( FARROWMAX, @farrowmax ) )');
%  ov = cat(1,ov,'define( FMAXONMAT, max( FMAXONMAT, @absfmax ) )');
%  ov = cat(1,ov,'    end do');
%  ov = cat(1,ov,'system( rm -f ./*-3D-Arrowplot.*.gld )');
%  ov = cat(1,ov,'    #');
%  ov = cat(1,ov,'    # The second pass through the Results.');
%  ov = cat(1,ov,'    # We now know the Max Values, and scale every Frame for the same');
%  ov = cat(1,ov,'    # Max Values that will occur in all the Frames.');
%  ov = cat(1,ov,'    #');
%  ov = cat(1,ov,'    fmaxonmat= FMAXONMAT / 2  # Slightly cheating.');
%  ov = cat(1,ov,'    fscale= 1.5 /  FARROWMAX');
%  ov = cat(1,ov,'    do ii= 1, NUMSETS');
%  ov = cat(1,ov,'       solution= ii');
%  ov = cat(1,ov,'       doit   # Create the gld-File.');
%  ov = cat(1,ov,'    end do');
%  ov = cat(1,ov,'    fonmat= no');
%  ov = cat(1,ov,'    jonmat= yes');
%  ov = cat(1,ov,'    # Now looking at power on the surfaces.');
%  ov = cat(1,ov,'    #');
%  ov = cat(1,ov,'    do ii= 1, NUMSETS');
%  ov = cat(1,ov,'       solution= ii');
%  ov = cat(1,ov,'       doit   # Create the gld-File.');
%  ov = cat(1,ov,'    end do');
if exist('data_link/wake/honmat-000000001.gz','file') == 2
    ov = cat(1,ov,' -3dmanygifs');
    ov = cat(1,ov,'    1stinfile= data_link/wake/honmat-000000001.gz');
    ov = cat(1,ov,'     outfiles= pp_link/wake/honmat3D');
    ov = cat(1,ov,'     what= logabs');
    ov = cat(1,ov,'     show=no');
    ov = cat(1,ov,'     zrot=-90'); % make the beam horizontal
    %  ov = cat(1,ov,'     xrot=180');
    ov = cat(1,ov,'     scale= 4');
    ov = cat(1,ov,'     mpegfile= ./temp.mpeg');
    %  ov = cat(1,ov,' define( PHI, 15 * @pi / 180 )');
    %  ov = cat(1,ov,' define( THETA, 150 * @pi / 180 )');
    %  ov = cat(1,ov,' eyeposition= ( sin(THETA) * cos( PHI ), sin(THETA) * sin(PHI), cos(THETA) )');
    ov = cat(1,ov,'     doit');
end %if
if exist('data_link/wake/efields-000000001.gz','file') == 2
    ov = cat(1,ov,' -2dmanygifs');
    ov = cat(1,ov,'    1stinfile= data_link/wake/efields-000000001.gz');
    ov = cat(1,ov,'      outfiles= pp_link/wake/E2DHy');
    ov = cat(1,ov,'      what= Hy');
    ov = cat(1,ov,'      log=yes');
    ov = cat(1,ov,'      show=no');
    ov = cat(1,ov,'     scale= 4');
    ov = cat(1,ov,'     mpegfile= ./temp.mpeg');
    ov = cat(1,ov,'     doit');
    ov = cat(1,ov,' -2dmanygifs');
    ov = cat(1,ov,'    1stinfile= data_link/wake/efields-000000001.gz');
    ov = cat(1,ov,'      outfiles= pp_link/wake/E2DHx');
    ov = cat(1,ov,'      what= Hx');
    ov = cat(1,ov,'      log=yes');
    ov = cat(1,ov,'      show=no');
    ov = cat(1,ov,'     scale= 4');
    ov = cat(1,ov,'     mpegfile= ./temp.mpeg');
    ov = cat(1,ov,'     doit');
end %if
if exist('data_link/wake/hfields-000000001.gz','file') == 2
    ov = cat(1,ov,' -2dmanygifs');
    ov = cat(1,ov,'    1stinfile= data_link/wake/hfields-000000001.gz');
    ov = cat(1,ov,'      outfiles= pp_link/wake/H2DHy');
    ov = cat(1,ov,'      what= Hy');
    ov = cat(1,ov,'      log=yes');
    ov = cat(1,ov,'      show=no');
    ov = cat(1,ov,'     scale= 4');
    ov = cat(1,ov,'     mpegfile= ./temp.mpeg');
    ov = cat(1,ov,'     doit');
    ov = cat(1,ov,' -2dmanygifs');
    ov = cat(1,ov,'    1stinfile= data_link/wake/hfields-000000001.gz');
    ov = cat(1,ov,'      outfiles= pp_link/wake/H2DHx');
    ov = cat(1,ov,'      what= Hx');
    ov = cat(1,ov,'      log=yes');
    ov = cat(1,ov,'      show=no');
    ov = cat(1,ov,'     scale= 4');
    ov = cat(1,ov,'     mpegfile= ./temp.mpeg');
    ov = cat(1,ov,'     doit');
    write_out_data( ov, 'pp_link/wake/model_wake_post_processing' )
end %if


