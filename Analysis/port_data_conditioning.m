function [port_data_out] = port_data_conditioning(port_data, log, ...
    port_fill_factor)
% scales ports data using the provided port fill factor. Filters out non
% transmitting modes.
%
% Example: [alpha, beta, port_data, cutoff] = port_data_conditioning(port_data, log, ...
%    port_fill_factor)
port_data_out = struct();
substructure = fieldnames(port_data);

for hs = 1:length(substructure)
    sub_substructure = fieldnames(port_data.(substructure{hs}));
    for wsh = 1:length(sub_substructure)
        for hes = 1:length(port_data.(substructure{hs}).(sub_substructure{wsh})) % simulated ports
            ck = 1;
            for wha = 1:size(port_data.(substructure{hs}).(sub_substructure{wsh}){hes},2) % modes
                if log.alpha{hes}(wha) == 0 % only interested in transmitting modes.
                    %                 If alpha =0 there is no imaginary component
                    if strcmp(substructure{hs}, 'time')
                    port_data_out.(substructure{hs}).(sub_substructure{wsh}).alpha{hes}(ck) = log.alpha{hes}(wha);
                    port_data_out.(substructure{hs}).(sub_substructure{wsh}).beta{hes}(ck) = log.beta{hes}(wha);
                    port_data_out.(substructure{hs}).(sub_substructure{wsh}).cutoff{hes}(ck) = log.cutoff{hes}(wha);
                    end %if
                    % divided by the port fill factor as it is the
                    % energy which is reduced by the fill factor.
                    % The port signals are reported as a power (i*h [W]).
                    % or as a voltage [sqrt(W)]
                    port_data_out.(substructure{hs}).(sub_substructure{wsh}).data{hes}(:,ck) = port_data.(substructure{hs}).(sub_substructure{wsh}){hes}(:,wha) ./ port_fill_factor(hes);
                    ck = ck +1;
                end %if
            end %for
        end %for
    end %for
end %for
    
    
