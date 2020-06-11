function out = get_wlf(model_sets)


[root, ~, ~] = analysis_model_settings_library;
[extracted_data] = extract_all_wlf(root, model_sets);
wlf = round(extracted_data.wlf .* 1E-9);
sim_time_string = sec_to_time_string(extracted_data.simulation_time);
mesh_stepsize = extracted_data.mesh_density ./ extracted_data.mesh_scaling .* 1e6;
timestep = round(extracted_data.timestep .* 1E15);
number_of_cells = round(extracted_data.number_of_cells ./ 1E6);
for kfn = 1:size(extracted_data.model_names,1)
    varnames = {'simulation time', 'number of mesh cells (million)', ...
        'memory used (MB)', 'timestep (fs)', ...
        'wlf (mV/pC)', 'wake length (m)', ...
        'mesh stepsize (um)', 'number of cores'};
    T = table(sim_time_string(kfn,:)', number_of_cells(kfn,:)', ...
        extracted_data.memory_usage(kfn,:)', timestep(kfn,:)',...
        wlf(kfn,:)', extracted_data.wake_length(kfn,:)', ...
        mesh_stepsize(kfn,:)',...
        extracted_data.n_cores(kfn,:)',...
        'RowNames', extracted_data.model_names(kfn, :)', 'VariableNames', varnames);
    disp(T)
    out.(model_sets{kfn}).wlf_table = T;
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