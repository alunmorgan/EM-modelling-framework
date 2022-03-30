function [port_data_out] = port_data_remove_non_transmitting(port_data, log)
%  Filters out non transmitting modes.
%
% Example: [port_data_out] = port_data_remove_non_transmitting(port_data, log)
port_data_out = struct();
substructure = fieldnames(port_data);
for wsh = 1:length(substructure)
    if strcmp(substructure{wsh}, 'voltage_port_mode') || ...
            strcmp(substructure{wsh}, 'power_port_mode')
        for hes = 1:length(port_data.(substructure{wsh}).data) % simulated ports
            ck = 1;
            for wha = 1:size(port_data.(substructure{wsh}).data{hes},2) % modes
                if log.alpha{hes}(wha) == 0 % only interested in transmitting modes.
                    %                 If alpha =0 there is no imaginary component
                    port_data_out.(substructure{wsh}).alpha{hes}(ck) = log.alpha{hes}(wha);
                    port_data_out.(substructure{wsh}).beta{hes}(ck) = log.beta{hes}(wha);
                    port_data_out.(substructure{wsh}).cutoff{hes}(ck) = log.cutoff{hes}(wha);
                    port_data_out.(substructure{wsh}).data{hes}(:,ck) =...
                        port_data.(substructure{wsh}).data{hes}(:,wha);
                    ck = ck +1;
                end %if
            end %for
        end %for
    end %if
end %for



