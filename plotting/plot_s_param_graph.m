function plot_s_param_graph(data, beam_present, cols_sep, fig_pos, pth, prefix, port_names, lower_cutoff, linewidth)
% plots the s parameter results.
%
% Example: plot_s_param_graph(s, cols_sep, fig_pos, pth)

if strcmp(beam_present, 'yes')
    start_port = 3;
else
    start_port = 1;
end %if
for nre = start_port:length(port_names) % excitation ports
    excitation_inds = find_position_in_cell_lst(strfind(data.excitation_list, port_names{nre}));
    for es = 1:length(excitation_inds) % receiving ports
        receiver_inds = find(strcmp(port_names, data.reciever_list{excitation_inds(es)}));

        h = figure('Position',fig_pos);
        np = 1;
        hold on
        for m=1:size(data.scale{excitation_inds(es)},1) % Iterate over modes
            x_data = data.scale{excitation_inds(es)}(m, :) * 1e-9;
            y_data = 20* log10(data.data{excitation_inds(es)}(m, :));
            if max(y_data) > lower_cutoff
                plot(x_data, y_data, '-',...
                    'Color', cols_sep{rem(m,length(cols_sep))+1}, ...
                    'Linewidth', linewidth,...
                    'DisplayName',strcat('S',num2str(receiver_inds), num2str(nre), '(',num2str(m), ')'));
                np = np +1;
            end %if
        end %for
        if np == 1
            continue
        end %if
        hold off
        legend('Location', 'NorthOutside', 'NumColumns', 2)
        ylim([-inf 0])
        xlabel('Frequency (GHz)')
        ylabel('S parameters (dB)')
        grid on
        savemfmt(h, pth,[prefix,'_s_parameters_S',num2str(receiver_inds), num2str(nre)])
        close(h)
    end %for
end %for