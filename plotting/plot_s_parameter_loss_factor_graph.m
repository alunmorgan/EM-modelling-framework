function plot_s_parameter_loss_factor_graph(data, cols, lines, fig_pos, ...
    pth, prefix, linewidth)

h = figure('Position',fig_pos);
for nre = 1:length(data.port.names) % excitation ports
        x_data = data.port.scales{nre} * 1e-9;
        y_data = data.port.loss_factor{nre};
        hl = plot(x_data, y_data,...
            'Linestyle',lines{rem(nre,length(lines))+1},...
            'Color', cols{rem(nre,length(cols))+1},...
            'LineWidth',  linewidth,...
            'DisplayName', regexprep(data.port.names{nre}, '_', ' '));
        hold all;
        %     end %if
end %if
grid on 
legend('Location', 'NorthOutside', 'NumColumns', 2)
xlabel('Frequency (GHz)')
ylabel('Loss')
title('Loss_factor')
savemfmt(h, pth,[prefix, '_s_parameters_loss_factor'])
close(h)