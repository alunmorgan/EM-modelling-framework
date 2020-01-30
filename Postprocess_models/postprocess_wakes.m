function raw_data = postprocess_wakes(modelling_inputs, log)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% ppi is a structure containing all the information required for the postprocessor
% modelling_inputs,log is
% wake_data is
%
%Example: wake_data = postprocess_wakes(ppi, modelling_inputs,log)

%% Write the wake post processing input file
% find the pipe length
pipe_length = get_pipe_length_from_defs(modelling_inputs.defs);
transverse_quadrupole_wake_offset = '1E-3';
tstart = GdfidL_write_pp_input_file(log, pipe_length, transverse_quadrupole_wake_offset, str2double(modelling_inputs.version(1:6)));

%% run the wake postprocessor
temp_files('make')
% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',modelling_inputs.version);
[~]=system('gd1.pp < pp_link/wake/model_wake_post_processing > pp_link/wake/model_wake_post_processing_log');
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
% Check that the post processor has completed
data = read_file_full_line(fullfile('pp_link', 'wake', 'model_wake_post_processing_log'));
for hwa = 1:length(data)
    if ~isempty(strfind(data{hwa},'The End of File is reached'))
        disp('Postprocess_wakes: The post processor has run to completion')
        break
    end
    if hwa == length(data)
        warning('postprocess_wakes:NotCompleted', 'The postprocessor has not completed properly')
    end
end

[file_list, path_list] = dir_list_gen('pp_link/wake/', 'ps');
if  ~isempty(file_list)
    All_scaled_list = file_list(contains(file_list, 'All_scaled'));
    if ~isempty(All_scaled_list)
        for cek = 1:length(All_scaled_list)
            system(['convert ', [path_list, All_scaled_list{cek}], ' -rotate -90 ', [path_list, All_scaled_list{cek}(1:end-2)],'png']);
        end
        system(['ffmpeg -r 2 -f image2 -s 1440x900 -i ', path_list, 'All_scaled_%02d.png -vcodec mpeg4 -pix_fmt yuv420p ' path_list, 'All_scaled.mp4'])
    end %if
    All_power_list = file_list(contains(file_list, 'All_power_scaled'));
    if ~isempty(All_power_list)
        for cek = 1:length(All_power_list)
            system(['convert ', [path_list, All_power_list{cek}], ' -rotate -90 ', [path_list, All_power_list{cek}(1:end-2)],'png']);
        end
        system(['ffmpeg -r 2 -f image2 -s 1440x900 -i ', path_list, 'All_power_%02d.png -vcodec mpeg4 -pix_fmt yuv420p ' path_list, 'All_power.mp4'])
    end %if
end %if
% find the gld files for the field output images.
gld_list = dir_list_gen('pp_link/wake/', 'gld');
if ~isempty(gld_list)
    gld_files = dir_list_gen('temp_scratch', 'gld', 1);
    parfor fjh = 1:length(gld_files)
        system(['gd1.3dplot -colorps -geometry 800x600 -o ',gld_files{fjh}(1:end-3), 'ps -i ' , gld_files{fjh}]);
        system(['convert ', gld_files{fjh}(1:end-3), 'ps -rotate -90 ',gld_files{fjh}(1:end-3) ,'png']);
    end %for
    system('ffmpeg -r 10 -f image2 -s 1920x1080 -i temp_scratch/3D-Arrowplot.%04d.png -vcodec mpeg4 -pix_fmt yuv420p test.mp4')
    movefile('test.mp4', 'pp_link/wake/h_on_surfaces.mp4')
end %if

gif_list = dir_list_gen('pp_link/wake/', 'gif');
if ~isempty(gif_list)
    convert_status = system('for file in pp_link/wake/*.gif; do convert $file pp_link/wake/`basename $file .gif`.png; done');
    if convert_status == 0
        [~] = system('rm -f pp_link/wake/*.gif');
    end%if
    if exist('pp_link/wake/E2DHy000000002.png', 'file') == 2
        E2DHy_status = system('ffmpeg -r 10 -i pp_link/wake/E2DHy%9d.png -vcodec mpeg4 -pix_fmt yuv420p pp_link/wake/E2Dy.mp4');
        if E2DHy_status == 0
            [~] = system('rm -f pp_link/wake/E2DHy*.png');
        end %if
    end %if
    if exist('pp_link/wake/E2DHx000000002.png', 'file') == 2
        E2DHx_status = system('ffmpeg -r 10 -i pp_link/wake/E2DHx%9d.png -vcodec mpeg4 -pix_fmt yuv420p pp_link/wake/E2Dx.mp4');
        if E2DHx_status == 0
            [~] = system('rm -f pp_link/wake/E2DHx*.png');
        end %if
    end %if
    if exist('pp_link/wake/H2DHy000000002.png', 'file') == 2
        H2DHy_status = system('ffmpeg -r 10 -i pp_link/wake/H2DHy%9d.png -vcodec mpeg4 -pix_fmt yuv420p pp_link/wake/H2Dy.mp4');
        if H2DHy_status == 0
            [~] = system('rm -f pp_link/wake/H2DHy*.png');
        end %if
    end %if
    if exist('pp_link/wake/H2DHx000000002.png', 'file') == 2
        H2DHx_status = system('ffmpeg -r 10 -i pp_link/wake/H2DHx%9d.png -vcodec mpeg4 -pix_fmt yuv420p pp_link/wake/H2Dx.mp4');
        if H2DHx_status == 0
            [~] = system('rm -f pp_link/wake/H2DHx*.png');
        end %if
    end %if
    if exist('pp_link/wake/honmat3D000000002.png', 'file') == 2
        honmat_status = system('ffmpeg -r 10 -i pp_link/wake/honmat3D%9d.png -vcodec mpeg4 -pix_fmt yuv420p pp_link/wake/Honmat3D.mp4');
        if honmat_status == 0
            [~] = system('rm -f pp_link/wake/honmat3D*.png');
        end %if
    end %if
end %if
%% find the location of all the required output files
[ WP_beam, WP_offset, WI_s, WI_x, WI_y, ...
    Port_mat, port_names_table, Energy, Energy_in_ceramics ] =...
    GdfidL_find_ouput('temp_scratch');

%% Extract the wake data

% get the Total energy in the structure
if iscell(Energy)
    [ total_energy_data ] = GdfidL_read_graph_datafile( Energy{1});
else
    total_energy_data.data = NaN;
end %if

%% Material losses
if isfield(log, 'mat_losses') && iscell(Energy_in_ceramics)
    % get the energy in the ceramics.
    energy_ceramics_data = GdfidL_read_graph_datafile( Energy_in_ceramics{1});
    % The original data is the energy sampled at a point in time. What I want
    % is the total energy over time. So cumsum it and scale with the timestep
    loss_in_ceramics = cumsum(energy_ceramics_data.data(:,2)) .* ...
        (energy_ceramics_data.data(2,1)-energy_ceramics_data.data(1,1));
    % In order to combine with the other material losses I can interpolate (as
    % I have already done the scaling with timestep.)
    loss_in_ceramics = interp1(energy_ceramics_data.data(:,1), ...
        loss_in_ceramics, log.mat_losses.loss_time);
else
    loss_in_ceramics = 0;
end

% scale the total energy values of the simulated volume to the full volume
% of the structure.
if isfield(log, 'mat_losses')
    if isfield(log.mat_losses, 'total_loss')
        % only do it if there are user defined materials in the model.
        total_loss = (log.mat_losses.total_loss + loss_in_ceramics)./ ...
            modelling_inputs.volume_fill_factor;
        % assume all the empty values are due to the fact that ceramics are not
        % output into the log.
        % Also I have to split the energy equally between ceramics for lack of
        % any better information.
        % first find out how many different ceramics are used.
        for ern = size(log.mat_losses.single_mat_data,1):-1:1
            cer_count(ern) = isempty(log.mat_losses.single_mat_data{ern,3});
        end
        cer_count = sum(cer_count);
        for ern = 1:size(log.mat_losses.single_mat_data,1)
            if ~isempty(log.mat_losses.single_mat_data{ern,3})
                log.mat_losses.single_mat_data{ern,4}(:,2) = ...
                    log.mat_losses.single_mat_data{ern,4}(:,2) ./ ...
                    modelling_inputs.volume_fill_factor;
            else
                log.mat_losses.single_mat_data{ern,4}(:,2) = loss_in_ceramics ./...
                    cer_count ./  modelling_inputs.volume_fill_factor;
            end
        end
        
    else
        log.mat_losses.total_loss = 0;
    end %if
end %if

%% Ports
if ~iscell(Port_mat)
    warning('postprocess_wakes:No ports to analyse')
    port_names = NaN;
    port_timebase = NaN;
    port_data_all = NaN;
    port_data = NaN;
    cutoff_all = NaN;
    alpha_all = NaN;
    beta_all = NaN;
    cutoff = NaN;
else
    [port_names, port_timebase,  port_data_all, ...
        cutoff_all, alpha_all, beta_all,...
        port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
        modelling_inputs.port_fill_factor,...
        modelling_inputs.port_multiple,...
        port_names_table);
end

%% Wake potentials
if isempty(WP_beam.s)
    %     If the model is simple enough that there is no wake potential (as it
    %     is zero) then GdfidL does not output a file.
    % use the total energy file to get the timescale and set all the data value
    % to zero.
    wpl_data = total_energy_data;
    wpl_data.data(:,2) = 0;
    wpl_data.title = 'Wake potential';
    wpl_data.ylabel = '';
    cd_data = wpl_data;
    cd_data.data(:,2) = 1;
    cd_data.title = 'Bunch charge distribution';
else
    % Returns the longitudinal wake potential
    % and the charge distribution with the integral scaled to 1C
    [ wpl_data, cd_data] = GdfidL_read_graph_datafile( WP_beam.s{1} );
end
% Get the transverse dipolewake potientials.
if ~isempty(WP_offset.x)
    wptdx_data = GdfidL_read_graph_datafile( WP_offset.x{1} );
end
if ~isempty(WP_offset.y)
    wptdy_data = GdfidL_read_graph_datafile( WP_offset.y{1} );
end

% Get the transverse quadrupolar wake potientials.
if ~isempty(WP_beam.x)
    wptqx_data = GdfidL_read_graph_datafile( WP_beam.x{1} );
end
if ~isempty(WP_beam.y)
    wptqy_data = GdfidL_read_graph_datafile( WP_beam.y{1} );
end

if ~isempty(WI_s)
    % Returns the longitudinal wake impedance
    % and the charge distribution with the integral scaled to 1C
    [ wil_data] = GdfidL_read_graph_datafile( WI_s{1} );
end
% Get the transverse wake potientials.
if ~isempty(WI_x)
    witqx_data = GdfidL_read_graph_datafile( WI_x{1} );
end
if ~isempty(WI_y)
    witqy_data = GdfidL_read_graph_datafile( WI_y{1} );
end
if ~isempty(WI_x)
    witdx_data = GdfidL_read_graph_datafile( WI_x{2} );
end
if ~isempty(WI_y)
    witdy_data = GdfidL_read_graph_datafile( WI_y{2} );
end

temp_files('remove')
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');



%% Generate the data file which the analysis code is expecting.
raw_data.Energy = total_energy_data.data ;
raw_data.Wake_potential = wpl_data.data;
if exist('wptqx_data','var')
    raw_data.Wake_potential_trans_quad_X = wptqx_data.data;
else
    raw_data.Wake_potential_trans_quad_X = NaN(length(wpl_data.data),2);
end
if exist('wptqy_data','var')
    raw_data.Wake_potential_trans_quad_Y = wptqy_data.data;
else
    raw_data.Wake_potential_trans_quad_Y = NaN(length(wpl_data.data),2);
end
if exist('wptdx_data','var')
    raw_data.Wake_potential_trans_dipole_X = wptdx_data.data;
else
    raw_data.Wake_potential_trans_dipole_X = NaN(length(wpl_data.data),2);
end
if exist('wptdy_data','var')
    raw_data.Wake_potential_trans_dipole_Y = wptqy_data.data;
else
    raw_data.Wake_potential_trans_dipole_Y = NaN(length(wpl_data.data),2);
end
raw_data.Charge_distribution = cd_data.data;
raw_data.Wake_impedance = wil_data.data;
if exist('witqx_data','var')
    raw_data.Wake_impedance_trans_quad_X = witqx_data.data;
else
    raw_data.Wake_impedance_trans_quad_X = NaN(length(wil_data.data),2);
end
if exist('witqy_data','var')
    raw_data.Wake_impedance_trans_quad_Y = witqy_data.data;
else
    raw_data.Wake_impedance_trans_quad_Y = NaN(length(wil_data.data),2);
end
if exist('witdx_data','var')
    raw_data.Wake_impedance_trans_dipole_X = witdx_data.data;
else
    raw_data.Wake_impedance_trans_dipole_X = NaN(length(wil_data.data),2);
end
if exist('witdy_data','var')
    raw_data.Wake_impedance_trans_dipole_Y = witdy_data.data;
else
    raw_data.Wake_impedance_trans_dipole_Y = NaN(length(wil_data.data),2);
end
raw_data.port.timebase = port_timebase;
raw_data.port.data_all = port_data_all;
raw_data.port.data = port_data;
raw_data.port.labels = port_names;
raw_data.port.labels_table = port_names_table;
raw_data.port.frequency_cutoffs = cutoff;
raw_data.port.frequency_cutoffs_all = cutoff_all;
raw_data.port.alpha = alpha_all;
raw_data.port.beta = beta_all;
raw_data.port.t_start = tstart;
raw_data.wake_setup.Wake_length = wpl_data.data(end,1) .* 2.99792458E8;
if isfield(log, 'mat_losses')
    raw_data.mat_losses.loss_time = log.mat_losses.loss_time;
    raw_data.mat_losses.total_loss = total_loss;
    raw_data.mat_losses.single_mat_data = log.mat_losses.single_mat_data;
end
