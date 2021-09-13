function [port_names, port_data, tstart] = duplicate_ports(port_multiple, port_names_in, port_data_in, tstart_in)
% duplicate any required ports


substructure = fieldnames(port_data_in);

for hs = 1:length(substructure)
    sub_substructure = fieldnames(port_data_in.(substructure{hs}));
    for wsh = 1:length(sub_substructure)
        ck1 = 1;
        ck2 = 1;
        for une = 1:length(port_names_in) %simulated ports
            if port_multiple(une) ~= 0
                for kea = 1:port_multiple(une)
                    if strcmp(substructure{hs}, 'time')
                        port_data.(substructure{hs}).(sub_substructure{wsh}).alpha(ck2) = port_data_in.(substructure{hs}).(sub_substructure{wsh}).alpha(ck1);
                        port_data.(substructure{hs}).(sub_substructure{wsh}).beta(ck2) = port_data_in.(substructure{hs}).(sub_substructure{wsh}).beta(ck1);
                        port_data.(substructure{hs}).(sub_substructure{wsh}).cutoff(ck2) = port_data_in.(substructure{hs}).(sub_substructure{wsh}).cutoff(ck1);
                        tstart(ck2) = tstart_in{ck1,2};
                    end %if
                    port_data.(substructure{hs}).(sub_substructure{wsh}).data(ck2) = port_data_in.(substructure{hs}).(sub_substructure{wsh}).data(:,ck1);
                    
                    if kea == 1
                        port_names{ck2} = port_names_in{une};
                    else
                        port_names{ck2} = [port_names_in{une},'_', num2str(kea)];
                    end %if
                    ck2 = ck2 + 1;
                end %for
                ck1 = ck1 +1;
            end %if
        end %for
    end %for
end %for
