function pp_reconstruction_data = duplicate_ports(port_multiple, pp_reconstruction_data)
% duplicate any required ports

if all(port_multiple == 1)
    return
end %if
port_names_in = pp_reconstruction_data.port_labels;
port_data_in = pp_reconstruction_data.port_data;
tstart_in = pp_reconstruction_data.port_t_start;

substructure = fieldnames(port_data_in);
port_data = replicate_structure(port_data_in, struct());
for wsh = 1:length(substructure)
    ck1 = 1;
    ck2 = 1;
    for une = 1:length(port_names_in) %simulated ports
        if port_multiple(une) ~= 0
            for kea = 1:port_multiple(une)
                data_fields = fieldnames(port_data_in.(substructure{wsh}));
                for wga = 1:length(data_fields)
                    try
                        % adding the try to cope with cases where there was a
                        % problem with data transfer and some of the files are
                        % not present.
                        port_data.(substructure{wsh}).(data_fields{wga}).data(ck2) = port_data_in.(substructure{wsh}).(data_fields{wga}).data(ck1);
                    catch
                        disp(['Missing port data file ', port_names_in{une}])
                    end %try
                end %for
                tstart(ck2) = tstart_in{ck1,2};
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

pp_reconstruction_data.port_labels = port_names;
pp_reconstruction_data.port_data = port_data;
pp_reconstruction_data.port_t_start = tstart;
