function plot_s_param_transmission_graphs_modes(pp_data, beam_present, cols, lines, fig_pos, pth, lower_cutoff, linewidth, trim_fraction)


h = figure('Position',fig_pos);
ax = axes('Parent', h);

% Just looking at mode 1.
mode=1;
sets = unique(pp_data.set);
min_y = 0;
for law = 1:length(sets)
    set_filter = strcmp(pp_data.set,sets{law});
    temp_data = pp_data.data(set_filter,:);
    temp_scale = pp_data.scale(set_filter,:);
    temp_excitation_port_list = pp_data.port_list(set_filter);
    for es=1:size(temp_data,1) % Excition ports
        s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports, temp_excitation_port_list{es}));
        for n=1:size(temp_data,2) % Receiving ports
            if ~isempty(pp_data.data{es,n})
                if max(20* log10(pp_data.data{es,n}(1,1:end-2))) > lower_cutoff
                    if s_in ~= n
                        if strcmp(beam_present, 'yes') && n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                            min_y = add_data_to_transmission_modes_graph(ax, temp_scale, temp_data, mode, min_y, lines, cols, linewidth, es, n, s_in, law, trim_fraction);
                        elseif strcmp(beam_present, 'no')
                            min_y = add_data_to_transmission_modes_graph(ax, temp_scale, temp_data, mode, min_y, lines, cols, linewidth, es, n, s_in, law, trim_fraction);
                        end %if
                    end %if
                end %if
            end %if
        end %for
    end %for
end %for

legend(ax, 'Location', 'EastOutside')
set(legend, 'NumColumns', 2)
if min_y == 0
    min_y = -1;
end %if
ylim([min_y 0])
xlabel('Frequency (GHz)')
ylabel('S parameters (dB)')
title('Transmission')
savemfmt(h, pth,'s_parameters_transmission_mode_1')
close(h)
end %function

function min_y = add_data_to_transmission_modes_graph(ax, temp_scale, temp_data, mode, min_y, lines, cols, linewidth, es, n, s_in, law, trim_fraction)
% Trim fraction controls how much data is trimmed from teh ends. This is often required as it contains artifacts.
hold on
x_data = temp_scale{es,n}(mode,1:end-2) * 1e-9;
y_data = 20* log10(temp_data{es,n}(mode, 1:end-2));
[start_ind,final_ind] = get_trim_inds(x_data,trim_fraction);
if min(y_data) < min_y
    min_y = min(y_data);
end %if
hl = plot(x_data(start_ind:final_ind), y_data(start_ind:final_ind),...
    'Linestyle',lines{rem(n,length(lines))+1},...
    'Color', cols{rem(es,length(cols))+1},...
    'LineWidth',  linewidth, 'Parent', ax,...
    'DisplayName', strcat('S',num2str(n), num2str(s_in), '(1)'));
if law > 1
    set(get(get(hl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end %if
hold off
end %function
