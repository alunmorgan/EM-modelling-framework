function wake_data = postprocess_wakes(ppi, modelling_inputs, log)
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
tstart = GdfidL_write_pp_input_file(log, pipe_length);

%% run the wake postprocessor
temp_files('make')
[~]=system('gd1.pp < pp_link/wake/model_wake_post_processing > pp_link/wake/model_wake_post_processing_log');
% Check that the post processor has completed
data = read_file_full_line('pp_link/wake/model_wake_post_processing_log');
for hwa = 1:length(data)
    se = strfind(data{hwa}, 'The End of File is reached');
    se = isempty(se{1});
    if se == 0
        disp('Postprocess_wakes: The post processor has run to completion')
        break
    end
    if hwa == length(data)
        warning('postprocess_wakes:NotCompleted', 'The postprocessor has not completed properly')
    end
end
%% find the location of all the required output files
[ WP_l, WP_2, WP_3, WI_s, WI_x, WI_y, ...
    Port_mat, port_names_table, Energy, Energy_in_ceramics ] =...
    GdfidL_find_ouput('temp_scratch');

%% Extract the wake data

% get the Total energy in the structure
[ total_energy_data ] = GdfidL_read_graph_datafile( Energy{1});

if isfield(log, 'mat_losses')
    % get the energy in the ceramics.
    [ energy_ceramics_data ] = GdfidL_read_graph_datafile( Energy_in_ceramics{1});
    % The original data is the energy sampled at a point in time. What I want
    % is the total energy over time. So I cumsum it and scale with the timestep
    loss_in_ceramics = cumsum(energy_ceramics_data.data(:,2)) .* ...
        (energy_ceramics_data.data(2,1)-energy_ceramics_data.data(1,1));
    % In order to combine with the other material losses I can interpolate (as
    % I have already done the scaling with timestep.)
    loss_in_ceramics = interp1(energy_ceramics_data.data(:,1), ...
        loss_in_ceramics, log.mat_losses.loss_time);
    % scale the loss values of the simulated volume to the full volume
    % of the structure.
    loss_in_ceramics = loss_in_ceramics ./ modelling_inputs.volume_fill_factor;
else
    loss_in_ceramics = 0;
end

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
% get the wake potentials
if isempty(WP_l)
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
    [ wpl_data, cd_data] = GdfidL_read_graph_datafile( WP_l{1} );
end
% Get the transverse wake potientials.
if ~isempty(WP_2)
    wptx_data = GdfidL_read_graph_datafile( WP_2{1} );
end
if ~isempty(WP_3)
    wpty_data = GdfidL_read_graph_datafile( WP_3{1} );
end

if ~isempty(WI_s)
    % Returns the longitudinal wake impedance
    % and the charge distribution with the integral scaled to 1C
    [ wil_data] = GdfidL_read_graph_datafile( WI_s{1} );
end
% Get the transverse wake potientials.
if ~isempty(WI_x)
    witx_data = GdfidL_read_graph_datafile( WI_x{1} );
end
if ~isempty(WI_y)
    wity_data = GdfidL_read_graph_datafile( WI_y{1} );
end
temp_files('remove')
delete('POSTP-LOGFILE');
delete('WHAT-PP-DID-SPIT-OUT');

% scale the total energy values of the simulated volume to the full volume
% of the structure.
if isfield(log, 'mat_losses')
    if isfield(log.mat_losses, 'total_loss')
        % only do it if there are user defined materials in the model.
        log.mat_losses.total_loss = (log.mat_losses.total_loss )./ ...
            modelling_inputs.volume_fill_factor + loss_in_ceramics;
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
                log.mat_losses.single_mat_data{ern,3}(:,2) = ...
                    log.mat_losses.single_mat_data{ern,3}(:,2) ./ ...
                    modelling_inputs.volume_fill_factor;
            else
                log.mat_losses.single_mat_data{ern,3} = loss_in_ceramics ./ cer_count;
            end
        end
        
    else
        log.mat_losses.total_loss = 0;
    end %if
end %if

% Generate the data file which the analysis code is expecting.
raw_data.Energy = total_energy_data.data ;
raw_data.Wake_potential = wpl_data.data;
if exist('wptx_data','var')
    raw_data.Wake_potential_trans_X = wptx_data.data;
else
    % NASTY HACK
    raw_data.Wake_potential_trans_X = wpl_data.data;
end
if exist('wpty_data','var')
    raw_data.Wake_potential_trans_Y = wpty_data.data;
else
    % NASTY HACK
    raw_data.Wake_potential_trans_Y = wpl_data.data;
end
raw_data.Charge_distribution = cd_data.data;
raw_data.Wake_impedance = wil_data.data;
if exist('witx_data','var')
    raw_data.Wake_impedance_trans_X = witx_data.data;
else
    % NASTY HACK
    raw_data.Wake_impedance_trans_X = wil_data.data;
end
if exist('wity_data','var')
    raw_data.Wake_impedance_trans_Y = wity_data.data;
else
    % NASTY HACK
    raw_data.Wake_impedance_trans_Y = wil_data.data;
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
    raw_data.mat_losses = log.mat_losses;
end

[port_time_data, time_domain_data, frequency_domain_data]= ...
    wake_analysis(raw_data, ppi, modelling_inputs, log);

wake_data.port_time_data = port_time_data;
wake_data.time_domain_data = time_domain_data;
wake_data.frequency_domain_data = frequency_domain_data;
wake_data.raw_data = raw_data;