function [port_names, port_timebase,  port_data_all, ...
    cutoff_all, alpha_all, beta_all,...
    port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
    port_fill_factor,port_multiple, port_names_table)
% Extracts ports data from the GdfidL output graphs.
%
% Example: [port_names, port_timebase,  port_data_all, ...
%     cutoff_all, alpha_all, beta_all,...
%     port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
%     port_fill_factor,port_multiple, port_names_table)

% construct port matrix
[ temp_data ] = GdfidL_read_graph_datafile( Port_mat{1,1});%, log, port_fill_factor);
port_timebase = temp_data.data(:,1);
ck = 1;
ck2 = 1;
port_data_all = {};
port_data = {};
cutoff_all = {};
cutoff = {};
alpha_all = {};
beta_all = {};
for hes = 1:size(Port_mat,1) % ports
    for nsaw = 1:port_multiple(hes) % duplicate port if the multiple is more than 1
        % flag to show when the first transmitting mode has been found.
        % any non transmissing modes above this frequency are due to
        % numerical limitation and need to be removed.
        t_flag = 0;
        for wha = 1:size(Port_mat,2) % modes
            if ~isempty(Port_mat{hes,wha})
                temp_data  = GdfidL_read_graph_datafile( Port_mat{hes,wha} );
                temp_data = temp_data.data(:,2);
                if log.beta{hes}(wha) == 0
                    t_flag = 1;
                end
                if t_flag == 0 || log.beta{hes}(wha) ~= 0
                    % divided by the sqrt of the fill factor as it is the
                    % energy which is reduced by the fill factor. So the
                    % signal is reduced by sqrt of the fill factor.
                    %(as energy = signal^2)
                    port_data_all{ck}(:,wha) = temp_data(:) ./ sqrt(port_fill_factor(hes));
                    if nsaw == 1
                        cutoff_all{ck2}(wha) = log.cutoff{hes}(wha);
                        alpha_all{ck2}(wha) = log.alpha{hes}(wha);
                        beta_all{ck2}(wha) = log.beta{hes}(wha);
                    end
                    if log.alpha{hes}(wha) == 0
                        % only take the transmitting ports.
                        port_data{ck}(:,wha) = temp_data(:) ./ sqrt(port_fill_factor(hes));
                        cutoff{ck}(wha) = log.cutoff{hes}(wha);
                    end
                end
                %   clear temp_data
                temp_data =[];
            end
        end %for
        if nsaw == 1
            port_names{ck} = port_names_table{hes};
            ck2 = ck2 + 1;
        else
            port_names{ck} = [port_names_table{hes},'_', num2str(nsaw)];
        end %if
        ck = ck +1;
    end
    
end
