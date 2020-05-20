function plot_s_param_transmission_graphs_modes(pp_data, cols, lines, fig_pos, pth, lower_cutoff, linewidth)
h = figure('Position',fig_pos);
ax = axes('Parent', h);
ck = 1;

% Just looking at mode 1.
for es=1:size(pp_data.data,1) % Excition ports
    s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{es}));
    for n=1:size(pp_data.data,2) % Receiving ports
          if ~isempty(pp_data.data{es,n})
            if max(20* log10(pp_data.data{es,n}(1,1:end-2))) > lower_cutoff
                if s_in ~= n
                    if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                        plot(pp_data.scale(1:end-2) * 1e-9, 20* log10(pp_data.data{es,n}(1,1:end-2)),...
                            'Linestyle',lines{rem(n,length(lines))+1},...
                            'Color', cols{rem(es,length(cols))+1},...
                            'LineWidth',  linewidth, 'Parent', ax,...
                            'DisplayName', strcat('S',num2str(n), num2str(s_in), '(1)'));
                        ck = ck+1;
                        hold all;
                    end %if
                end %if
            end %if
        end %if
    end %for
end %for

legend(ax, 'Location', 'EastOutside')
ylim([lower_cutoff 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('Transmission')
% xlim(ppi.display_range)
savemfmt(h, pth,'s_parameters_transmission_mode_1')
close(h)
