function [port_data_out] = port_data_fill_factor_scaling(port_data, port_fill_factor)
% scales ports data using the provided port fill factor. 
%
% Example: [port_data_out] = port_data_conditioning(port_data, port_fill_factor)
port_data_out = struct();
substructure = fieldnames(port_data);

for hs = 1:length(substructure)
    sub_substructure = fieldnames(port_data.(substructure{hs}));
    for wsh = 1:length(sub_substructure)
        for hes = 1:length(port_data.(substructure{hs}).(sub_substructure{wsh})) % simulated ports
            for wha = 1:size(port_data.(substructure{hs}).(sub_substructure{wsh}){hes},2) % modes
                    % divided by the port fill factor as it is the
                    % energy which is reduced by the fill factor.
                    % The port signals are reported as a power (i*h [W]).
                    % or as a voltage [sqrt(W)]
                    port_data_out.(substructure{hs}).(sub_substructure{wsh}).data{hes}(:,wha) =...
                        port_data.(substructure{hs}).(sub_substructure{wsh}){hes}(:,wha) ./ port_fill_factor(hes);
            end %for
        end %for
    end %for
end %for
    