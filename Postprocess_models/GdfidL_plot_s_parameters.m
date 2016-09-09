function GdfidL_plot_s_parameters(s, ppi, fig_pos, pth)
% plots the s parameter results.
%
% Example: GdfidL_plot_s_parameters(s, fig_pos, pth)

lines = {'--',':','-.','-'};
cols_sep = {'y','k','r','b','g','c','m'};

for es=1:size(s.data,1);
    for n=1:size(s.data,2);
        if n ~= 1 && n ~=2 % dont do the beam ports
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
            xlim(ppi.display_range)
            savemfmt(pth,['s_parameters_S',num2str(s_in),num2str(n)])
            close(gcf)
        end
    end
end

cols = {'y','k','r','b','c','m'};

figure('Position',fig_pos)
figure_setup_bounding_box
ck = 1;
leg='';

for es=1:size(s.data,1);
    for n=1:size(s.data,2);
        s_in  = find_position_in_cell_lst(strfind(s.all_ports,s.port_list{es}));
        if ~isempty(s.data{es,n})
            if max(20* log10(s.data{es,n}(1,1:end-2))) > -40
                if s_in ~= n
                    if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                        plot(s.scale(1:end-2) * 1e-9, 20* log10(s.data{es,n}(1,1:end-2)),...
                            'Linestyle',lines{rem(es,length(lines))+1},...
                            'Color', cols{rem(n,length(cols))+1},...
                            'LineWidth',  1);
                        leg{ck} = strcat('S',num2str(s_in), num2str(n), '(1)');
                        ck = ck+1;
                        hold all;
                    end
                end
            end
        end
    end
end

legend(leg, 'Location', 'EastOutside')
ylim([-40 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('S parameters')
xlim(ppi.display_range)
savemfmt(pth,'s_parameters_transmission_mode_1')
close(gcf)



for es=1:size(s.data,1);
    s_in  = find_position_in_cell_lst(strfind(s.all_ports,s.port_list{es}));
    
    figure('Position',fig_pos)
    figure_setup_bounding_box
    ck = 1;
    leg='';
    for n=1:size(s.data,2);
        if ~isempty(s.data{es,n})
            if max(20* log10(s.data{es,n}(1,1:end-2))) > -40
                if s_in ~= n
                    if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                        plot(s.scale(1:end-2) * 1e-9, 20* log10(s.data{es,n}(1,1:end-2)),...
                            'Linestyle',lines{rem(es,length(lines))+1},...
                            'Color', cols{rem(n,length(cols))+1},...
                            'LineWidth',  1);
                        leg{ck} = strcat('S',num2str(s_in), num2str(n), '(1)');
                        ck = ck+1;
                        hold all;
                    end
                end
            end
        end
    end
    legend(leg, 'Location', 'EastOutside')
    ylim([-40 0])
    xlabel('Frequency (GHz)')
    ylabel('S parameters (dB)')
    title(['S parameters (port ',num2str(s_in),' excitation)'])
    xlim(ppi.display_range)
    savemfmt(pth,['s_parameters_transmission_excitation_port_',num2str(s_in)])
    close(gcf)
end


figure('Position',fig_pos)
figure_setup_bounding_box
ck = 1;
leg='';

for es=1:size(s.data,1);
    s_in  = find_position_in_cell_lst(strfind(s.all_ports,s.port_list{es}));
    for n=1:size(s.data,2);
        if ~isempty(s.data{es,n})
            if max(20* log10(s.data{es,n}(1,1:end-2))) > -40
                if s_in == n
                    plot(s.scale(1:end-2) * 1e-9, 20* log10(s.data{es,n}(1,1:end-2)),...
                        'Linestyle',lines{rem(es,length(lines))+1},...
                        'Color', cols{rem(n,length(cols))+1},...
                        'LineWidth',  1);
                    leg{ck} = strcat('S',num2str(s_in), num2str(n), '(1)');
                    ck = ck+1;
                    hold all;
                end
            end
        end
    end
end

legend(leg, 'Location', 'EastOutside')
ylim([-40 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('S parameters')
xlim(ppi.display_range)
savemfmt(pth,'s_parameters_reflection_mode_1')
close(gcf)