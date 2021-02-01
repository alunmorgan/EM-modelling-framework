function plot_s_param_graph(pp_data, beam_present, cols_sep, fig_pos, pth, lower_cutoff, linewidth)
% plots the s parameter results.
%
% Example: plot_s_param_graph(s, cols_sep, fig_pos, pth)

sets = unique(pp_data.set);
min_y = zeros(length(pp_data.all_ports));
for law = 1:length(sets)
    set_filter = strcmp(pp_data.set,sets{law});
    temp_data = pp_data.data(set_filter,:);
    temp_scale = pp_data.scale(set_filter,:);
    temp_excitation_port_list = pp_data.port_list(set_filter);
    for nre = 1:size(temp_data,1) % excitation ports
        s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports, temp_excitation_port_list{nre}));
        for es = 1:size(temp_data,2) % receiving ports
            if law == 1
                h(s_in, es) = figure('Position',fig_pos);
            end %if
            figure(h(s_in, es))
            np = 1;
            hold on
            tmp_data = temp_data{nre,es};
            for m=1:size(tmp_data,1) % Iterate over modes
                x_data = temp_scale{nre, es}(m,1:end-2) * 1e-9;
                y_data = 20* log10(tmp_data(m, 1:end-2));
                % Trimming off the end 10% as this often contains artifacts.
%                 start_ind = ceil(length(x_data)/10);
%                 final_ind = floor(length(x_data) - length(x_data) /10);
%                 x_data = x_data(start_ind:final_ind);
%                 y_data = y_data(start_ind:final_ind);
                if max(y_data) > lower_cutoff
                    if min(y_data) < min_y(s_in, es)
                        min_y(s_in, es) = min(y_data);
                    end %if
                    hl = plot(x_data, y_data, '-',...
                        'Color', cols_sep{rem(m,length(cols_sep))+1}, ...
                        'Linewidth', linewidth,...
                        'DisplayName',strcat('S',num2str(s_in), num2str(es), '(',num2str(m), ')'));
                    if law > 1
                        set(get(get(hl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                    end %if
                    np = np +1;
                end %if
            end %for
            if np == 1
%                 clf(h(s_in, es))
                continue
            end %if
            hold off
            t_string1 = ['S(',num2str(s_in),',',num2str(es),')'];
            legend('Location', 'EastOutside')
            ylim([min_y(s_in, es) 0])
            xlabel('Frequency (GHz)')
            ylabel('S parameters (dB)')
            title(['S parameters ', t_string1])
        end %for
    end %for
end %for
if strcmp(beam_present, 'no')
    start_port = 1;
else
    start_port = 3;
end %if
for fe = start_port:size(h,1)
    for js = 1:size(h,2)
            savemfmt(h(fe, js), pth,['s_parameters_S',num2str(fe),num2str(js)])
        close(h(fe, js))
    end %for
end%for
