function plot_s_parameter_transmission_graphs_port(pp_data, cols, lines, fig_pos, pth, lower_cutoff, linewidth)

mode=1;
sets = unique(pp_data.set);
min_y = zeros(length(pp_data.all_ports),1);
for law = 1:length(sets)
    set_filter = strcmp(pp_data.set,sets{law});
    temp_data = pp_data.data(set_filter,:);
    temp_scale = pp_data.scale(set_filter,:);
    temp_excitation_port_list = pp_data.port_list(set_filter);
    for es=1:size(temp_data,1) % Excitation port
        s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports, temp_excitation_port_list{es}));
        if law == 1
            h(s_in) = figure('Position',fig_pos);
        end %if
        figure(h(s_in))
        for n=1:size(temp_data,2) % Receiving port
            if ~isempty(temp_data{es,n})
                if max(20* log10(temp_data{es,n}(1,1:end-2))) > lower_cutoff
                    if s_in ~= n
                        if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                            x_data = temp_scale{es,n}(mode,1:end-2) * 1e-9;
                            y_data = 20* log10(temp_data{es,n}(mode,1:end-2));
                            % Trimming off the end 10% as this often contains artifacts.
                            start_ind = ceil(length(x_data)/10);
                            final_ind = floor(length(x_data) - length(x_data) /10);
                            if min(y_data) < min_y(s_in)
                                min_y(s_in) = min(y_data);
                            end %if
                            hl = plot(x_data(start_ind:final_ind), y_data(start_ind:final_ind),...
                                'Linestyle',lines{rem(n,length(lines))+1},...
                                'Color', cols{rem(s_in,length(cols))+1},...
                                'LineWidth',  linewidth,...
                                'DisplayName', strcat('S',num2str(n), num2str(s_in), '(1)'));
                            if law > 1
                                set(get(get(hl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                            end %if
                            hold all;
                        end %if
                    end %if
                end %if
            end %if
        end %for
    end %for
end %for
for ke = 1:length(pp_data.all_ports)
    if ishandle(h(ke))
        figure(h(ke))
        legend('Location', 'EastOutside')
        if min_y(ke) == 0
            min_y(ke) = -1;
        end %if
        ylim([min_y(ke) 0])
        xlabel('Frequency (GHz)')
        ylabel('S parameters (dB)')
        title(['Port ',num2str(ke),' excitation'])
        savemfmt(h(ke), pth,['s_parameters_transmission_excitation_port_',num2str(ke)])
        close(h(ke))
    end %if
end %for
