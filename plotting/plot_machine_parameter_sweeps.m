function plot_machine_parameter_sweeps(bunch_charge_sweep_data, ppi, prefix, fig_pos, graph_freq_lim, lw, output_folder)



% bunch current, RF voltage, train lenth / fill pattern
% ppi.bt_length
% ppi.current
% ppi.rf_volts

% for now assume a single value of current
f_names1 = fieldnames(bunch_charge_sweep_data);
filtered = {'time', 'freq'};
f_names1 = setdiff(f_names1, filtered);
f_names2 = fieldnames(bunch_charge_sweep_data.time);
f_names3 = fieldnames(bunch_charge_sweep_data.freq);
for jer = 1:length(f_names1)
    single_current_data.(f_names1{jer}) = squeeze(bunch_charge_sweep_data.(f_names1{jer})(1,:, :));
end %for
for jer = 1:length(f_names2)
    single_current_data.time.(f_names2{jer}) = squeeze(bunch_charge_sweep_data.time.(f_names2{jer})(1,:, :));
end %for
for jer = 1:length(f_names3)
    single_current_data.freq.(f_names3{jer}) = squeeze(bunch_charge_sweep_data.freq.(f_names3{jer})(1,:, :));
end %for

% fill pattern at a single RF voltage
for jer = 1:length(f_names1)
    single_curent_single_RF_data.(f_names1{jer}) = squeeze(single_current_data.(f_names1{jer})(:, 2));
end %for
for jer = 1:length(f_names2)
    single_curent_single_RF_data.time.(f_names2{jer}) = squeeze(single_current_data.time.(f_names2{jer})(:, 2));
end %for
for jer = 1:length(f_names3)
    single_curent_single_RF_data.freq.(f_names3{jer}) = squeeze(single_current_data.freq.(f_names3{jer})(:, 2));
end %for

% fill pattern at a single fill pattern voltage
for jer = 1:length(f_names1)
    single_curent_single_fp_data.(f_names1{jer}) = squeeze(single_current_data.(f_names1{jer})(2, :));
end %for
for jer = 1:length(f_names2)
    single_curent_single_fp_data.time.(f_names2{jer}) = squeeze(single_current_data.time.(f_names2{jer})(2, :));
end %for
for jer = 1:length(f_names3)
    single_curent_single_fp_data.freq.(f_names3{jer}) = squeeze(single_current_data.freq.(f_names3{jer})(2, :));
end %for


prefix_fp = [prefix, '_fill_patterns_'];
prefix_rf = [prefix, '_RF_voltages_'];

plot_machine_parameter_sweeps_single_sweep(single_curent_single_RF_data, prefix_fp, ppi.bt_length, fig_pos, graph_freq_lim, lw, output_folder)
plot_machine_parameter_sweeps_single_sweep(single_curent_single_fp_data, prefix_rf, ppi.rf_volts, fig_pos, graph_freq_lim, lw, output_folder)

end %function

function plot_machine_parameter_sweeps_single_sweep(data, data_prefix, sweep_vals, fig_pos, graph_freq_lim, lw, output_folder)
h_wake = figure('Position',fig_pos);
clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(data.freq.bunch_spectra)
    plot(data.freq.f_raw{jse}*1E-9, abs(data.freq.bunch_spectra{jse}), '--', 'LineWidth',lw, 'Parent', ax, 'DisplayName',...
        ['Fill pattern = ', num2str(sweep_vals(jse))]);
end %for
title('Bunch spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [data_prefix, 'bunch_spectrum'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(data.freq.bunch_spectra)
    plot(data.freq.f_raw{jse}*1E-9, data.freq.Bunch_loss_energy_spectrum{jse}, '--', 'LineWidth',lw, 'Parent', ax, 'DisplayName',...
        ['Fill pattern = ', num2str(sweep_vals(jse))]);
end %for
title('Bunch loss energy spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [data_prefix, 'bunch_loss_energy_spectrum'])

clf(h_wake)
port_names = data.time.port_lables{1};
[hwn, ksn] = num_subplots(length(port_names));
for ens = length(port_names):-1:1 % ports
    ax_sp(ens) = subplot(hwn,ksn,ens);
    for jse = 1:length(data.freq.f_raw)
        try
            hold on
            % This is to cope with the case of missing data files.
            plot(data.freq.f_raw{jse}*1E-9, abs(squeeze(data.freq.port_spectra{jse}(ens,:))),...
                'LineWidth',lw, 'Parent', ax_sp(ens), 'DisplayName',...
        ['Fill pattern = ', num2str(sweep_vals(jse))])
            catch
            fprinf(['\nMissing data file for ', port_names{ens}])
        end %try
    end %for
    title(port_names{ens}, 'Parent', ax_sp(ens))
    xlim([0 graph_freq_lim])
    ylim([0 inf])
    xlabel('Frequency (GHz)', 'Parent', ax_sp(ens))
    ylabel('', 'Parent', ax_sp(ens))
    grid on
    legend
end %for
savemfmt(h_wake, output_folder, [data_prefix, 'port_spectra'])

close(h_wake)
end %function