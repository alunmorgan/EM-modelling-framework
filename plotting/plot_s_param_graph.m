function plot_s_param_graph(s, cols_sep, fig_pos, pth, lower_cutoff, linewidth)
% plots the s parameter results.
%
% Example: plot_s_param_graph(s, cols_sep, fig_pos, pth)

h(1) = figure('Position',fig_pos);

for nre = 1:length(s.port_list) % excitation ports
    s_in  = find_position_in_cell_lst(strfind(s.all_ports,s.port_list{nre}));
    for es = 1:length(s.all_ports) % receiving ports
        np = 1;
        hold on
        tmp_data = s.data{nre,es};
        for m=1:size(tmp_data,1) % Iterate over modes
            if max(20* log10(tmp_data(m,1:end-2))) > lower_cutoff
                plot(s.scale(1:end-2) * 1e-9, 20* log10(tmp_data(m,1:end-2)), '-',...
                    'Color', cols_sep{rem(m,length(cols_sep))+1}, ...
                    'Linewidth', linewidth,...
                    'DisplayName',strcat('S',num2str(s_in), num2str(es), '(',num2str(m), ')'));
                np = np +1;
            end %if
        end %for
        if np == 1
            clf(h(1))
            continue
        end %if
        hold off
        t_string1 = ['S(',num2str(s_in),',',num2str(es),')'];
        legend('Location', 'EastOutside')
        ylim([lower_cutoff 0])
        %         xlim([0 5])
        xlabel('Frequency (GHz)')
        ylabel('S parameters (dB)')
        title(['S parameters ', t_string1])
        savemfmt(h(1), pth,['s_parameters_S',num2str(s_in),num2str(es)])
        clf(h(1))
    end %for
end %for
close(h(1))