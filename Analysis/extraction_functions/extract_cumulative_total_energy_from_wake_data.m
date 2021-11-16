function [e_total_cs, e_ports_cs] =  extract_cumulative_total_energy_from_wake_data(wake_data)
%
% wake data (structure): contains all the data from the wake postprocessing
%
% timebase_cs (vector): timebase in ns.
% e_total_cs (vector): cumulative sum of the total energy in the structure (nJ).
% e_ports_cs (vector): cumulative sum of the energy transmitted out of the ports (nJ).

if wake_data.time_domain_data.port_data.power_port_mode.full_signal.total_energy ~=0
    % only capturing the remnant signal from the beam ports, but the full signal
    % from the signal ports.
    e_ports_cs = cat(1,wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_energy_cumsum(1:2,:),...
        wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_energy_cumsum(3:end,:))' .* 1e9; %nJ
    e_total_cs = sum(e_ports_cs,2); %nJ
else
    % no ports have transmitting modes.
    e_ports_cs = 0;
    e_total_cs = 0;
end
