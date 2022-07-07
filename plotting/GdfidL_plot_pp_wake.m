function GdfidL_plot_pp_wake(path_to_data, ppi)
% Generate the graphs based on the wake simulation data.
% Graphs are saved in fig format and png, eps.
%
% path_to_data is where the resulting files are saved to.
% range is to do with peak identification for Q values, and
% is the separation peaks have to have to be counted as separate.
%
% Example GdfidL_plot_wake(wake_data, ppi, mi, run_log,  pth, range)

% chosen_wake_length = str2double(chosen_wake_length);

[path_to_data ,~,~] = fileparts(path_to_data{1});
files_to_load = {'run_inputs.mat', 'modelling_inputs';...
    'data_analysed_wake.mat', 'pp_data';...
    'data_reconstructed_wake.mat', 'wake_sweep_data';...
    'data_from_run_logs.mat', 'run_logs'};

[temp, ~, ~] = fileparts(path_to_data);
[~, prefix, ~] = fileparts(temp);

for rnf = 1:size(files_to_load,1)
    if exist(fullfile(path_to_data, files_to_load{rnf,1}), 'file') == 2
        load(fullfile(path_to_data, files_to_load{rnf,1}), files_to_load{rnf,2});
    else
        disp(['Unable to load ', files_to_load{rnf,1}])
        return
    end %if
end %for
%Line width of the graphs
lw = 2;
% limit to the horizontal axis.
graph_freq_lim = ppi.hfod * 1e-9;
% location and size of the default figures.
fig_width = 800;
fig_height = 600;
fig_left = 10560 - fig_width;
fig_bottom = 1098 - fig_height;
fig_pos = [fig_left fig_bottom fig_width fig_height];

% Set the level vector to show the total energy loss on graphs (nJ).
% y_lev_t = [wake_data.time_domain_data.loss_from_beam *1e9,...
%     wake_data.time_domain_data.loss_from_beam * 1e9];
% y_lev_f = [wake_data.frequency_domain_data.Total_bunch_energy_loss *1e9,...
%     wake_data.frequency_domain_data.Total_bunch_energy_loss * 1e9];
%
% cut_off_freqs = wake_data.time_domain_data.port_data.voltage_port_mode.frequency_cutoffs;
% cut_off_freqs = cellfun(@(x) x*1e-9,cut_off_freqs, 'UniformOutput', false);

% setting up some style lists for the graphs.
% cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[1, 0, 0.5],[0.5, 0, 1],[0.5, 1, 0] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};

% Some pre processing to pull out trends.
% [wl, freqs, Qs, mags, bws] = find_Q_trends(wake_sweep_data.frequency_domain_data, range, run_logs.wake_length);
% Show the Q values of the resonances shows if the simulation has stablised.
% for ehw = size(freqs,1):-1:1
%     Q_leg{ehw} = [num2str(round(freqs(ehw,1)./1e7)./1e2), 'GHz'];
% end %for
% These are the plots to generate for a single value of sigma.
% sigma = round(str2num(mi.beam_sigma) ./3E8 *1E12 *10)/10;
% if isfield(pp_data.port, 'timebase')
% end %if

% Extracting  losses
[model_mat_data, mat_loss, m_time, m_data] = ...
    extract_material_losses_from_wake_data(pp_data, modelling_inputs.extension_names);

% [bunch_energy_loss, beam_port_energy_loss, signal_port_energy_loss, ...
%     ] = extract_energy_loss_data_from_wake_data(wake_data);

[structure_energy_loss, material_names] =  ...
    extract_energy_loss_data_from_pp_data(pp_data);

% total_port_energy_loss = signal_port_energy_loss + beam_port_energy_loss;
% pme = extract_port_energy_from_wake_data(wake_data);

% Extracting wake impedances
cut_freq_ind = find(pp_data.Wake_impedance.s.data(:,1)*1E-9 < graph_freq_lim,1,'last');
wi_re = pp_data.Wake_impedance.s.data(1:cut_freq_ind,:);
wi_re(:,1) = wi_re(:,1) .* 1E-9; % frequency in GHz
wi_dipole_x = pp_data.Wake_impedance.x.data(1:cut_freq_ind,:);
wi_dipole_x(:,1) = wi_dipole_x(:,1) .* 1E-9; % frequency in GHz
wi_dipole_y = pp_data.Wake_impedance.y.data(1:cut_freq_ind,:);
wi_dipole_y(:,1) = wi_dipole_y(:,1) .* 1E-9; % frequency in GHz

% wi_im = pp_data.Wake_impedance_Im.s.data(1:cut_freq_ind,:);
% wi_im(:,1) = wi_im(:,1) .* 1E-9; % frequency in GHz

% Extracting time series
wp = pp_data.Wake_potential.s.data; % V/pC
wp(:,1) = wp(:,1) .* 1E9; % time in ns
wpdx = pp_data.Wake_potential.x.data; % V/pC
wpdx(:,1) = wpdx(:,1) .* 1E9; % time in ns
wpdy = pp_data.Wake_potential.y.data; % V/pC
wpdy(:,1) = wpdy(:,1) .* 1E9; % time in ns


% e_ports_cs = cat(1,wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_energy_cumsum(1:2,:),...
%     wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_energy_cumsum(3:end,:))' .* 1e9; %nJ
% e_total_cs = sum(e_ports_cs,2); %nJ


% port_mode_energy = cat(1,wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_mode_energy(1:2,:),...
%     wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_mode_energy(3:end,:));
% port_mode_signals = cat(1,wake_data.time_domain_data.port_data.power_port_mode.remnant_only.port_mode_signals(1:2,:,:),...
%     wake_data.time_domain_data.port_data.power_port_mode.full_signal.port_mode_signals(3:end, :, :));
% [~, max_mode] = max(port_mode_energy,[],2);
% for ens = size(port_mode_signals, 1):-1:1 % ports
%     dominant_modes{ens} =  squeeze(port_mode_signals(ens,max_mode(ens), :));
%     for seo = 1:size(port_mode_signals, 2) % modes
%         modes{ens}{seo} =  squeeze(port_mode_signals(ens,seo, :));
%     end %for
% end %for


% Extracting spectra

% bs = extract_bunch_spectrum_from_wake_data(wake_data, cut_freq_ind);

[peaks, Q, bw] = find_Qs(wi_re(:,1) .* 1e9, wi_re(:,2), 0.1, 'single_sided');
R_over_Q = peaks(:,2) ./ Q;

% bls = extract_bunch_loss_spectrum_from_wake_data(wake_data, cut_freq_ind);

% pes = extract_port_energy_spectrum_from_wake_data(wake_data, cut_freq_ind);
%
% [beam_port_spectrum, ...
%     signal_port_spectrum, port_spectra] = ...
%     extract_port_spectra_from_wake_data(wake_data, cut_freq_ind);


h_wake = figure('Position',fig_pos);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal graphs
clf(h_wake)
if isfield(pp_data.port, 'timebase') && isfield(pp_data.port.data, 'time') && isfield(pp_data.port.data.time, 'power_port')
    time_step = pp_data.port.timebase(2) - pp_data.port.timebase(1);
    beam_ports = sum(pp_data.port.data.time.power_port.data{1}) .* time_step + ...
        sum(pp_data.port.data.time.power_port.data{2}) .* time_step;
    signal_ports = 0;
    for jas = 3:length(pp_data.port.data.time.power_port.data)
        signal_ports = signal_ports + sum(pp_data.port.data.time.power_port.data{jas}) .* time_step;
    end %for
else
    beam_ports = 0;
    signal_ports = 0;
end %if
plot_data = [beam_ports * 1E9, signal_ports * 1E9, structure_energy_loss];
% matlab will ignore any values of zero which messes up the maping of the
% lables. This just makes any zero values a very small  positive value to avoid
% this.
plot_data(plot_data == 0) = 1e-12;

if iscell(material_names)
    x = categorical(cellstr(['Beam ports', 'Signal ports',material_names]));
elseif isnan(material_names)
    x = categorical(cellstr(['Beam ports', 'Signal ports']));
end %if
subplot(2,2,1)
x1 = categorical({'Energy from beam'});
y1 = abs(pp_data.Wake_potential.s.loss.s) * 1e9;
b1 = bar(x1, y1);
subplot(2,2,2)
plot_data2 = [plot_data; plot_data];
b3 = bar(plot_data2, 'stacked');
legend(x, 'Location', 'EastOutside')
subplot(2,2,3:4)
b3 = bar(x, plot_data);
xtips1 = b3(1).XEndPoints;
ytips1 = b3(1).YEndPoints;
labels1 = string(round(b3(1).YData .*100) ./100);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
title('Thermal Losses into materials')
ylabel('Energy (nJ)')
savemfmt(h_wake, path_to_data,[prefix, 'Thermal_Losses_into_materials'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Electric field at the origin over time.
if isfield(pp_data, 'EfieldAtZerox')
    clf(h_wake)
    ax = axes('Parent', h_wake);
    plot(pp_data.EfieldAtZerox.data(:,1) * 1E9, pp_data.EfieldAtZerox.data(:,2),...
        'LineWidth',lw, 'Parent', ax)
    title('Electric field at origin (x component)', 'Parent', ax)
    xlabel('Time (ns)', 'Parent', ax)
    xlim([pp_data.EfieldAtZerox.data(1,1) * 1E9 pp_data.EfieldAtZerox.data(end,1) * 1e9])
    ylabel('Electric field (V/m)', 'Parent', ax)
    grid on
    savemfmt(h_wake, path_to_data, [prefix, 'EfieldAtZerox'])
    
    clf(h_wake)
    ax = axes('Parent', h_wake);
    plot(pp_data.EfieldAtZerox_freq.data(:,1) * 1E-9, pp_data.EfieldAtZerox_freq.data(:,2),...
        'LineWidth',lw, 'Parent', ax)
    title('Electric field at origin (x component)', 'Parent', ax)
    xlabel('Frequency (GHz)', 'Parent', ax)
    if pp_data.EfieldAtZerox_freq.data(end,1) * 1E-9 > graph_freq_lim
        upper_lim = graph_freq_lim;
    else
        upper_lim = pp_data.EfieldAtZerox_freq.data(end,1) * 1E-9;
    end %if
    xlim([0 graph_freq_lim])
    ylabel('Electric field (V/m/Hz)', 'Parent', ax)
    grid on
    savemfmt(h_wake, path_to_data, [prefix, 'EfieldAtZerox_freq'])
end %if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake potential over time.
clf(h_wake)
ax = axes('Parent', h_wake);
plot(wp(:,1), wp(:,2),...
    'LineWidth',lw, 'Parent', ax)
title('Evolution of longitudinal wake potential in the structure', 'Parent', ax)
xlabel('Time (ns)', 'Parent', ax)
xlim([wp(1,1) wp(end,1)])
ylabel('Wake potential (V/pC)', 'Parent', ax)
grid on
savemfmt(h_wake, path_to_data, [prefix, 'wake_potential'])

clf(h_wake)
ax = axes('Parent', h_wake);
plot(wpdx(:,1), wpdx(:,2),...
    'LineWidth',lw, 'Parent', ax)
title('Evolution of dipole transverse wake potential in the structure (x)', 'Parent', ax)
xlabel('Time (ns)', 'Parent', ax)
xlim([wpdx(1,1) wpdx(end,1)])
ylabel('Wake potential (V/pC)', 'Parent', ax)
grid on
savemfmt(h_wake, path_to_data, [prefix, 'transverse_dipole_x_wake_potential'])

clf(h_wake)
ax = axes('Parent', h_wake);
plot(wpdy(:,1), wpdy(:,2),...
    'LineWidth',lw, 'Parent', ax)
title('Evolution of dipole transverse wake potential in the structure (y)', 'Parent', ax)
xlabel('Time (ns)', 'Parent', ax)
xlim([wpdy(1,1) wpdy(end,1)])
ylabel('Wake potential (V/pC)', 'Parent', ax)
grid on
savemfmt(h_wake, path_to_data, [prefix, 'transverse_dipole_y_wake_potential'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake impedance.
clf(h_wake)
ax = axes('Parent', h_wake);
plot(wi_re(:,1), wi_re(:,2), 'b', 'Parent', ax);
title('Longditudinal real wake impedance', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('Impedance (Ohms)', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend(['Wake loss factor = ',num2str(pp_data.Wake_impedance.s.loss.s .* 1E9),'mV/pC'])
grid on
savemfmt(h_wake, path_to_data, [prefix, 'longditudinal_real_wake_impedance'])

clf(h_wake)
ax = axes('Parent', h_wake);
plot(wi_dipole_x(:,1), wi_dipole_x(:,2), 'b', 'Parent', ax);
title('Transverse (x) real wake impedance', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('Impedance (Ohms)', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend(['Wake loss factor = ',num2str(pp_data.Wake_impedance.x.loss.x .* 1E9),'mV/pC'])
grid on
savemfmt(h_wake, path_to_data, [prefix, 'transverse_x_real_wake_impedance'])

clf(h_wake)
ax = axes('Parent', h_wake);
plot(wi_dipole_y(:,1), wi_dipole_y(:,2), 'b', 'Parent', ax);
title('Transverse (y) real wake impedance', 'Parent', ax)
xlabel('Frequency (GHz)', 'Parent', ax)
ylabel('Impedance (Ohms)', 'Parent', ax)
xlim([0 graph_freq_lim])
ylim([0 inf])
legend(['Wake loss factor = ',num2str(pp_data.Wake_impedance.y.loss.y .* 1E9),'mV/pC'])
grid on
savemfmt(h_wake, path_to_data, [prefix, 'transverse_y_real_wake_impedance'])


clf(h_wake)
ax = axes('Parent', h_wake);
hold on;
[~, Q_sort_inds] = sort(Q);
if length(peaks) > 5
    plot(peaks(:,1)*1E-9, R_over_Q, '*b');
    plot(peaks(Q_sort_inds(1:5),1) * 1E-9, R_over_Q(Q_sort_inds(1:5)), '*r')
else
    plot(peaks(:,1)*1E-9, R_over_Q, '*r');
end %if

for hs = 1:size(peaks,1)
    text(peaks(hs,1)*1E-9, R_over_Q(hs), ['Q=',num2str(round(Q(hs)))])
end %for
xlabel('Frequency (GHz)')
ylabel('R/Q')
hold off
savemfmt(h_wake, path_to_data, [prefix, 'R_over_Q_from_wake'])

clf(h_wake)
ax = axes('Parent', h_wake);
hold on;
[~, R_over_Q_sort_inds] = sort(R_over_Q);
if length(peaks) > 5
    plot(peaks(:,1)*1E-9, Q, '*b');
    plot(peaks(R_over_Q_sort_inds(1:5),1) * 1E-9, Q(R_over_Q_sort_inds(1:5)), '*r')
else
    plot(peaks(:,1)*1E-9, Q, '*r');
end %if
for hs = 1:size(peaks,1)
    text(peaks(hs,1)*1E-9, Q(hs), ['R/Q=',num2str(round(R_over_Q(hs)*10)/10)])
end %for
xlabel('Frequency (GHz)')
ylabel('Q')
hold off
savemfmt(h_wake, path_to_data, [prefix, 'Q_from_wake'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Port signals
port_names = regexprep(pp_data.port.labels,'_',' ');
clf(h_wake)
if isfield(pp_data.port, 'timebase')
    [hwn, ksn] = num_subplots(length(port_names));
    for ens = length(port_names):-1:1 % ports
        ax_sp(ens) = subplot(hwn,ksn,ens);
        try
            % This is to cope with the case of missing data files.
        plot(pp_data.port.timebase .* 1E9, pp_data.port.data.time.power_port.data{ens}, 'b', 'Parent', ax_sp(ens))
        end
        title(port_names{ens}, 'Parent', ax_sp(ens))
        xlim([pp_data.port.timebase(1) .* 1E9 pp_data.port.timebase(end) .* 1E9])
        xlabel('Time (ns)', 'Parent', ax_sp(ens))
        ylabel('Power (W)', 'Parent', ax_sp(ens))
        grid on
    end %for
    savemfmt(h_wake, path_to_data, [prefix, 'port_signals'])
    for ens = length(port_names):-1:1 % ports
        xlim(ax_sp(ens),[pp_data.port.timebase(1) .* 1E9 4])
    end %for
    savemfmt(h_wake, path_to_data, [prefix, 'port_signals_first4ns'])
end %if

%% Voltage monitors
clf(h_wake)
if isfield(pp_data, 'voltages')
    [hwn, ksn] = num_subplots(length(pp_data.voltages));
    for ens = length(pp_data.voltages):-1:1 
        ax_sp(ens) = subplot(hwn,ksn,ens);
        try
            % This is to cope with the case of missing data files.
        plot(pp_data.voltages{ens}.data(:,1) .* 1E9, pp_data.voltages{ens}.data(:,2), 'b', 'Parent', ax_sp(ens))
        end
        title(regexprep(pp_data.voltages{ens}.title, 'voltage ',''), 'Parent', ax_sp(ens))
        xlim([pp_data.voltages{ens}.data(1,1) .* 1E9 pp_data.voltages{ens}.data(end, 1) .* 1E9])
        xlabel('Time (ns)', 'Parent', ax_sp(ens))
        ylabel('Voltage (V)', 'Parent', ax_sp(ens))
        grid on
    end %for
    savemfmt(h_wake, path_to_data, [prefix, 'voltage_monitors'])
    for ens = length(pp_data.voltages):-1:1 
        xlim(ax_sp(ens),[pp_data.voltages{ens}.data(1,1) .* 1E9 4])
    end %for
    savemfmt(h_wake, path_to_data, [prefix, 'voltage_monitors_first4ns'])
end %if

% clf(h_wake)
% ax = axes('Parent', h_wake);
% [hwn, ksn] = num_subplots(length(port_names));
% for ens = length(port_names):-1:1 % ports
%     ax_sp2(ens) = subplot(hwn,ksn,ens);
%     hold(ax_sp2(ens), 'all')
%     for seo = 1:size(pp_data.port.data.time.power_port_mode{ens},2) % modes
%         plot(pp_data.port.timebase, pp_data.port.data.time.power_port_mode{ens}(:,seo), 'Parent',ax_sp2(ens))
%     end %for
%     hold(ax_sp2(ens), 'off')
%     title(port_names{ens}, 'Parent', ax_sp2(ens))
%     xlabel('Time (ns)', 'Parent', ax_sp2(ens))
%     ylabel('', 'Parent', ax_sp2(ens))
%     xlim([pp_data.port.timebase(1) pp_data.port.timebase(end)])
% %     graph_add_background_patch(pp_data.port.t_start(ens) * 1E9)
% end %for
% savemfmt(h_wake, path_to_data,'port_signals_separated_modes')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy over time.
clf(h_wake)
energy = pp_data.Energy.data .* 1E9;
ax = axes('Parent', h_wake);
if ~isnan(energy)
    minlim = energy(end,2);
    maxlim = max(energy(:,2));
    minxlim = energy(1,1);
    maxxlim = energy(end,1);
    if ~isnan(minlim)
        if minlim >0
            semilogy(energy(:,1),energy(:,2),'b', 'LineWidth',lw, 'DisplayName', 'Energy decay')
            if minlim < maxlim
                ylim([minlim maxlim])
                ylabel('Energy (J)')
                
            end %if
        else
            plot(energy(:,1), energy(:,2),'LineWidth',lw)
            ylim([minlim 0])
            ylabel('Energy (relative)')
        end %if
    end %if
    xlim([minxlim maxxlim])
    title('Energy over time');
    xlabel('Time (ns)')
    grid on
end %if
savemfmt(h_wake, path_to_data, [prefix, 'Energy'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking alignment of the input signals
clf(h_wake)
ax = axes('Parent', h_wake);
plot(wp(:,1), ...
    wp(:,2) ./ max(abs(wp(:,2))),'b',...
    pp_data.Charge_distribution.data(:,1) .* 1E9, ...
    pp_data.Charge_distribution.data(:,2) ./ max(pp_data.Charge_distribution.data(:,2)),'r',...
    'LineWidth',lw)
xlim([-inf, 0.1])
ylim([-1.05 1.05])
xlabel('time (ns)')
ylabel('a.u.')
grid on
legend('Wake potential', 'Charge distribution','Location','SouthEast')
title('Alignment check')
savemfmt(h_wake, path_to_data, [prefix, 'input_signal_alignment_check'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf(h_wake)
ax = axes('Parent', h_wake);
beg_ind = find(wp(:,1) > -0.05, 1, 'first');
scaled_wp = wp(:,2) ./ max(abs(wp(:,2)));
wp_time = wp(:,1);
scaled_cd = interp1(pp_data.Charge_distribution.data(:,1) .* 1E9, ...
    pp_data.Charge_distribution.data(:,2),wp_time);
[~ ,centre_ind] = min(abs(wp(:,1)));
span = centre_ind - beg_ind;
scaled_wp = scaled_wp(centre_ind - span:centre_ind + span);
wp_time = wp_time(centre_ind - span:centre_ind + span);
real_wp = scaled_wp + flipud(scaled_wp);
imag_wp = scaled_wp - flipud(scaled_wp);
scaled_cd = scaled_cd(centre_ind - span:centre_ind + span) ./ ...
    max(scaled_cd(centre_ind - span:centre_ind + span));
plot(wp_time, real_wp, 'b',...
    wp_time, imag_wp,'m',...
    wp_time, scaled_cd,':r',...
    'LineWidth',lw, 'Parent', ax)
hold(ax, 'on')
[~,ind] =  max(wp(:,2));
plot([wp(ind,1) wp(ind,1)], get(gca,'Ylim'), ':m')
hold(ax, 'off')
xlabel('time (ns)')
ylabel('a.u.')
title('Lossy and reactive signal')
legend('Real','Imaginary','Charge','Location','SouthEast')
savemfmt(h_wake, path_to_data, [prefix, 'input_signal_lossy_reactive_check'])
clf(h_wake)
close(h_wake)
