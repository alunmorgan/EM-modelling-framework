function plot_s_parameter_transmission_graphs_port(data, beam_present, cols, lines, fig_pos, pth, prefix, port_names, lower_cutoff, linewidth)

% Just looking at mode 1.
mode=1;
if strcmp(beam_present, 'yes')
    start_port = 3;
else
    start_port = 1;
end %if
for es = start_port:length(port_names) % excitation ports
    excitation_inds = find(strcmp(data.excitation_list, port_names{es}));
    h = figure('Position',fig_pos);
    for n=1:length(port_names) % Receiving ports
        receiver_port_number = find(strcmp(port_names, data.reciever_list{excitation_inds(n)}));
        if es ~= receiver_port_number
            if ~isempty(data.data{excitation_inds(n)})
                x_data = data.scale{excitation_inds(n)}(mode, :) * 1e-9;
                y_data = 20 * log10(data.data{excitation_inds(n)}(mode, :));
                if max(y_data) > lower_cutoff
                        add_data_to_sparameter_graph(x_data, y_data, mode, lines, cols, linewidth, receiver_port_number, es, port_names);
                end %if
            end %if
        end %if
    end %for
    grid on
    legend('Location', 'NorthOutside', 'NumColumns', 2)
    ylim([-inf 0])
    xlabel('Frequency (GHz)')
    ylabel('S parameters (dB)')
    title(['Port ',num2str(es),' excitation'])
    savemfmt(h, pth,[prefix, '_s_parameters_transmission_excitation_port_',num2str(es)])
    close(h)
end %for