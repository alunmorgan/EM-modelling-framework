function GdfidL_plot_s_parameters(path_to_data, fig_pos)
% plots the s parameter results.
%
% Example: GdfidL_plot_s_parameters(s, ppi, fig_pos, pth)

pth = fullfile(path_to_data, 's-parameter');
load(fullfile(pth, 'run_inputs.mat')); % contains modelling inputs
load(fullfile(pth,'data_postprocessed.mat')); % contains pp_data
load(fullfile(pth, 'pp_inputs.mat')); % contains ppi
load(fullfile(pth, 'data_from_run_logs.mat')) % contains run_logs

lines = {'--',':','-.','-'};
cols_sep = {'y','k','r','b','g','c','m'};

for es=1:size(pp_data.data,1)
    for n=1:size(pp_data.data,2)
        if n ~= 1 && n ~=2 % dont do the beam ports
            h(1) = figure('Position',fig_pos);
            ax(1) = axes('Parent', h(1));
            np = 1;
            leg = {};
            
            s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{es}));
            for m=size(pp_data.data{es,n},1):-1:1 % Iterate over modes
                if max(20* log10(pp_data.data{es,n}(m,1:end-2))) > -40
                    hold on
                    plot(pp_data.scale(1:end-2) * 1e-9, 20* log10(pp_data.data{es,n}(m,1:end-2)), '-',...
                        'Color', cols_sep{rem(m,7)+1}, 'Parent', ax(1))
                    leg{np} = strcat('S',num2str(s_in), num2str(n), '(',num2str(m), ')');
                    np = np +1;
                    hold off
                end
            end
            t_string1 = ['S(',num2str(s_in),',',num2str(n),')'];
            
            legend(ax(1), leg, 'Location', 'EastOutside')
            ylim([-40 0])
            xlim([0 25])
            xlabel('Frequency (GHz)')
            ylabel('S parameters (dB)')
            title(t_string1)
            xlim(ppi.display_range)
            savemfmt(h(1), pth,['s_parameters_S',num2str(s_in),'_',num2str(n)])
            close(h(1))
        end
    end
end

cols = {'y','k','r','b','c','m'};


if size(pp_data.all_ports,1) > 3
    % Only generate the transmission graphs if there is more than 1 signal port.
    h(2) = figure('Position',fig_pos);
    ax(2) = axes('Parent', h(2));
    ck = 1;
    leg='';
    
    for es=1:size(pp_data.data,1)
        for n=1:size(pp_data.data,2)
            s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{es}));
            if ~isempty(pp_data.data{es,n})
                if max(20* log10(pp_data.data{es,n}(1,1:end-2))) > -40
                    if s_in ~= n
                        if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                            plot(pp_data.scale(1:end-2) * 1e-9, 20* log10(pp_data.data{es,n}(1,1:end-2)),...
                                'Linestyle',lines{rem(es,length(lines))+1},...
                                'Color', cols{rem(n,length(cols))+1},...
                                'LineWidth',  1, 'Parent', ax(2));
                            leg{ck} = strcat('S',num2str(s_in), num2str(n), '(1)');
                            ck = ck+1;
                            hold all;
                        end %if
                    end %if
                end %if
            end %if
        end %for
    end %for
    
    legend(ax(2), leg, 'Location', 'EastOutside')
    ylim([-40 0])
    xlabel('Frequency (GHz)')
    ylabel('S parameters (dB)')
 %   title('S parameters')
    xlim(ppi.display_range)
    savemfmt(h(2), pth,'s_parameters_transmission_mode_1')
    close(h(2))
end %if

if size(pp_data.all_ports,1) > 3
    % Only generate the transmission graphs if there is more than 1 signal port.
    for es=1:size(pp_data.data,1)
        s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{es}));
        
        h(3) = figure('Position',fig_pos);
        ax(3) = axes('Parent', h(3));
        ck = 1;
        leg='';
        for n=1:size(pp_data.data,2)
            if ~isempty(pp_data.data{es,n})
                if max(20* log10(pp_data.data{es,n}(1,1:end-2))) > -40
                    if s_in ~= n
                        if n ~= 1 && n ~= 2 % dont show the beam pipe ports.
                            plot(pp_data.scale(1:end-2) * 1e-9, 20* log10(pp_data.data{es,n}(1,1:end-2)),...
                                'Linestyle',lines{rem(es,length(lines))+1},...
                                'Color', cols{rem(n,length(cols))+1},...
                                'LineWidth',  1, 'Parent', ax(3));
                            leg{ck} = strcat('S',num2str(s_in), num2str(n), '(1)');
                            ck = ck+1;
                            hold all;
                        end
                    end
                end
            end
        end
        legend(ax(3), leg, 'Location', 'EastOutside')
        ylim([-40 0])
        xlabel('Frequency (GHz)')
        ylabel('S parameters (dB)')
        title(['Port ',num2str(s_in),' excitation'])
        xlim(ppi.display_range)
        savemfmt(h(3), pth,['s_parameters_transmission_excitation_port_',num2str(s_in)])
        close(h(3))
    end %for
end %if


h(4) = figure('Position',fig_pos);
ck = 1;
leg='';

for es=1:size(pp_data.data,1)
    s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports,pp_data.port_list{es}));
    for n=1:size(pp_data.data,2)
        if ~isempty(pp_data.data{es,n})
            if max(20* log10(pp_data.data{es,n}(1,1:end-2))) > -40
                if s_in == n
                    plot(pp_data.scale(1:end-2) * 1e-9, 20* log10(pp_data.data{es,n}(1,1:end-2)),...
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
% title('S parameters')
xlim(ppi.display_range)
savemfmt(h(4), pth,'s_parameters_reflection_mode_1')
close(h(4))