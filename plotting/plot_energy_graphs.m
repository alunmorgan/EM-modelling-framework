function plot_energy_graphs(h_wake, path_to_data, m_time, m_data, ...
    material_names, col_ofst, timebase, port_cumsum,...
    e_ports_cs, e_total_cs, cut_time_ind, y_lev_t, lw, l_st, port_names)

clf(h_wake)
if ~isnan(m_time{1})
    ax(3) = axes('Parent', h_wake);
    cols = col_gen(length(m_time) + col_ofst);
    for na = 1:length(m_time)
        hold on
        plot(ax(3), m_time{na} ,m_data{na}, 'Color', cols(na+col_ofst,:),...
            'LineWidth',lw, ...
            'DisplayName', material_names{na})
        hold off
    end %for
    legend(ax(3), 'Location', 'SouthEast')
    xlabel(ax(3), 'Time (ns)')
    ylabel(ax(3), 'Energy (nJ)')
    title('Material loss over time', 'Parent', ax(3))
    savemfmt(h_wake, path_to_data,'Material_loss_over_time')
    clf(h_wake)
end %if

%% Cumulative total energy.
if ~all(isnan(timebase)) && ~all(isnan(port_cumsum))
    ax(4) = axes('Parent', h_wake);
    if ~isempty(cut_time_ind)
        plot(timebase(1:cut_time_ind), e_total_cs(1:cut_time_ind),'b','LineWidth',lw, 'Parent', ax(4))
        graph_add_horizontal_lines(y_lev_t)
        title('Cumulative Energy seen at all ports', 'Parent', ax(4))
        xlabel('Time (ns)', 'Parent', ax(4))
        ylabel('Cumulative Energy (nJ)', 'Parent', ax(4))
        xlim([0 timebase(end)])
        text(timebase(cut_time_ind), y_lev_t(1), '100%')
        fr = (e_total_cs(cut_time_ind) / y_lev_t(1)) *100;
        text(timebase(cut_time_ind), e_total_cs(end), [num2str(round(fr)),'%'])
    end %if
    savemfmt(h_wake, path_to_data,'cumulative_total_energy')
    clf(h_wake)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Cumulative energy seen at each port.
    ax(5) = axes('Parent', h_wake);
    hold(ax(5), 'all')
    cport_cols = col_gen(length(port_names));
    for ens = 1:length(port_names)
        plot(timebase(1:cut_time_ind), e_ports_cs(1:cut_time_ind, ens),...
            'Color',cport_cols(ens,:),'LineWidth',lw, 'LineStyle', l_st{1}, ...
            'Parent', ax(5), 'DisplayName', regexprep(port_names{ens},'_',' '))
    end %for
    hold(ax(5), 'off')
    title('Cumulative energy seen at the ports (nJ)', 'Parent', ax(5))
    xlabel('Time (ns)', 'Parent', ax(5))
    ylabel('Cumulative Energy (nJ)', 'Parent', ax(5))
    xlim([timebase(1) timebase(cut_time_ind)])
    legend(ax(5), 'Location', 'SouthEast')
    savemfmt(h_wake, path_to_data,'cumulative_energy')
    clf(h_wake)
end %if