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