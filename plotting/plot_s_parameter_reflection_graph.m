function plot_s_parameter_reflection_graph(data, beam_present, cols, lines, fig_pos, ...
    pth, prefix, lower_cutoff, linewidth)

mode = 1;
h = figure('Position',fig_pos);
min_y = 0;
excitations = unique(data.excitation_list);
recievers = unique(data.reciever_list);
for nre = 1:length(excitations) % excitation ports
    excitation_inds = find(strcmp(data.excitation_list, excitations{nre}));
    if strcmp(beam_present, 'yes')
        exitation_port_number = nre + 2;
    else
        exitation_port_number = nre;
    end %if
    receiver_inds = find(strcmp(data.reciever_list(excitation_inds), excitations{nre}));
        x_data = data.scale{excitation_inds(receiver_inds)}(mode, :) * 1e-9;
        y_data = 20* log10(data.data{excitation_inds(receiver_inds)}(mode, :));
        if max(y_data) < lower_cutoff
            continue
        end %if
        if min(y_data) < min_y
            min_y = min(y_data);
        end %if
        hl = plot(x_data, y_data,...
            'Linestyle',lines{rem(exitation_port_number,length(lines))+1},...
            'Color', cols{rem(exitation_port_number,length(cols))+1},...
            'LineWidth',  linewidth,...
            'DisplayName', strcat('S',num2str(exitation_port_number), num2str(exitation_port_number), '(',num2str(mode),')'));
        hold all;
%     end %if
end %if

legend('Location', 'EastOutside')
ylim([min_y 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('Reflection')
savemfmt(h, pth,[prefix, '_s_parameters_reflection_mode_1'])
close(h)