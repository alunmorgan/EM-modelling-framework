function tfirst = GdfidL_write_pp_input_file(log, tqw_offset)
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
% 8 sigmas is usually enough for the input charge to have fully passed through the
% port. If you do not leave enough time then there is an enhancement in
% what is accounted for. And a sharp pling which messes up the FFT later in
% the processing chain.
% However for some models (e.g. BPMs) this quiet period needs to be extended.
tfirst{1} = '2E-9';%'8 * SIGMA / 3e8'; % input beam port
tfirst{2} = '2E-9';%'( @zmax - @zmin + 8 * SIGMA ) / 3e8'; % output beam port
for kd = 3:length(log.port_name)
    % For the signal ports you WANT to include the effect of the beam signal
    %     as that is what you are trying to measure
    tfirst{kd} = '0';
end %for


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

% ov = cat(1,ov,'-fexport');
% if isfield(log, 'field_data')
%     if isfield(log.field_data, 'EF')
%         for kew = 1:size(log.field_data.EF,1)
%             ov = cat(1,ov,['symbol = EF_e_', num2str(kew)]);
%             ov = cat(1,ov,['outfile= pp_link/wake/EF_e_', num2str(kew)]);
%             ov = cat(1,ov,'    doit');
%         end %for
%     end %if
%      if isfield(log.field_data, 'ED')
%         for kew = 1:size(log.field_data.ED, 1)
%             ov = cat(1,ov,['symbol = EF_e_', num2str(kew)]);
%             ov = cat(1,ov,['outfile= pp_link/wake/EF_e_', num2str(kew)]);
%             ov = cat(1,ov,'    doit');
%         end %for
%     end %if
% end %if
showeh = {'no', 'yes'};
% showeh =yes gives good output power graphs, while showeh=no gives output
% voltage graphs which can be used to reconstruct the frequency domain after
% truncating the wake/ time slicing etc.
for ens = 1:2
    for lae = 1:length(log.port_name)
        ov = cat(1,ov,'-general');
        ov = cat(1,ov,strcat('    scratchbase = temp_scratch/',log.port_name{lae}, '-'));
        ov = cat(1,ov,'-sparameter');
        ov = cat(1,ov,strcat('    ports = ', log.port_name{lae}));
        ov = cat(1,ov,'    modes = all');
        ov = cat(1,ov,strcat('showeh   = ', showeh{ens}));
        ov = cat(1,ov,'    timedata = yes');
        ov = cat(1,ov,'    ignoreexc = yes');
        ov = cat(1,ov,strcat('    tfirst = ',tfirst{lae}));
        ov = cat(1,ov,'    tsumpower = yes');
        ov = cat(1,ov,'    tintpower = yes');
        ov = cat(1,ov,'    fintpower = yes');
        ov = cat(1,ov,'    onlyplotfiles = yes');
        ov = cat(1,ov,'    doit');
    end   
end %for
% find the first stored field after the bunch has passed out of the
% structure
% model_length = log.mesh_extent_zhigh - log.mesh_extent_zlow;
% model_length_time = model_length ./ 3E8;
if isfield(log, 'field_data')
    if isfield(log.field_data, 'ALL')
        %     field_start = find(log.field_data.ALL(:,1) > model_length_time, 1, 'first');
        field_start = 1;
        ov = cat(1,ov,'-3darrowplot');
        ov = cat(1,ov,'    lenarrows= 1e-7');
        ov = cat(1,ov,'    scale= 4');
        ov = cat(1,ov,'    fcolour= 7');
        ov = cat(1,ov,'    arrows= 10');
        ov = cat(1,ov,'    fonmat= yes');
        ov = cat(1,ov,'    eyeposition= ( 1.0, -2.3, 0.5 )');
        ov = cat(1,ov,'    bbxlow=0'); % cutting in half
        ov = cat(1,ov,'    bbxhigh=1E30');
        ov = cat(1,ov,'    bbylow=-8E-3');
        ov = cat(1,ov,'    bbyhigh=8E-3');
        ov = cat(1,ov,'    bbzlow=-10E-3');
        ov = cat(1,ov,'    bbzhigh=10E-3');
        ov = cat(1,ov,'    rotx=180');
        ov = cat(1,ov,'    roty=90'); % make the beam horizontal
        ov = cat(1,ov,'    rotz=-90');
        ov = cat(1,ov,'    logfonmat=yes');
        ov = cat(1,ov,'    onlyplotfile= no');
        ov = cat(1,ov,'    quantity= ALL_e');
        ov = cat(1,ov,'    #');
        ov = cat(1,ov,'    # A first Pass through the Results.');
        ov = cat(1,ov,'    # We want to know what the max-Values of the Fields are ,');
        ov = cat(1,ov,'    # after the bunch has passed out of the structure.');
        ov = cat(1,ov,'    # to not use autoscaling of the Arrow-Lengths and fonmat Patches.');
        ov = cat(1,ov,'    #');
        ov = cat(1,ov,'define( FARROWMAX, 1e-6 )');
        ov = cat(1,ov,'define( FMAXONMAT, 1e-6 )');
        for ii = field_start:40 %length(log.field_data.ALL)
            ov = cat(1,ov,['       solution= ', num2str(ii)]);
            ov = cat(1,ov,['plotopts =  -geometry 1440X900 -colorps -o ./pp_link/wake/All_scaling_',num2str(ii,'%02d'),'.ps']);
            ov = cat(1,ov,'       doit');
            ov = cat(1,ov,'define( FARROWMAX, max( FARROWMAX, @farrowmax ) )');
            ov = cat(1,ov,'define( FMAXONMAT, max( FMAXONMAT, @absfmax ) )');
        end %for
        %         ov = cat(1,ov,'    end do');
        %         ov = cat(1,ov,'system(rm -f ./*-3D-Arrowplot.*.gld )');
        ov = cat(1,ov,'    #');
        ov = cat(1,ov,'    # The second pass through the Results.');
        ov = cat(1,ov,'    # We now know the Max Values, and scale every Frame for the same');
        ov = cat(1,ov,'    # Max Values that will occur in all the Frames.');
        ov = cat(1,ov,'    #');
        ov = cat(1,ov,'    fmaxonmat= FMAXONMAT / 2  # Slightly cheating.');
        ov = cat(1,ov,'    fscale= 1.5 /  FARROWMAX');
        for ii = field_start:40 %length(log.field_data.ALL)
            ov = cat(1,ov,['       solution= ', num2str(ii)]);
            ov = cat(1,ov,['plotopts =  -geometry 1440X900 -colorps -o pp_link/wake/All_scaled_',num2str(ii,'%02d'),'.ps']);
            ov = cat(1,ov,'       doit   # Create the gld-File.');
        end %for
        ov = cat(1,ov,'    fonmat= no');
        ov = cat(1,ov,'    jonmat= yes');
        ov = cat(1,ov,'    # Now looking at power on the surfaces.');
        ov = cat(1,ov,'    fscale= auto');
        ov = cat(1,ov,'    fmaxonmat= auto');
        for ii = field_start:40 %length(log.field_data.ALL)
            ov = cat(1,ov,['       solution= ', num2str(ii)]);
            ov = cat(1,ov,['plotopts =  -geometry 1440X900 -colorps -o pp_link/wake/All_power_scaling_',num2str(ii,'%02d'),'.ps']);
            ov = cat(1,ov,'       doit');
            ov = cat(1,ov,'define( FARROWMAX, max( FARROWMAX, @farrowmax ) )');
            ov = cat(1,ov,'define( FMAXONMAT, max( FMAXONMAT, @absfmax ) )');
        end %for
        ov = cat(1,ov,'    #');
        ov = cat(1,ov,'    # The second pass through the Results.');
        ov = cat(1,ov,'    # We now know the Max Values, and scale every Frame for the same');
        ov = cat(1,ov,'    # Max Values that will occur in all the Frames.');
        ov = cat(1,ov,'    #');
        ov = cat(1,ov,'    fmaxonmat= FMAXONMAT / 2  # Slightly cheating.');
        ov = cat(1,ov,'    fscale= 1.5 /  FARROWMAX');
        for ii = field_start:40 %length(log.field_data.ALL)
            ov = cat(1,ov,['       solution= ', num2str(ii)]);
            ov = cat(1,ov,['plotopts =  -geometry 1440X900 -colorps -o pp_link/wake/All_power_scaled_',num2str(ii,'%02d'),'.ps']);
            ov = cat(1,ov,'       doit   # Create the gld-File.');
        end %for
    end %if
end %if
if exist('data_link/wake/honmat-000000001.gz','file') == 2
    ov = cat(1,ov,' -3dmanygifs');
    ov = cat(1,ov,'    1stinfile= data_link/wake/honmat-000000001.gz');
    ov = cat(1,ov,'     outfiles= pp_link/wake/honmat3D');
    ov = cat(1,ov,'     what= logabs');
    ov = cat(1,ov,'     show=no');
    ov = cat(1,ov,'     scale= 4');
    ov = cat(1,ov,'     mpegfile= ./temp.mpeg');
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
end %if
write_out_data( ov, 'pp_link/wake/model_wake_post_processing' )

