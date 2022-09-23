function [beam_port_spectrum, Total_energy_from_beam_ports,...
    signal_port_spectrum, Total_energy_from_signal_ports,...
    Total_port_spectrum, Total_energy_from_all_ports] = ...
    find_port_power_loss(raw_port_mode_energy_spectrum)
%%%%%% This is all for model charge %%%%%%%%%%%%%%%%
% for a single port
    %combining all the modes.
    for ne = 1:length(raw_port_mode_energy_spectrum)
    raw_port_energy_spectrum = squeeze(sum(raw_port_mode_energy_spectrum{ne},2));
    beam_port_spectrum{ne} = squeeze(sum(raw_port_energy_spectrum(1:2,:),1));
    signal_port_spectrum{ne} = squeeze(sum(raw_port_energy_spectrum(3:end,:),1));
    Total_port_spectrum{ne} = squeeze(sum(raw_port_energy_spectrum,1));
    Total_energy_from_beam_ports{ne}  = sum(beam_port_spectrum{ne}, 2);
    Total_energy_from_signal_ports{ne}  = sum(signal_port_spectrum{ne}, 2);
    Total_energy_from_all_ports{ne} = sum(Total_port_spectrum{ne}, 2);
    end %for