function [bunch_energy_loss, beam_port_energy_loss, ...
    signal_port_energy_loss] =  extract_energy_loss_data_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
bunch_energy_loss = wake_data.time_domain_data.loss_from_beam * 1e9; %nJ
% Ignoring the signal from the bunch passing through the ports.
beam_port_energy_loss = sum(wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_energy(1:2))* 1e9; %nJ
if length(wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_energy) > 2
    % add signal ports if there is any signal.
    signal_port_energy_loss = sum(wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_energy(3:end))* 1e9;
else
    signal_port_energy_loss = NaN;
end %if
