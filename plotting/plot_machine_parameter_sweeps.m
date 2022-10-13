function plot_machine_parameter_sweeps(bunch_charge_sweep_data, ppi, prefix, fig_pos, graph_freq_lim, lw, output_folder)

h_wake = figure('Position',fig_pos);

% bunch current, RF voltage, train lenth / fill pattern
ppi.bt_length
ppi.current
ppi.rf_volts

port_names = regexprep(bunch_charge_sweep_data.port_labels{1,1,1}, '_', ' ');

% for now assume a single value of current
wlf = squeeze(bunch_charge_sweep_data.wlf(1,:, :));
power_loss = squeeze(bunch_charge_sweep_data.power_loss(1,:, :));
bunch_charge = squeeze(bunch_charge_sweep_data.bunch_charge(1,:, :));
bunch_length = squeeze(bunch_charge_sweep_data.bunch_length(1,:, :));
loss_beam_pipe = squeeze(bunch_charge_sweep_data.loss_beam_pipe(1,:, :));
loss_signal_ports = squeeze(bunch_charge_sweep_data.loss_signal_ports(1,:, :));
loss_structure = squeeze(bunch_charge_sweep_data.loss_structure(1,:, :));

% fill pattern at a single RF voltage
bunch_spec = squeeze(bunch_charge_sweep_data.bunch_spec(1,:, 2));
port_energy_loss = squeeze(bunch_charge_sweep_data.port_energy_loss(1,:, 2, :, :));
port_loss_energy_spectrum = squeeze(bunch_charge_sweep_data.port_loss_energy_spectrum(1,:, 2,: ,:));
f_scale = squeeze(bunch_charge_sweep_data.f_scale(1,:, 2, :)) .* 1e-9;
Bunch_loss_energy_spectrum = squeeze(bunch_charge_sweep_data.Bunch_loss_energy_spectrum(1,:, 2,:));

prefix_fp = [prefix, '_fill_patterns_'];

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(bunch_spec)
    plot(f_scale(jse,:), bunch_spec{jse}, 'LineWidth',lw, 'Parent', ax, 'DisplayName', ['Fill pattern = ', num2str(ppi.bt_length(jse))]);
end %for
title('Bunch spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_fp, 'bunch_spectrum'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(bunch_spec)
    plot(f_scale(jse,:), Bunch_loss_energy_spectrum(jse,:), 'LineWidth',lw, 'Parent', ax, 'DisplayName', ['Fill pattern = ', num2str(ppi.bt_length(jse))]);
end %for
title('Bunch loss energy spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_fp, 'bunch_loss_energy_spectrum'])

clf(h_wake)
[hwn, ksn] = num_subplots(length(port_names));
for ens = length(port_names):-1:1 % ports
    ax_sp(ens) = subplot(hwn,ksn,ens);
    for jse = 1:size(f_scale, 1)
        try
            hold on
            % This is to cope with the case of missing data files.
            plot(f_scale(jse,:), squeeze(port_loss_energy_spectrum(jse,:,ens)),...
                'LineWidth',lw, 'Parent', ax_sp(ens))
        end %try
    end %for
    title(port_names{ens}, 'Parent', ax_sp(ens))
    xlim([0 graph_freq_lim])
    ylim([0 inf])
    xlabel('Frequency (GHz)', 'Parent', ax_sp(ens))
    ylabel('', 'Parent', ax_sp(ens))
    grid on
end %for
savemfmt(h_wake, output_folder, [prefix_fp, 'port_loss_energy_spectrum'])

prefix_rf = [prefix, '_fill_patterns_'];
% for now assume a single value of current
% fill pattern at a single fill pattern voltage
bunch_spec = squeeze(bunch_charge_sweep_data.bunch_spec(1,2, :));
port_energy_loss = squeeze(bunch_charge_sweep_data.port_energy_loss(1,2, :, :, :));
port_loss_energy_spectrum = squeeze(bunch_charge_sweep_data.port_loss_energy_spectrum(1,2, :,: ,:));
f_scale = squeeze(bunch_charge_sweep_data.f_scale(1,2, :, :)) .* 1e-9;
Bunch_loss_energy_spectrum = squeeze(bunch_charge_sweep_data.Bunch_loss_energy_spectrum(1,2, :,:));

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(bunch_spec)
    plot(f_scale(jse,:), bunch_spec{jse}, 'LineWidth',lw, 'Parent', ax, 'DisplayName', ['RF voltage = ', num2str(ppi.rf_volts(jse))]);
end %for
title('Bunch spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_rf, 'bunch_spectrum'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = 1:length(bunch_spec)
    plot(f_scale(jse,:), Bunch_loss_energy_spectrum(jse,:), 'LineWidth',lw, 'Parent', ax, 'DisplayName', ['RF voltage = ', num2str(ppi.rf_volts(jse))]);
end %for
title('Bunch loss energy spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_rf, 'bunch_loss_energy_spectrum'])

clf(h_wake)
[hwn, ksn] = num_subplots(length(port_names));
for ens = length(port_names):-1:1 % ports
    ax_sp(ens) = subplot(hwn,ksn,ens);
    for jse = 1:size(f_scale, 1)
        try
            hold on
            % This is to cope with the case of missing data files.
            plot(f_scale(jse,:), squeeze(port_loss_energy_spectrum(jse,:,ens)),...
                'LineWidth',lw, 'Parent', ax_sp(ens))
        end %try
    end %for
    title(port_names{ens}, 'Parent', ax_sp(ens))
    xlim([0 graph_freq_lim])
    ylim([0 inf])
    xlabel('Frequency (GHz)', 'Parent', ax_sp(ens))
    ylabel('', 'Parent', ax_sp(ens))
    grid on
end %for
savemfmt(h_wake, output_folder, [prefix_rf, 'port_loss_energy_spectrum'])
close(h_wake)