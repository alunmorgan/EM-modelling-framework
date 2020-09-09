function makeSweepSummaryTables(valsX, dataInds, extracted_data, model_set, xunit, sweep_name, root)

wlf = round(extracted_data.wlf(dataInds) .* 1E-9);
sim_time_string = sec_to_time_string(extracted_data.simulation_time(dataInds));
mesh_stepsize = extracted_data.mesh_density(dataInds) ./ extracted_data.mesh_scaling(dataInds) .* 1e6;
timestep = round(extracted_data.timestep(dataInds) .* 1E15);
number_of_cells = round(extracted_data.number_of_cells(dataInds) ./ 1E6);
for ks = 1:length(valsX)
    row_names{ks} = [num2str(valsX(ks)) ,' ', xunit];
end %for
unique_row_names = unique(row_names);
if length(unique_row_names) ~= length(row_names)
    for rdf = 1:length(unique_row_names)
        found_names = find(strcmp(unique_row_names{rdf}, row_names));
        if length(found_names) >1
            for jsel = 2:length(found_names)
                row_names{found_names(jsel)} = [row_names{found_names(jsel)}, '(',num2str(jsel) , ')'];
            end %for
        end %if
    end %for
end %if
%%%%%%%%%%%%%%%Setup table%%%%%%%%%%%%%%%%%%
varnames_setup = {'simulation time (wake only)', 'number of mesh cells (million)', ...
    'memory used (MB)', 'timestep (fs)', ...
    'mesh stepsize (um)', 'number of cores'};
T_setup = table(sim_time_string', number_of_cells', ...
    extracted_data.memory_usage(dataInds)', timestep',...
    mesh_stepsize', extracted_data.n_cores(dataInds)',...
    'RowNames', row_names', 'VariableNames', varnames_setup);
writetable(T_setup, fullfile(root, model_set,...
    [model_set, '_', sweep_name, '_setup.txt']), ...
    'Delimiter','|',...
    'WriteVariableNames',true, 'WriteRowNames',true)

%%%%%%%%%%%% wake table %%%%%%%%%%%%%%%%%%%%%
varnames_wake = {'wake loss factor (mV/pC)', 'wake length (m)'};
T_wake = table(...
    wlf', extracted_data.wake_length(dataInds)', ...
    'RowNames', row_names', 'VariableNames', varnames_wake);
writetable(T_wake, fullfile(root, model_set,...
    [model_set, '_', sweep_name, '_wake.txt']), ...
    'Delimiter','|',...
    'WriteVariableNames',true, 'WriteRowNames',true)

%%%%%%%%%%%%%%% material loss table %%%%%%%%%%%%%%%%%%%%%%%%
materials = [];
for jse = 1:length(extracted_data.material_loss(dataInds))
    varnames_material_loss = fieldnames(extracted_data.material_loss{jse});
    for hne = 1:length(varnames_material_loss)
        % Power loss at 300mA operation. (assuming 1nC simulation charge)
        materials(hne, jse) = round(extracted_data.material_loss{jse}.(varnames_material_loss{hne}) * 300E6 *1000) / 1000;
        if jse == 1
            material_names{hne} = [varnames_material_loss{hne}, ' (W)'];
        end %if
    end %for
end %for

T_material_loss = array2table(materials',...
    'RowNames', row_names', 'VariableNames', material_names');
writetable(T_material_loss, fullfile(root, model_set,...
    [model_set, '_', sweep_name, '_material_loss.txt']), ...
    'Delimiter','|',...
    'WriteVariableNames',true, 'WriteRowNames',true)

%%%%%%%%%%%%%%%%%% loss table %%%%%%%%%%%%%%%%%%%%
varnames_losses = {...
    'beam port loss [f](%)', 'signal port loss [f](%)', 'structure loss [f](%)',...
    'beam port loss [t](%)', 'signal port loss [t](%)', 'structure loss [t](%)'};
T_losses = table(...
    round(extracted_data.fractional_loss_beam_ports(dataInds)' .* 100),...
    round(extracted_data.fractional_loss_signal_ports(dataInds)' .* 100),...
    round(extracted_data.fractional_loss_structure(dataInds)' .* 100),...
    round(extracted_data.beam_port_loss(dataInds)' .* 100),...
    round(extracted_data.signal_port_loss(dataInds)' .* 100),...
    round(extracted_data.structure_loss(dataInds)' .* 100),...
    'RowNames', row_names', 'VariableNames', varnames_losses);
writetable(T_losses, fullfile(root, model_set,...
    [model_set, '_', sweep_name, '_losses.txt']), ...
    'Delimiter','|',...
    'WriteVariableNames',true, 'WriteRowNames',true)

%%%%%%%%%%%%%%%%%% overview table %%%%%%%%%%%%%%%%%%%%
varnames_losses = {...
    'wake loss factor (mV/pC)',...
    'beam port loss [t](%)', 'signal port loss [t](%)', 'structure loss [t](%)',...
    'simulation time (wake only)', 'number of mesh cells (million)'};
T_losses = table(...
    wlf',...
    round(extracted_data.beam_port_loss(dataInds)' .* 100),...
    round(extracted_data.signal_port_loss(dataInds)' .* 100),...
    round(extracted_data.structure_loss(dataInds)' .* 100),...
    sim_time_string', number_of_cells',...
    'RowNames', row_names', 'VariableNames', varnames_losses);
writetable(T_losses, fullfile(root, model_set,...
    [model_set, '_', sweep_name, '_overview.txt']), ...
    'Delimiter','|',...
    'WriteVariableNames',true, 'WriteRowNames',true)

%%%%%%%%%%%%%%%% port signals table %%%%%%%%%%%%%%%%%%%%
varnames_port_signals = {};
for wha = 1:length(dataInds) %for each model in sweep
    temp_port_data = extracted_data.port{dataInds(wha)};
    ck = 1;
    for hne = 3:length(temp_port_data.dominant_signal_amplitudes) %for each signal port
        label = temp_port_data.labels{hne};
        label_inds_dup_check = find(strcmp(temp_port_data.labels, label(1:end-2)));
        if ~isempty(label_inds_dup_check)
            %it is a duplicated port - so can be ignored for this.
            continue
        end %if
        varnames_port_signals{wha,ck} = [label, ' amplitude'];
        varnames_port_signals{wha,ck+1} = [label, ' dominant mode'];
        label_inds = [length(varnames_port_signals) -1, length(varnames_port_signals)];
        port_signals_table_data(wha,ck) = round(temp_port_data.dominant_signal_amplitudes(hne)*1000)/1000;
        port_signals_table_data(wha,ck +1) = temp_port_data.dominant_modes(hne);
        ck = ck +2;
    end %for
end %for
ports_present = not(cellfun(@isempty,varnames_port_signals));
if max(diff(sum(ports_present,2))) > 0
    warning('makeSweepSummaryTables: The number of ports changes. Please check that this is expected (This mainly occurs with geometry fraction changes)')
end %if
[~, max_num_pots_ind] = max(sum(ports_present,2));
T_port_signals = array2table(port_signals_table_data,...
    'RowNames', row_names', 'VariableNames', varnames_port_signals(max_num_pots_ind,:));
writetable(T_port_signals, fullfile(root, model_set,...
    [model_set, '_', sweep_name, '_port_signals.txt']),...
    'Delimiter','|',...
    'WriteVariableNames',true, 'WriteRowNames',true)
