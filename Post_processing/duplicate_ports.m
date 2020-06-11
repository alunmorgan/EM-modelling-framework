function [port_names, alpha, beta, port_data, cutoff, tstart] = duplicate_ports(port_multiple, Port_mat, port_names_in, alpha_in, beta_in, port_data_in, cutoff_in, tstart_in)
% duplicate any required ports
ck2 = 1;
%TODO make code able to cope with zeros in the middle of the port multiple list.
for une = 1:size(Port_mat,1) %simulated ports
    for kea = 1:port_multiple(une)
        alpha(ck2) = alpha_in(une);
        beta(ck2) = beta_in(une);
        port_data(ck2) = port_data_in(:,une);
        cutoff(ck2) = cutoff_in(une);
        tstart(ck2) = tstart_in(une);
        if kea == 1
            port_names{ck2} = port_names_in{une};
        else
            port_names{ck2} = [port_names_in{une},'_', num2str(kea)];
        end %if      
        ck2 = ck2 + 1;
    end %for
end %for
