function plot_s_parameter_transmission_graphs_port(pp_data, cols, lines, fig_pos, pth, lower_cutoff, linewidth)

sets = (unique(pp_data.set));

h = figure('Position',fig_pos);

for nsz = 1:length(sets) % s_parameter set
    ports_for_set_ind = find(strcmp(pp_data.set, sets{nsz}));
    for es=1:length(ports_for_set_ind) % Excitation port
        s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{ports_for_set_ind(es)}));
        
        ax = axes('Parent', h);
        ck = 1;
        leg='';
        for n=1:size(pp_data.data,2) % Receiving port
            if ~isempty(pp_data.data{ports_for_set_ind(es),n})
                if max(20* log10(pp_data.data{ports_for_set_ind(es),n}(1,1:end-2))) > lower_cutoff
                    if s_in ~= n
                        if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                            plot(pp_data.scale{ports_for_set_ind(es),n}(1,1:end-2) * 1e-9, 20* log10(pp_data.data{ports_for_set_ind(es),n}(1,1:end-2)),...
                                'Linestyle',lines{rem(n,length(lines))+1},...
                                'Color', cols{rem(es,length(cols))+1},...
                                'LineWidth',  linewidth, 'Parent', ax);
                            leg{ck} = strcat('S',num2str(n), num2str(s_in), '(1)');
                            ck = ck+1;
                            hold all;
                        end %if
                    end %if
                end %if
            end %if
        end %for
        legend(ax, leg, 'Location', 'EastOutside')
        ylim([lower_cutoff 0])
        xlabel('Frequency (GHz)')
        ylabel('S parameters (dB)')
        title(['Port ',num2str(s_in),' excitation'])
        %     xlim(ppi.display_range)
        savemfmt(h, fullfile(pth, ['set_', sets{nsz}]),['s_parameters_transmission_excitation_port_',num2str(s_in)])
        clf(h)
    end %for
end %for
close(h)