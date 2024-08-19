function port_data = port_data_sum_modes(port_data)
% Adds a datastream of the sum of all modes
%
% Example: port_data_out = port_data_sum_modes(port_data)

substructure = fieldnames(port_data);

for hs = 1:length(substructure)
    sub_substructure = fieldnames(port_data.(substructure{hs}));
    new_sub_substructure = regexprep(sub_substructure, '_mode', '');
    for wsh = 1:length(sub_substructure)
        if contains(sub_substructure{wsh}, '_mode')
            for hes = 1:length(port_data.(substructure{hs}).(sub_substructure{wsh}).data) % simulated ports
                port_data.(substructure{hs}).(new_sub_substructure{wsh}).data{hes} =...
                    sum(port_data.(substructure{hs}).(sub_substructure{wsh}).data{hes},2);
            end %for
        end %if
    end %for
end %for
