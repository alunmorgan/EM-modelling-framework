function plot_s_parameter_reflection_graph(pp_data, cols, lines, fig_pos, pth, lower_cutoff, linewidth)

sets = (unique(pp_data.set));
h = figure('Position',fig_pos);

for nsz = 1:length(sets) % s_parameter set
    ck = 1;
    % Just looking at mode 1.
        ports_for_set_ind = find(strcmp(pp_data.set, sets{nsz}));
for es=1:length(ports_for_set_ind) %excitation port
    s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{ports_for_set_ind(es)}));
    for n=1:length(pp_data.all_ports)  % Receiving port
        if ~isempty(pp_data.data{ports_for_set_ind(es),n})
            if max(20* log10(pp_data.data{ports_for_set_ind(es),n}(1,1:end-2))) > lower_cutoff
                if s_in == n
                    plot(pp_data.scale{ports_for_set_ind(es),n}(1,1:end-2) * 1e-9, 20* log10(pp_data.data{ports_for_set_ind(es),n}(1,1:end-2)),...
                        'Linestyle',lines{rem(n,length(lines))+1},...
                        'Color', cols{rem(es,length(cols))+1},...
                        'LineWidth',  linewidth,...
                        'DisplayName', strcat('S',num2str(n), num2str(s_in), '(1)'));
                    ck = ck+1;
                    hold all;
                end %if
            end %if
        end %if
    end %for
end %for

legend('Location', 'EastOutside')
ylim([lower_cutoff 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('Reflection')
% xlim(ppi.display_range)
savemfmt(h, fullfile(pth, ['set_', sets{nsz}]),'s_parameters_reflection_mode_1')
    clf(h)
end %for
close(h)