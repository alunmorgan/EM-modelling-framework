function plot_s_parameter_reflection_graph(pp_data, beam_present, cols, lines, fig_pos, pth, lower_cutoff, linewidth,trim_fraction)

mode = 1;
h = figure('Position',fig_pos);
min_y = 0;
excitations = unique(pp_data.excitation_list);
recievers = unique(pp_data.reciever_list);
for nre = 1:length(excitations) % excitation ports
    excitation_inds = find(strcmp(pp_data.excitation_list, excitations{nre}));
    if strcmp(beam_present, 'yes')
        exitation_port_number = nre + 2;
    else
        exitation_port_number = nre;
    end %if
    receiver_inds = find(strcmp(pp_data.reciever_list(excitation_inds), excitations{nre}));
        x_data = pp_data.scale{excitation_inds(receiver_inds)}(mode, :) * 1e-9;
        y_data = 20* log10(pp_data.data{excitation_inds(receiver_inds)}(mode, :));
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
savemfmt(h, pth,[pp_data.set, '_s_parameters_reflection_mode_1'])
close(h)