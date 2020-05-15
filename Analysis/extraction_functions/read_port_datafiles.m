function [port_names, port_timebase,alpha, beta,...
        port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
    port_fill_factor,port_multiple, port_names)
% Extracts ports data from the GdfidL output graphs.
%
% Example: [port_names, port_timebase,  port_data_all, ...
%     cutoff_all, alpha_all, beta_all,...
%     port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
%     port_fill_factor,port_multiple, port_names_table)

port_names = cat(2, 'Beam_port_in', 'Beam_port_out', port_names);
%TEMP modelling inputs should have all the port names not just the signal ports

% construct port matrix
[ temp_data ] = GdfidL_read_graph_datafile( Port_mat{1,1});%, log, port_fill_factor);
port_timebase = temp_data.data(:,1); % this step is not needed as everything is now on a common timebase.
% port_data = {};
% cutoff = {};
for hes = 1:size(Port_mat,1) % simulated ports
    ck = 1;
    for wha = 1:size(Port_mat,2) % modes
        if ~isempty(Port_mat{hes,wha})
            if log.beta{hes}(wha) == 0 % only interested in transmitting modes.
                temp_data  = GdfidL_read_graph_datafile( Port_mat{hes,wha} );
                temp_data = temp_data.data(:,2);
                
                % divided by the sqrt of the fill factor as it is the
                % energy which is reduced by the fill factor. So the
                % signal is reduced by sqrt of the fill factor.
                %(as energy = signal^2)
                alpha_tmp{hes}(ck) = log.alpha{hes}(wha);
                beta_tmp{hes}(ck) = log.beta{hes}(wha);
                port_data_tmp{hes}(:,ck) = temp_data(:) ./ sqrt(port_fill_factor(hes));
                cutoff_tmp{hes}(ck) = log.cutoff{hes}(wha);
                ck = ck +1;
            end %if
        end %if
        clear temp_data
    end %for
end %for
% duplicate any required ports
ck2 = 1;
for une = 1:size(Port_mat,1)
    for kea = 1:port_multiple(une)
        alpha(ck2) = alpha_tmp(une);
        beta(ck2) = beta_tmp(une);
        port_data(ck2) = port_data_tmp(:,une);
        cutoff(ck2) = cutoff_tmp(une);
        if kea == 1
            port_names{ck2} = port_names{une};
        else
            port_names{ck2} = [port_names{une},'_', num2str(kea)];
        end %if      
        ck2 = ck2 + 1;
    end %for
end %for

