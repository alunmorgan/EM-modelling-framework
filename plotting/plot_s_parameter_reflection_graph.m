function plot_s_parameter_reflection_graph(pp_data, cols, lines, fig_pos, pth, lower_cutoff, linewidth,trim_fraction)

mode = 1;
h = figure('Position',fig_pos);
sets = unique(pp_data.set);
min_y = 0;
for law = 1:length(sets)
    set_filter = strcmp(pp_data.set,sets{law});
    temp_data = pp_data.data(set_filter,:);
    temp_scale = pp_data.scale(set_filter,:);
    temp_excitation_port_list = pp_data.port_list(set_filter);
    for es=1:size(temp_data,1) %excitation port
        s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports, temp_excitation_port_list{es}));
            if ~isempty(temp_data{es,s_in})
                if max(20* log10(temp_data{es,s_in}(1,1:end-2))) > lower_cutoff
                    x_data = temp_scale{es,s_in}(mode, 1:end-2) * 1e-9;
                    y_data = 20* log10(temp_data{es,s_in}(mode, 1:end-2));
                    [start_ind,final_ind] = get_trim_inds(x_data,trim_fraction);
                    if min(y_data) < min_y
                        min_y = min(y_data);
                    end %if
                        hl = plot(x_data(start_ind:final_ind), y_data(start_ind:final_ind),...
                            'Linestyle',lines{rem(s_in,length(lines))+1},...
                            'Color', cols{rem(es,length(cols))+1},...
                            'LineWidth',  linewidth,...
                            'DisplayName', strcat('S',num2str(s_in), num2str(s_in), '(1)'));
                        if law > 1
                            set(get(get(hl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        end %if
                        hold all;
                end %if
            end %if
    end %for
end %for

legend('Location', 'EastOutside')
ylim([min_y 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('Reflection')
savemfmt(h, pth,'s_parameters_reflection_mode_1')
close(h)