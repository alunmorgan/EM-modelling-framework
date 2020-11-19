function raw_data = extract_wake_data_from_pp_output_files(output_file_locations, log, modelling_inputs, tstart)

% get the Total energy in the structure
if iscell(output_file_locations.Energy)
    total_energy_data = GdfidL_read_graph_datafile(output_file_locations.Energy{1});
else
    total_energy_data.data = NaN;
end %if

%% Material losses
if iscell(output_file_locations.Energy_in_ceramics)
    % get the energy in the ceramics.
    energy_ceramics_data = GdfidL_read_graph_datafile(output_file_locations.Energy_in_ceramics{1});
    % The original data is the energy sampled at a point in time. What I want
    % is the total energy over time. So cumsum it and scale with the timestep
    loss_in_ceramics = cumsum(energy_ceramics_data.data(:,2)) .* ...
        (energy_ceramics_data.data(2,1)-energy_ceramics_data.data(1,1));
    if sum(loss_in_ceramics) == 0
         loss_in_ceramics = 0;
         if ~isfield(log.mat_losses, 'loss_time')
             log.mat_losses.loss_time = 0;
         end %if
    else
    % In order to combine with the other material losses I can interpolate (as
    % I have already done the scaling with timestep.)
    loss_in_ceramics = interp1(energy_ceramics_data.data(:,1), ...
        loss_in_ceramics, log.mat_losses.loss_time);
    end %if
end %if

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
if ~iscell(output_file_locations.Port_mat)
    warning('postprocess_wakes:No ports to analyse')
    port_data = NaN;
else
    [port_timebase, port_data] = read_port_datafiles(output_file_locations.Port_mat);
end

%% Wake potentials
if isempty(output_file_locations.WP_beam.s)
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
    [ wpl_data, cd_data] = GdfidL_read_graph_datafile(output_file_locations.WP_beam.s{1} );
end
% Get the transverse dipolewake potientials.
if ~isempty(output_file_locations.WP_offset.x)
    wptdx_data = GdfidL_read_graph_datafile(output_file_locations.WP_offset.x{1} );
end
if ~isempty(output_file_locations.WP_offset.y)
    wptdy_data = GdfidL_read_graph_datafile(output_file_locations.WP_offset.y{1} );
end

% Get the transverse quadrupolar wake potientials.
if ~isempty(output_file_locations.WP_beam.x)
    wptqx_data = GdfidL_read_graph_datafile(output_file_locations.WP_beam.x{1} );
end
if ~isempty(output_file_locations.WP_beam.y)
    wptqy_data = GdfidL_read_graph_datafile(output_file_locations.WP_beam.y{1} );
end

if ~isempty(output_file_locations.WI_s)
    % Returns the longitudinal wake impedance
    wil_data = GdfidL_read_graph_datafile(output_file_locations.WI_s{1} );
end
% Get the transverse wake potientials.
if ~isempty(output_file_locations.WI_x)
    witqx_data = GdfidL_read_graph_datafile(output_file_locations.WI_x{1} );
end
if ~isempty(output_file_locations.WI_y)
    witqy_data = GdfidL_read_graph_datafile(output_file_locations.WI_y{1} );
end
if ~isempty(output_file_locations.WI_x) && length(output_file_locations.WI_x) >1
    % the second check is to cope with symetry planes.
    witdx_data = GdfidL_read_graph_datafile(output_file_locations.WI_x{2} );
end
if ~isempty(output_file_locations.WI_y) && length(output_file_locations.WI_y) >1
    % the second check is to cope with symetry planes.
    witdy_data = GdfidL_read_graph_datafile(output_file_locations.WI_y{2} );
end

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
    raw_data.Wake_potential_trans_dipole_Y = wptdy_data.data;
else
    raw_data.Wake_potential_trans_dipole_Y = NaN(length(wpl_data.data),2);
end
raw_data.Charge_distribution = cd_data.data;
if exist('wil_data','var')
    raw_data.Wake_impedance = wil_data.data;
else
    raw_data.Wake_impedance = NaN(length(wpl_data.data),2);
    warning('Missing impedance graph')
end
if exist('witqx_data','var')
    raw_data.Wake_impedance_trans_quad_X = witqx_data.data;
else
    raw_data.Wake_impedance_trans_quad_X = NaN(size(raw_data.Wake_impedance));
end
if exist('witqy_data','var')
    raw_data.Wake_impedance_trans_quad_Y = witqy_data.data;
else
    raw_data.Wake_impedance_trans_quad_Y = NaN(size(raw_data.Wake_impedance));
end
if exist('witdx_data','var')
    raw_data.Wake_impedance_trans_dipole_X = witdx_data.data;
else
    raw_data.Wake_impedance_trans_dipole_X = NaN(size(raw_data.Wake_impedance));
end
if exist('witdy_data','var')
    raw_data.Wake_impedance_trans_dipole_Y = witdy_data.data;
else
    raw_data.Wake_impedance_trans_dipole_Y = NaN(size(raw_data.Wake_impedance));
end
raw_data.port.timebase = port_timebase;
raw_data.port.data = port_data;
raw_data.port.labels = modelling_inputs.port_names;
raw_data.port.t_start = tstart;
raw_data.wake_setup.Wake_length = wpl_data.data(end,1) .* 2.99792458E8;
raw_data.mat_losses.loss_time = log.mat_losses.loss_time;
raw_data.mat_losses.total_loss = total_loss;
raw_data.mat_losses.single_mat_data = log.mat_losses.single_mat_data;
