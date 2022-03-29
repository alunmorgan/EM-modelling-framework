function [port_data_out] = port_data_remove_non_transmitting(port_data, log)
%  Filters out non transmitting modes.
%
% Example: [port_data_out] = port_data_remove_non_transmitting(port_data, log)
port_data_out = struct();
substructure = fieldnames(port_data);
for nes = 1:length(substructure) %time/ frequency
    if strcmp(substructure{nes}, 'time') || strcmp(substructure{nes}, 'frequency')
        sub_substructure = fieldnames(port_data.(substructure{nes}));
        for wsh = 1:length(sub_substructure)
            for hes = 1:length(port_data.(sub_substructure{wsh})) % simulated ports
                ck = 1;
                for wha = 1:size(port_data.(sub_substructure{wsh}){hes},2) % modes
                    if log.alpha{hes}(wha) == 0 % only interested in transmitting modes.
                        %                 If alpha =0 there is no imaginary component
                        if strcmp(substructure{nes}, 'time')
                            port_data_out.(substructure{nes}).(sub_substructure{wsh}).alpha{hes}(ck) = log.alpha{hes}(wha);
                            port_data_out.(substructure{nes}).(sub_substructure{wsh}).beta{hes}(ck) = log.beta{hes}(wha);
                            port_data_out.(substructure{nes}).(sub_substructure{wsh}).cutoff{hes}(ck) = log.cutoff{hes}(wha);
                        end %if
                        port_data_out.(substructure{nes}).(sub_substructure{wsh}).data{hes}(:,ck) =...
                            port_data.(substructure{nes}).(sub_substructure{wsh}){hes}(:,wha);
                        ck = ck +1;
                    end %if
                end %for
            end %for
        end %for
    end %if
end %for


