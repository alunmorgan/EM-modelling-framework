function [timebase,  modes, max_mode, dominant_modes, port_cumsum, t_start] = ...
extract_port_signals_from_wake_data(pp_data, wake_data, lab_ind)
% wake data (structure): contains all the data from the wake postprocessing
%

 timebase = wake_data.time_domain_data.timebase *1E9; %in ns
    t_start = pp_data.port.t_start;

if isfield(pp_data.port, 'data') && isfield(wake_data.port_time_data, 'port_mode_energy')
    [~, max_mode] = max(wake_data.port_time_data.port_mode_energy,[],2);
    for ens = length(lab_ind):-1:1 % ports
%         [~, max_mode(ens)] = max(squeeze(wake_data.port_time_data.port_mode_energy{lab_ind(ens)}(:)));
        dominant_modes{ens} =  squeeze(wake_data.port_time_data.port_mode_signals(lab_ind(ens),max_mode(ens), :));     
        for seo = 1:size(wake_data.port_time_data.port_mode_signals, 2) % modes
            modes{ens}{seo} =  squeeze(wake_data.port_time_data.port_mode_signals(lab_ind(ens),seo, :));
        end %for
    end %for
else
    dominant_modes = NaN;
    modes = NaN;
    max_mode = NaN;
end %if

if isfield(wake_data.port_time_data, 'total_energy_cumsum')
    port_cumsum = wake_data.port_time_data.total_energy_cumsum;
else
    port_cumsum = NaN;
end %if
