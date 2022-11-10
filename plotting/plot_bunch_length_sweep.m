function plot_bunch_length_sweep(bunch_length_sweep_data, prefix_bls, fig_pos, graph_freq_lim, lw, output_folder)

h_wake = figure('Position',fig_pos);

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(bunch_length_sweep_data.freq.Bunch_loss_energy_spectrum)
    plot(bunch_length_sweep_data.freq.f_raw{jse}*1E-9, bunch_length_sweep_data.freq.Bunch_loss_energy_spectrum{jse}, 'LineWidth',lw,...
        'Parent', ax, 'DisplayName', ...
        ['Bunchlength = ', num2str(round(bunch_length_sweep_data.sig_time(jse)*3e8*1e3)), 'mm']);
end %for
title('Bunch loss energy spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_bls, 'Bunch_loss_energy_spectrum'])

close(h_wake)