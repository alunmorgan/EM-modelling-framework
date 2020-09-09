function [port_timebase, port_data] = read_port_datafiles(Port_mat)
% Extracts ports data from the GdfidL output graphs.
%
% Example: [port_timebase, port_data] = read_port_datafiles(Port_mat)

temp_data = GdfidL_read_graph_datafile( Port_mat{1,1});
port_timebase = temp_data.data(:,1);

for hes = 1:size(Port_mat,1) % simulated ports
    for wha = 1:size(Port_mat,2) % modes
        if ~isempty(Port_mat{hes,wha})
            temp_data  = GdfidL_read_graph_datafile( Port_mat{hes,wha} );
            temp_data = temp_data.data(:,2);
            port_data{hes}(:,wha) = temp_data(:);
        end %if
        clear temp_data
    end %for
end %for

