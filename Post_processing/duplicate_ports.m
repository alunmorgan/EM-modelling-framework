function [port_names, port_data, tstart] = duplicate_ports(port_multiple, port_names_in, port_data_in, tstart_in)
% duplicate any required ports


substructure = fieldnames(port_data_in);
port_data = struct;
for wsh = 1:length(substructure)
    ck1 = 1;
    ck2 = 1;
    for une = 1:length(port_names_in) %simulated ports
        if port_multiple(une) ~= 0
            for kea = 1:port_multiple(une)
                data_fields = fieldnames(port_data_in.(substructure{wsh}));
                for wga = 1:length(data_fields)
                    port_data.(substructure{wsh}).(data_fields{wga})(ck2) = port_data_in.(substructure{wsh}).(data_fields{wga})(ck1);
                end %for
                %port_data.(substructure{wsh}).beta(ck2) = port_data_in.(substructure{wsh}).beta(ck1);
                %                     port_data.(substructure{wsh}).cutoff(ck2) = port_data_in.(substructure{wsh}).cutoff(ck1);
                tstart(ck2) = tstart_in{ck1,2};
                %                 port_data.(substructure{wsh}).data(ck2) = port_data_in.(substructure{wsh}).data(:,ck1);
                
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

