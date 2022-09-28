function plot_s_parameter_transmission_graphs_port(data, beam_present, cols, lines, fig_pos, pth, prefix, lower_cutoff, linewidth)

% Just looking at mode 1.
mode=1;
excitations = unique(data.excitation_list);
for es=1:length(excitations) % Excitation port
    excitation_inds = find(strcmp(data.excitation_list, excitations{es}));
    if strcmp(beam_present, 'yes')
        exitation_port_number = es + 2;
    else
        exitation_port_number = es;
    end %if
    h = figure('Position',fig_pos);
    receivers = data.reciever_list(excitation_inds);
    for n=1:length(receivers) % Receiving port
        if ~isempty(data.data{excitation_inds(n)})
            x_data = data.scale{excitation_inds(n)}(mode, :) * 1e-9;
            y_data = 20 * log10(data.data{excitation_inds(n)}(mode, :));
            if n == 1
                min_y = min(y_data);
            end %if
            if max(y_data) > lower_cutoff
                if ~strcmp(excitations{es}, receivers{n})
                    if strcmp(beam_present, 'yes') && n > 2 % dont show the beam pipe ports.
                        min_y = add_data_to_sparameter_graph(x_data, y_data, mode, min_y, lines, cols, linewidth, n, exitation_port_number);
                    elseif strcmp(beam_present, 'no')
                        min_y = add_data_to_sparameter_graph(x_data, y_data, mode, min_y, lines, cols, linewidth, n, exitation_port_number);
                    end %if
                end %if
            end %if
        end %if
    end %for
    legend('Location', 'EastOutside')
    ylim([min_y 0])
    xlabel('Frequency (GHz)')
    ylabel('S parameters (dB)')
    title(['Port ',num2str(exitation_port_number),' excitation'])
    savemfmt(h, pth,[prefix, '_s_parameters_transmission_excitation_port_',num2str(exitation_port_number)])
    close(h)
end %for