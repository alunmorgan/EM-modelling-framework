function [timebase,  modes, max_mode, dominant_modes, port_cumsum, t_start] = ...
extract_port_signals_from_wake_data(pp_data, wake_data, lab_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
if isfield(pp_data.port, 'timebase')
    timebase = pp_data.port.timebase *1E9; %in ns
else
    timebase = NaN;
end %if

if isfield(pp_data.port, 'data')
    for ens = length(lab_ind):-1:1 % ports
        [~, max_mode(ens)] = max(squeeze(wake_data.port_time_data.port_mode_energy{lab_ind(ens)}(:)));
        dominant_modes{ens} =  squeeze(pp_data.port.data{lab_ind(ens)}(:,max_mode(ens)));
        
        for seo = 1:size(pp_data.port.data{lab_ind(ens)},2) % modes
            modes{ens}{seo} =  squeeze(pp_data.port.data{lab_ind(ens)}(:,seo));
        end %for
    end %for
else
    dominant_modes = NaN;
    modes = NaN;
end %if

if isfield(wake_data.port_time_data, 'total_energy_cumsum')
    port_cumsum = wake_data.port_time_data.total_energy_cumsum;
else
    port_cumsum = NaN;
end %if
t_start = pp_data.port.t_start;