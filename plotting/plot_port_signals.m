function plot_port_signals(h_wake, path_to_data, ...
    cut_time_ind, max_mode, ...
    dominant_modes,port_names, timebase_port, modes)

clf(h_wake)
[hwn, ksn] = num_subplots(length(port_names));
for ens = length(port_names):-1:1 % ports
    ax_sp(ens) = subplot(hwn,ksn,ens);
    plot(timebase_port(1:cut_time_ind), dominant_modes{ens}(1:cut_time_ind), 'b', 'Parent', ax_sp(ens))
    title([port_names{ens}, ' (mode ',num2str(max_mode(ens)),')'], 'Parent', ax_sp(ens))
    xlim([timebase_port(1) timebase_port(cut_time_ind)])
    xlabel('Time (ns)', 'Parent', ax_sp(ens))
%     graph_add_background_patch(pp_data.port.t_start(ens) * 1E9)
    ylabel('', 'Parent', ax_sp(ens))
end %for
savemfmt(h_wake, path_to_data,'dominant_port_signals')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hwn, ksn] = num_subplots(length(port_names));
for ens = length(port_names):-1:1 % ports
    ax_sp2(ens) = subplot(hwn,ksn,ens);
    hold(ax_sp2(ens), 'all')
    for seo = 1:length(modes{ens}) % modes
        plot(timebase_port(1:cut_time_ind), modes{ens}{seo}(1:cut_time_ind), 'Parent',ax_sp2(ens))
    end %for
    hold(ax_sp2(ens), 'off')
    title(port_names{ens}, 'Parent', ax_sp2(ens))
    xlabel('Time (ns)', 'Parent', ax_sp2(ens))
    ylabel('', 'Parent', ax_sp2(ens))
    xlim([timebase_port(1) timebase_port(cut_time_ind)])
%     graph_add_background_patch(pp_data.port.t_start(ens) * 1E9)
end %for
savemfmt(h_wake, path_to_data,'port_signals')
clf(h_wake)
end %if