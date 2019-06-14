function [timebase_cs, e_total_cs, e_ports_cs] =  extract_cumulative_total_energy_from_wake_data(pp_data, wake_data)
%
% wake data (structure): contains all the data from the wake postprocessing
%
% timebase_cs (vector): timebase in ns.
% e_total_cs (vector): cumulative sum of the total energy in the structure (nJ).
% e_ports_cs (vector): cumulative sum of the energy transmitted out of the ports (nJ).


if wake_data.port_time_data.total_energy ~=0
    t_step = wake_data.port_time_data.timebase(2) - wake_data.port_time_data.timebase(1);
    for jsff = length(wake_data.port_time_data.data):-1:1 % number of ports
        tmp = sum(wake_data.port_time_data.data{jsff},2);
        e_ports_cs(:,jsff) = cumsum(tmp.^2) * t_step * 1e9;
    end
    e_total_cs = sum(e_ports_cs,2) * 1e9;
else
    e_ports_cs = zeros(1,length(wake_data.port_time_data.data));
    e_total_cs = 0;
end
timebase_cs = wake_data.port_time_data.timebase *1e9;