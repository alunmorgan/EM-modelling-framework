function raw_data = extract_wake_data_from_pp_output_files(output_file_locations, log, modelling_inputs)

% get the Total energy in the structure
raw_data.Energy = GdfidL_read_graph_datafile(output_file_locations.Energy{1});

% get the bunch spectrum
raw_data.bunch_spectrum = GdfidL_read_graph_datafile(output_file_locations.bunch_spectrum{1});

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
        if ~isfield(log, 'mat_losses') || ~isfield(log.mat_losses, 'loss_time')
            log.mat_losses.loss_time = 0;
        end %if
    else
        % In order to combine with the other material losses I can interpolate (as
        % I have already done the scaling with timestep.)
        if isfield(log, 'mat_losses') && isfield(log.mat_losses, 'loss_time')
            loss_in_ceramics = interp1(energy_ceramics_data.data(:,1), ...
                loss_in_ceramics, log.mat_losses.loss_time);
        end %if
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
if ~isfield(output_file_locations, 'Port_mat')
    fprintf('\npostprocess_wakes:No ports to analyse')
    raw_data.port.data.time = NaN;
    raw_data.port.data.frequency = NaN;
    raw_data.port.timebase = NaN;
else
    [raw_data.port.timebase, raw_data.port.data] = read_port_datafiles(output_file_locations.Port_mat);
end

%% Electric field at origin
% raw_data.EfieldAtZerox = GdfidL_read_graph_datafile(output_file_locations.EfieldAtZerox{1} );
% raw_data.EfieldAtZerox_freq = GdfidL_read_graph_datafile(output_file_locations.EfieldAtZerox_freq{1} );

%% Voltage signals
if isfield(output_file_locations, 'Voltage_Signals')
    for wic = 1:length(output_file_locations.Voltage_Signals)
        raw_data.voltages{wic} = GdfidL_read_graph_datafile(output_file_locations.Voltage_Signals{wic});
    end %for
end %if

%% Wake potentials
%     The charge distribution with the integral scaled to 1C
[ ~, raw_data.Charge_distribution] = GdfidL_read_graph_datafile(output_file_locations.WP_beam.s{1} );

% Returns the longitudinal wake potential at the origin
raw_data.Wake_potential.s = GdfidL_read_graph_datafile(output_file_locations.WP_origin.s{1} );
% Get the transverse potientials at the origin.
raw_data.Wake_potential.x = GdfidL_read_graph_datafile(output_file_locations.WP_origin.x{1} );
raw_data.Wake_potential.y = GdfidL_read_graph_datafile(output_file_locations.WP_origin.y{1} );

if ~isempty(output_file_locations.WI_s)
    % Returns the longitudinal wake impedance
    raw_data.Wake_impedance.s = GdfidL_read_graph_datafile(output_file_locations.WI_s{1} );
end
% Get the transverse wake impedance.
if ~isempty(output_file_locations.WI_x)
    raw_data.Wake_impedance.x = GdfidL_read_graph_datafile(output_file_locations.WI_x{1} );
end
if ~isempty(output_file_locations.WI_y)
    raw_data.Wake_impedance.y = GdfidL_read_graph_datafile(output_file_locations.WI_y{1} );
end
if ~isempty(output_file_locations.WI_x) && length(output_file_locations.WI_x) >1
    % the second check is to cope with symetry planes.
    raw_data.Wake_impedance.dx = GdfidL_read_graph_datafile(output_file_locations.WI_x{2} );
end
if ~isempty(output_file_locations.WI_y) && length(output_file_locations.WI_y) >1
    % the second check is to cope with symetry planes.
    raw_data.Wake_impedance.dy = GdfidL_read_graph_datafile(output_file_locations.WI_y{2} );
end

if ~isempty(output_file_locations.WI_Im_s)
    % Returns the longitudinal wake impedance
    raw_data.Wake_impedance_Im.s = GdfidL_read_graph_datafile(output_file_locations.WI_Im_s{1} );
end
% Get the transverse wake impedance.
if ~isempty(output_file_locations.WI_Im_x)
    raw_data.Wake_impedance_Im.x = GdfidL_read_graph_datafile(output_file_locations.WI_Im_x{1} );
end
if ~isempty(output_file_locations.WI_Im_y)
    raw_data.Wake_impedance_Im.y = GdfidL_read_graph_datafile(output_file_locations.WI_Im_y{1} );
end
if ~isempty(output_file_locations.WI_Im_x) && length(output_file_locations.WI_Im_x) >1
    % the second check is to cope with symetry planes.
    raw_data.Wake_impedance_Im.dx = GdfidL_read_graph_datafile(output_file_locations.WI_Im_x{2} );
end
if ~isempty(output_file_locations.WI_Im_y) && length(output_file_locations.WI_Im_y) >1
    % the second check is to cope with symetry planes.
    raw_data.Wake_impedance_Im.dy = GdfidL_read_graph_datafile(output_file_locations.WI_Im_y{2} );
end

raw_data.wake_loss_factor = raw_data.Wake_impedance.s.loss.s ./ raw_data.Wake_impedance.s.charge.^2 ; % V/C

%% Generate the data file which the analysis code is expecting.
raw_data.port.labels = modelling_inputs.port_names;
% raw_data.port.t_start = tstart;
raw_data.wake_setup.Wake_length = raw_data.Wake_potential.s.data(end,1) .* 2.99792458E8;
if isfield(log.mat_losses, 'loss_time')
    raw_data.mat_losses.loss_time = log.mat_losses.loss_time;
else
    raw_data.mat_losses.loss_time = 0;
end %if
if exist('total_loss', 'var')
    raw_data.mat_losses.total_loss = total_loss;
else
    raw_data.mat_losses.total_loss = 0;
end %if
if isfield(log.mat_losses, 'single_mat_data')
    raw_data.mat_losses.single_mat_data = log.mat_losses.single_mat_data;
else
    raw_data.mat_losses.single_mat_data = 0;
end %if