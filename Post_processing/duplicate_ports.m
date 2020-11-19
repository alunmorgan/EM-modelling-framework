function [port_names, alpha, beta, port_data, cutoff, tstart] = duplicate_ports(port_multiple, port_names_in, alpha_in, beta_in, port_data_in, cutoff_in, tstart_in)
% duplicate any required ports
ck1 = 1;
ck2 = 1;
for une = 1:length(port_names_in) %simulated ports
    if port_multiple(une) ~= 0
    for kea = 1:port_multiple(une)
        alpha(ck2) = alpha_in(ck1);
        beta(ck2) = beta_in(ck1);
        port_data(ck2) = port_data_in(:,ck1);
        cutoff(ck2) = cutoff_in(ck1);
        tstart(ck2) = tstart_in(ck1);
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
