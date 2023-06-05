function plot_wake_sweep(wake_sweep_data, prefix_wls, fig_pos, graph_freq_lim, lw, output_folder)

h_wake = figure('Position',fig_pos);

for hwa = 1:length(wake_sweep_data.frequency_domain_data)
    cut_freq_ind(hwa) = find(wake_sweep_data.frequency_domain_data{hwa}.f_raw*1E-9 < graph_freq_lim,1,'last'); %GHz
    f_raw{hwa} = wake_sweep_data.frequency_domain_data{hwa}.f_raw(1:cut_freq_ind(hwa),:)*1E-9;
    % Extracting wake impedances
    wi_re{hwa} = wake_sweep_data.frequency_domain_data{hwa}.Wake_Impedance_data(1:cut_freq_ind(hwa),:);
    wi_dipole_x{hwa} = wake_sweep_data.frequency_domain_data{hwa}.Wake_Impedance_trans_X(1:cut_freq_ind(hwa),:);
    wi_dipole_y{hwa} = wake_sweep_data.frequency_domain_data{hwa}.Wake_Impedance_trans_X(1:cut_freq_ind(hwa),:);
    wlf_t(hwa) = wake_sweep_data.frequency_domain_data{hwa}.wlf;
    %extracting the specra
    bunch_spectra{hwa} = wake_sweep_data.frequency_domain_data{hwa}.bunch_spectra(1:cut_freq_ind(hwa),:);
    Bunch_loss_energy_spectrum{hwa} = wake_sweep_data.frequency_domain_data{hwa}.Bunch_loss_energy_spectrum(1:cut_freq_ind(hwa),:);
    signal_port_spectrum{hwa} = wake_sweep_data.frequency_domain_data{hwa}.signal_port_spectrum(1:cut_freq_ind(hwa),:);
    beam_port_spectrum{hwa} = wake_sweep_data.frequency_domain_data{hwa}.beam_port_spectrum(1:cut_freq_ind(hwa),:);
    
    % Extracting time series
    timebase{hwa} = wake_sweep_data.time_domain_data{hwa}.timebase .* 1E9; % time in ns
    charge_distribution{hwa} = wake_sweep_data.time_domain_data{hwa}.charge_distribution;
    wp{hwa} = wake_sweep_data.time_domain_data{hwa}.wakepotential; % V/pC
    wpdx{hwa} = wake_sweep_data.time_domain_data{hwa}.wakepotential_trans_x; % V/pC
    wpdy{hwa} = wake_sweep_data.time_domain_data{hwa}.wakepotential_trans_y; % V/pC
    wlf_f(hwa) = wake_sweep_data.time_domain_data{hwa}.wake_loss_factor;
    wakelength(hwa) = timebase{hwa}(end)*1E-9*3E8; %m
    
    %Ports
    port_names{hwa} = regexprep(wake_sweep_data.time_domain_data{hwa}.port_lables, '_', ' ');
    port_signals{hwa} = squeeze(sum(wake_sweep_data.time_domain_data{hwa}.port_data.power_port_mode.full_signal.port_mode_signals, 2));
end %for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wake potential over time.
clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(wp):-1:1
    plot(timebase{jse}, wp{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))])
end %for
title('Evolution of longitudinal wake potential in the structure', 'Parent', ax)
xlabel('Time (ns)', 'Parent', ax)
xlim([timebase{end}(1) timebase{end}(end)])
ylabel('Wake potential (V/pC)', 'Parent', ax)
grid on
legend
savemfmt(h_wake, output_folder, [prefix_wls, 'wake_potential'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(wpdx):-1:1
    plot(timebase{jse}, wpdx{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))])
end %for
title('Evolution of dipole transverse wake potential in the structure (x)', 'Parent', ax)
xlabel('Time (ns)', 'Parent', ax)
xlim([timebase{end}(1) timebase{end}(end)])
ylabel('Wake potential (V/pC)', 'Parent', ax)
grid on
legend
savemfmt(h_wake, output_folder, [prefix_wls, 'transverse_dipole_x_wake_potential'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(wpdy):-1:1
    plot(timebase{jse}, wpdy{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))])
end %for
title('Evolution of dipole transverse wake potential in the structure (y)', 'Parent', ax)
xlabel('Time (ns)', 'Parent', ax)
xlim([timebase{end}(1) timebase{end}(end)])
ylabel('Wake potential (V/pC)', 'Parent', ax)
grid on
legend
savemfmt(h_wake, output_folder, [prefix_wls, 'transverse_dipole_y_wake_potential'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wake impedance.
clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(wi_re):-1:1
    plot(f_raw{jse}, wi_re{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wake loss factor = ',num2str(round(wlf_f(jse) .* 1E-9)),'mV/pC ','Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('Longditudinal real wake impedance', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('Impedance (\Omega)', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'longditudinal_real_wake_impedance'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(wi_dipole_x):-1:1
    plot(f_raw{jse}, wi_dipole_x{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wake loss factor = ','mV/pC ', 'Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('Transverse (x) real wake impedance', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('Impedance (\Omega)', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'transverse_x_real_wake_impedance'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(wi_dipole_y):-1:1
    plot(f_raw{jse}, wi_dipole_y{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wake loss factor = ','mV/pC ', 'Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('Transverse (y) real wake impedance', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('Impedance (\Omega)', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'transverse_y_real_wake_impedance'])

% Spectra
clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(bunch_spectra):-1:1
    plot(f_raw{jse}, abs(bunch_spectra{jse}), 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('Bunch spectra', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'bunch_spectra'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(Bunch_loss_energy_spectrum):-1:1
    plot(f_raw{jse}, Bunch_loss_energy_spectrum{jse}, 'LineWidth',lw, 'Parent', ax,...
        'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('Bunch loss energy spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'Bunch_loss_energy_spectrum'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(signal_port_spectrum):-1:1
    plot(f_raw{jse}, abs(signal_port_spectrum{jse}), '--', 'LineWidth',lw, 'Parent', ax, 'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('signal port spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'signal_port_spectrum'])


clf(h_wake)
ax = axes('Parent', h_wake);
hold on
for jse = length(beam_port_spectrum):-1:1
    plot(f_raw{jse}, abs(beam_port_spectrum{jse}), '--', 'LineWidth',lw, 'Parent', ax, 'DisplayName', ['Wakelength = ', num2str(round(wakelength(jse)))]);
end %for
title('beam port spectrum', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend
grid on
savemfmt(h_wake, output_folder, [prefix_wls, 'beam_port_spectrum'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Port signals
clf(h_wake)
[hwn, ksn] = num_subplots(length(port_names{1}));
for ens = length(port_names{1}):-1:1 % ports
    ax_sp(ens) = subplot(hwn,ksn,ens);
    for jse = length(timebase):-1:1
        try
            hold on
            % This is to cope with the case of missing data files.
            plot(timebase{jse}, port_signals{jse}(ens, :),...
               '--', 'LineWidth',lw, 'Parent', ax_sp(ens))
        catch
            fprintf(['\nMissing data file for ', port_names{jse}{ens}])
        end %try
        title(port_names{jse}{ens}, 'Parent', ax_sp(ens))
        xlim([timebase{end}(1) timebase{end}(end)])
        xlabel('Time (ns)', 'Parent', ax_sp(ens))
        ylabel('Power (W)', 'Parent', ax_sp(ens))
        grid on
    end %for
end %for
savemfmt(h_wake, output_folder, [prefix_wls, 'port_signals'])
close(h_wake)