function plot_s_parameter_reflection_graph(data, beam_present, cols, lines, fig_pos, ...
    pth, prefix, port_names, lower_cutoff, linewidth)

mode = 1;
h = figure('Position',fig_pos);
if strcmp(beam_present, 'yes')
    start_port = 3;
else
    start_port = 1;
end %if
for nre = start_port:length(port_names) % excitation ports
    excitation_inds = find(strcmp(data.excitation_list, port_names{nre}));
    receiver_inds = find(strcmp(port_names, data.reciever_list{excitation_inds(nre)}));
        x_data = data.scale{excitation_inds(receiver_inds)}(mode, :) * 1e-9;
        y_data = 20* log10(data.data{excitation_inds(receiver_inds)}(mode, :));
        if max(y_data) < lower_cutoff
            continue
        end %if
        hl = plot(x_data, y_data,...
            'Linestyle',lines{rem(nre,length(lines))+1},...
            'Color', cols{rem(nre,length(cols))+1},...
            'LineWidth',  linewidth,...
            'DisplayName', strcat(regexprep(port_names{nre}, '_', ' '),...
            ' S',num2str(nre), num2str(nre), ...
            '(',num2str(mode),')' ));
        hold all;
        %     end %if
end %if
grid on 
legend('Location', 'NorthOutside', 'NumColumns', 2)
ylim([-inf 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('Reflection')
savemfmt(h, pth,[prefix, '_s_parameters_reflection_mode_1'])
close(h)