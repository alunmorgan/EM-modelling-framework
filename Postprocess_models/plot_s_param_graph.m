function plot_s_param_graph(n, es, s, cols_sep, fig_pos, pth)
% plots the s parameter results.
%
% Example: plot_s_param_graph(n, es, s, cols_sep, fig_pos, pth)

figure('Position',fig_pos)
figure_setup_bounding_box
np = 1;
leg = {};

s_in  = find_position_in_cell_lst(strfind(s.all_ports,s.port_list{es}));
    for m=1:size(s.data{es,n},1); % Iterate over modes
        if max(20* log10(s.data{es,n}(m,1:end-2))) > -40
            hold on
            plot(s.scale(1:end-2) * 1e-9, 20* log10(s.data{es,n}(m,1:end-2)), '-',...
                'Color', cols_sep{rem(m,7)+1})
            leg{np} = strcat('S',num2str(s_in), num2str(n), '(',num2str(m), ')');
            np = np +1;
            hold off
        end
    end
    t_string1 = ['S(',num2str(s_in),',',num2str(n),')'];

legend(leg, 'Location', 'EastOutside')
ylim([-40 0])
xlim([0 25])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title(['S parameters ', t_string1])
savemfmt(pth,['s_parameters_S',num2str(s_in),num2str(n)])
close(gcf)