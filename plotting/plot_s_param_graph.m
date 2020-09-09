function plot_s_param_graph(s, cols_sep, fig_pos, pth, lower_cutoff, linewidth)
% plots the s parameter results.
%
% Example: plot_s_param_graph(s, cols_sep, fig_pos, pth)

sets = (unique(s.set));
h(1) = figure('Position',fig_pos);
for nsz = 1:length(sets) % s_parameter set
    mkdir(pth, ['set_', sets{nsz}])
    ports_for_set_ind = find(strcmp(s.set, sets{nsz}));
    for nre = 1:length(ports_for_set_ind) % excitation ports
        s_in  = find_position_in_cell_lst(strfind(s.all_ports,s.port_list{ports_for_set_ind(nre)}));
        for es = 1:length(s.all_ports) % receiving ports
            np = 1;
            hold on
            tmp_data = s.data{nre,es};
            for m=1:size(tmp_data,1) % Iterate over modes
                if max(20* log10(tmp_data(m,1:end-2))) > lower_cutoff
                    plot(s.scale{nre, es}(m,1:end-2) * 1e-9, 20* log10(tmp_data(m,1:end-2)), '-',...
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
            savemfmt(h(1), fullfile(pth, ['set_', sets{nsz}]),['s_parameters_S',num2str(s_in),num2str(es)])
            clf(h(1))
        end %for
    end %for
end %for
    close(h(1))