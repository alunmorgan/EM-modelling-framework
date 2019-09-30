function [timebase_cs, e_total_cs, e_ports_cs] =  extract_cumulative_total_energy_from_wake_data(wake_data)
%
% wake data (structure): contains all the data from the wake postprocessing
%
% timebase_cs (vector): timebase in ns.
% e_total_cs (vector): cumulative sum of the total energy in the structure (nJ).
% e_ports_cs (vector): cumulative sum of the energy transmitted out of the ports (nJ).

if wake_data.port_time_data.total_energy ~=0
    e_ports_cs = wake_data.port_time_data.port_energy_cumsum' .* 1e9;
    e_total_cs = wake_data.port_time_data.total_energy_cumsum .* 1e9;
    timebase_cs = wake_data.port_time_data.timebase * 1e9;
else
    if isfield(wake_data.port_time_data, 'data')
    e_ports_cs = zeros(1,length(wake_data.port_time_data.data));
    else
        % no ports have transmitting modes.
        e_ports_cs = 0;
    end %if
    e_total_cs = 0;
    timebase_cs = 0;
end
