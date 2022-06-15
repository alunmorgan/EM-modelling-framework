function plot_s_param_graph(pp_data, beam_present, cols_sep, fig_pos, pth, lower_cutoff, linewidth)
% plots the s parameter results.
%
% Example: plot_s_param_graph(s, cols_sep, fig_pos, pth)

min_y = zeros(length(pp_data.excitation_list));
excitations = unique(pp_data.excitation_list);
recievers = unique(pp_data.reciever_list);
for nre = 1:length(excitations) % excitation ports
    excitation_inds = find_position_in_cell_lst(strfind(pp_data.excitation_list, excitations{nre}));
    if strcmp(beam_present, 'yes')
        exitation_port_number = nre + 2;
    else
        exitation_port_number = nre;
    end %if
    for es = 1:length(excitation_inds) % receiving ports
        receiver_inds = find(strcmp(recievers, pp_data.reciever_list{excitation_inds(es)}));
        
        h = figure('Position',fig_pos);
        np = 1;
        hold on
        for m=1:size(pp_data.scale{excitation_inds(es)},1) % Iterate over modes
            x_data = pp_data.scale{excitation_inds(es)}(m, :) * 1e-9;
            y_data = 20* log10(pp_data.data{excitation_inds(es)}(m, :));
            if max(y_data) > lower_cutoff
                if min(y_data) < min_y(nre, es)
                    min_y(nre, es) = min(y_data);
                end %if
                plot(x_data, y_data, '-',...
                    'Color', cols_sep{rem(m,length(cols_sep))+1}, ...
                    'Linewidth', linewidth,...
                    'DisplayName',strcat('S',num2str(exitation_port_number), num2str(receiver_inds), '(',num2str(m), ')'));
                np = np +1;
            end %if
        end %for
        if np == 1
            continue
        end %if
        hold off
        t_string1 = ['S(',num2str(exitation_port_number),',',num2str(receiver_inds),')'];
        legend('Location', 'EastOutside')
        ylim([min_y(nre, es) 0])
        xlabel('Frequency (GHz)')
        ylabel('S parameters (dB)')
        title(['S parameters ', t_string1])
        savemfmt(h, pth,[pp_data.set,'_s_parameters_S',num2str(exitation_port_number),num2str(receiver_inds)])
        close(h)
    end %for
end %for