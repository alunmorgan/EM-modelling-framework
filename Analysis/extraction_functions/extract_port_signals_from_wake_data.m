function [modes, max_mode, dominant_modes, port_mode_energy] = ...
extract_port_signals_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%


if isfield(wake_data.time_domain_data.port_data.power_port_mode.full_signal, 'port_mode_energy')
    %Using the remenant only signal for teh beam ports and the full signal for
    %the signal ports.
    port_mode_energy = cat(1,wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_mode_energy(1:2,:),...
        wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_mode_energy(3:end,:));
    port_mode_signals = cat(1,wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_mode_signals(1:2,:,:),...
        wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_mode_signals(3:end, :, :));
    [~, max_mode] = max(port_mode_energy,[],2);
    for ens = size(port_mode_signals, 1):-1:1 % ports
        dominant_modes{ens} =  squeeze(port_mode_signals(ens,max_mode(ens), :));     
        for seo = 1:size(port_mode_signals, 2) % modes
            modes{ens}{seo} =  squeeze(port_mode_signals(ens,seo, :));
        end %for
    end %for
else
    dominant_modes = NaN;
    modes = NaN;
    max_mode = NaN;
end %if
