function out = get_wlf(model_sets)


[root, ~, ~] = analysis_model_settings_library;
[extracted_data] = extract_all_wlf(root, model_sets);
wlf = round(extracted_data.wlf .* 1E-9);
sim_time_string = sec_to_time_string(extracted_data.simulation_time);
mesh_stepsize = extracted_data.mesh_density ./ extracted_data.mesh_scaling .* 1e6;
timestep = round(extracted_data.timestep .* 1E15);
number_of_cells = round(extracted_data.number_of_cells ./ 1E6);
for kfn = 1:size(extracted_data.model_names,1)
    varnames_setup = {'simulation time', 'number of mesh cells (million)', ...
        'memory used (MB)', 'timestep (fs)', ...
        'mesh stepsize (um)', 'number of cores'};
    T_setup = table(sim_time_string(kfn,:)', number_of_cells(kfn,:)', ...
        extracted_data.memory_usage(kfn,:)', timestep(kfn,:)',...
        mesh_stepsize(kfn,:)', extracted_data.n_cores(kfn,:)',...
        'RowNames', extracted_data.model_names(kfn, :)', 'VariableNames', varnames_setup);
    out.(model_sets{kfn}).setup_table = T_setup;
    disp(T_setup(:,1:3))
    disp(T_setup(:,4:6))
    
    varnames_wake = {'wlf (mV/pC)', 'wake length (m)'};
    T_wake = table(...
        wlf(kfn,:)', extracted_data.wake_length(kfn,:)', ...
        'RowNames', extracted_data.model_names(kfn, :)', 'VariableNames', varnames_wake);
    out.(model_sets{kfn}).wake_table = T_wake;
    disp(T_wake(:,:))
    
    varnames_losses = {...
        'beam port loss [f](%)', 'signal port loss [f](%)', 'structure loss [f](%)',...
        'beam port loss [t](%)', 'signal port loss [t](%)', 'structure loss [t](%)'};
    T_losses = table(...
        extracted_data.fractional_loss_beam_ports(kfn,:)' .* 100,...
        extracted_data.fractional_loss_signal_ports(kfn,:)' .* 100,...
        extracted_data.fractional_loss_structure(kfn,:)' .* 100,...
        extracted_data.beam_port_loss(kfn,:)' .* 100,...
        extracted_data.signal_port_loss(kfn,:)' .* 100,...
        extracted_data.structure_loss(kfn,:)' .* 100,...
        'RowNames', extracted_data.model_names(kfn, :)', 'VariableNames', varnames_losses);
    out.(model_sets{kfn}).losses_table = T_losses;
    disp(T_losses(:,1:3))
    disp(T_losses(:,4:6))
    
    if length(extracted_data.port{kfn}.dominant_signal_amplitudes) > 2
        varnames_port_signals = {};
        ports = {};
        for wha = 1:size(extracted_data.port,2) %for each model in set
             if wha == 1
                 for hne = 3:length(extracted_data.port{kfn,wha}.dominant_signal_amplitudes) %for each signal port
                varnames_port_signals = cat(2, varnames_port_signals, [extracted_data.port{kfn,wha}.labels{hne}, ' amplitude'], ...
                    [extracted_data.port{kfn, wha}.labels{hne}, ' dominant mode']);
                ports = cat(2, ports, extracted_data.port{kfn,wha}.labels{hne}, ...
                    extracted_data.port{kfn, wha}.labels{hne});
                 end %for
                end %if
            for hne = 3:length(extracted_data.port{kfn,wha}.dominant_signal_amplitudes) %for each signal port
                label = extracted_data.port{kfn,wha}.labels{hne};
                label_inds = find(strcmp(ports, label));
                if isempty(label_inds)
                    label_inds = find(strcmp(ports, label(1:end-2)));
                    if isempty(label_inds)
                        % added new port to output - The only time this should
                        % happen is if the base model has reduced geometry and
                        % some of the others do not.
                        varnames_port_signals = cat(2, varnames_port_signals, [label, ' amplitude'], ...
                            [label, ' dominant mode']);
                        label_inds = [length(varnames_port_signals) -1, length(varnames_port_signals)];
                    else
                        %it is a duplicated port - so can be ignored for this.
                        continue
                    end %if
                end %if
                port_signals_table_data{label_inds(1)}(wha,1) = extracted_data.port{kfn,wha}.dominant_signal_amplitudes(hne);
                port_signals_table_data{label_inds(2)}(wha,1) = extracted_data.port{kfn,wha}.dominant_modes(hne);
            end %for
        end %for
        T_port_signals = table(port_signals_table_data{:},...
            'RowNames', extracted_data.model_names(kfn, :)', 'VariableNames', varnames_port_signals);
        out.(model_sets{kfn}).port_signals_table = T_port_signals;
    else
        out.(model_sets{kfn}).port_signals_table = NaN;
    end %if
    clear varnames_setup varnames_wake varnames_losses varnames_port_signals T_setup T_wake T_losses T_port_signals
end %for
end %function

function sim_time_string = sec_to_time_string(simulation_time)

st_days = floor(simulation_time ./ 3600 ./24);
st_hours = floor(simulation_time ./ 3600 - st_days .* 24);
st_mins = floor(simulation_time ./ 60 - st_hours .* 60);
for kef = 1:length(simulation_time)
    if st_days(kef) ~= 0
        day_string = [num2str(st_days(kef)), ' days '];
    else
        day_string = '';
    end %if
    if st_hours(kef) ~= 0
        hour_string = [num2str(st_hours(kef)), ' hours '];
    else
        hour_string = '';
    end %if
    if st_mins(kef) ~= 0
        min_string = [num2str(st_mins(kef)), ' mins '];
    else
        min_string = '';
    end %if
    sim_time_string{kef} = [day_string, hour_string, min_string];
end %for
sim_time_string = string(sim_time_string);

end %function