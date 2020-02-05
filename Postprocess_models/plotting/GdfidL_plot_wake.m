<<<<<<< HEAD
function GdfidL_plot_wake(path_to_data, ppi, range, chosen_wake_length, hfoi)
% Generate the graphs based on the wake simulation data.
% Graphs are saved in fig format and png, eps.
% 
% path_to_data is where the resulting files are saved to.
% range is to do with peak identification for Q values, and
% is the separation peaks have to have to be counted as separate.
%
% Example GdfidL_plot_wake(wake_data, ppi, mi, run_log,  pth, range)

pth = fullfile(path_to_data, 'wake');
load(fullfile(pth, 'run_inputs.mat'), 'modelling_inputs'); 
load(fullfile(pth,'data_postprocessed.mat'), 'pp_data');
load(fullfile(pth, 'data_analysed_wake'),'wake_sweep_data');
load(fullfile(pth, 'data_from_run_logs.mat'), 'run_logs')
for nw = 1:length(wake_sweep_data.raw)
wake_sweep_vals(nw) = wake_sweep_data.raw{1, nw}.wake_setup.Wake_length;
end %for
chosen_wake_ind = find(wake_sweep_vals == str2double(chosen_wake_length));
if isempty(chosen_wake_ind)
    [~,chosen_wake_ind] = min(abs((wake_sweep_vals ./ str2double(chosen_wake_length)) - 1));
    warning('Chosen wake length not found. Setting the wakelength closest value.')
end %if
wake_data.port_time_data = wake_sweep_data.port_time_data{chosen_wake_ind};
wake_data.time_domain_data = wake_sweep_data.time_domain_data{chosen_wake_ind};
wake_data.frequency_domain_data = wake_sweep_data.frequency_domain_data{chosen_wake_ind};

%Line width of the graphs
lw = 2;
% limit to the horizontal axis.
graph_freq_lim = hfoi * 1e-9;
% find the coresponding index.
cut_freq_ind = find(wake_data.frequency_domain_data.f_raw*1E-9 < graph_freq_lim,1,'last');
% also find the index for 9GHz for zoomed graphs
% power_dist_ind = find(wake_data.frequency_domain_data.f_raw > 9E9, 1,'First');

% location and size of the default figures.
fig_pos = [10000 678 560 420];

% Set the level vector to show the total energy loss on graphs (nJ).
y_lev_t = [wake_data.time_domain_data.loss_from_beam *1e9,...
    wake_data.time_domain_data.loss_from_beam * 1e9];
y_lev_f = [wake_data.frequency_domain_data.Total_bunch_energy_loss *1e9,...
    wake_data.frequency_domain_data.Total_bunch_energy_loss * 1e9];

cut_off_freqs = pp_data.port.frequency_cutoffs;
cut_off_freqs = cellfun(@(x) x*1e-9,cut_off_freqs, 'UniformOutput', false);

% setting up some style lists for the graphs.
cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[1, 0, 0.5],[0.5, 0, 1],[0.5, 1, 0] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};

% Identifying the non replica ports.
for sjew = length(pp_data.port.labels_table):-1:1
    lab_ind(sjew) = find(strcmp(pp_data.port.labels,...
        pp_data.port.labels_table{sjew}));
end %for
% can I just do a search using the original names in raw data?

% Some pre processing to pull out trends.
[wl, freqs, Qs, mags, bws] = find_Q_trends(wake_sweep_data.frequency_domain_data, range);
% Show the Q values of the resonances shows if the simulation has stablised.
for ehw = size(freqs,1):-1:1
    Q_leg{ehw} = [num2str(round(freqs(ehw,1)./1e7)./1e2), 'GHz'];
end %for
% These are the plots to generate for a single value of sigma.
% sigma = round(str2num(mi.beam_sigma) ./3E8 *1E12 *10)/10;
if isfield(pp_data.port, 'timebase')
    port_names = regexprep(pp_data.port.labels,'_',' ');
    port_names = regexprep(port_names,'-e$|-h$','');
end %if
if size(wake_data.frequency_domain_data.raw_port_energy_spectrum,2) == 2
    % assume that only beam ports are involved and set a flag so that the
    % signal port values are not displayed.
    bp_only_flag = 1;
else
    bp_only_flag = 0;
end %if

[bunch_energy_loss, beam_port_energy_loss, signal_port_energy_loss, ...
    structure_energy_loss, material_names] =  ...
    extract_energy_loss_data_from_wake_data(pp_data, wake_data);

[timebase_cs, e_total_cs, e_ports_cs] =  ...
    extract_cumulative_total_energy_from_wake_data(wake_data);

[model_mat_data, mat_loss, m_time, m_data] = ...
    extract_material_losses_from_wake_data(pp_data, modelling_inputs.extension_names);

[frequency_scale_bs, bs] = ...
    extract_bunch_spectrum_from_wake_data(wake_data);

[timebase_wp, wp, wpdx, wpdy, wpqx, wpqy] = extract_wake_potential_from_wake_data(wake_data);

[frequency_scale_wi, wi_re, wi_im] = ...
    extract_longitudinal_wake_impedance_from_wake_data(wake_data, cut_freq_ind);

[wi_quad_x, wi_quad_y, wi_dipole_x, wi_dipole_y] = ...
    extract_transverse_wake_impedance_from_wake_data(pp_data, wake_data);

[wi_quad_x_comp, wi_quad_y_comp, wi_dipole_x_comp, wi_dipole_y_comp] = ...
    extract_transverse_wake_impedance_from_wake_data(pp_data, wake_data,'GdfidL');

[timebase_port, modes, max_mode, dominant_modes, port_cumsum, t_start] = ...
    extract_port_signals_from_wake_data(pp_data, wake_data, lab_ind);

[frequency_scale_bls, bls] = ...
    extract_bunch_loss_spectrum_from_wake_data(wake_data);

[~, pes] = extract_port_energy_spectrum_from_wake_data(wake_data);

[frequency_scale_ports, beam_port_spectrum, ...
    signal_port_spectrum, port_energy_spectra] = ...
    extract_port_spectra_from_wake_data(pp_data, wake_data, cut_freq_ind, lab_ind);

[frequency_scale_ts, spectra_ts, peaks_ts, n_slices, ...
    slice_length, slice_timestep] =  ...
    extract_time_slice_results_from_wake_data(wake_data);

pme = extract_port_energy_from_wake_data(wake_data);

[frequency_scale_mc, spectra_mc] = ...
    extract_machine_conditions_results_from_wake_data(wake_data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal graphs
leg = {};
% make the array that the bar function understands.
% this is the total energy lossed from the beam.
py(1,1) = bunch_energy_loss;
py(2,1)=0;
% These are the places that energy has been recorded.
% assume beam ports are always there.
py(2,2) = beam_port_energy_loss;
py(1,2) =0;
leg{1} = ['Beam ports (',num2str(py(2,2)) ,'nJ)'];
if ~isnan(signal_port_energy_loss)
    % add signal ports if there is any signal.
    py(2,3) = signal_port_energy_loss;
    py(1,3) =0;
    leg{2} = ['Signal ports (',num2str(py(2,3)) ,'nJ)'];
end %if

if ~isnan(structure_energy_loss)
    orig_size = size(py,2);
    new_size = size(py,2) + size(structure_energy_loss,2);
    py(1, orig_size + 1:new_size) = 0;
    py(2, orig_size + 1:new_size) = structure_energy_loss;
    for lse = 1:size(structure_energy_loss,2)
        leg{orig_size-1 + lse} = [material_names{lse}, ' (',...
            num2str(structure_energy_loss(1,lse)),'nJ)'];
    end %for
end %if

h_wake = figure('Position',fig_pos);

ax(1) = axes('Parent', h_wake);
f1 = bar(ax(1), py,'stacked');
% turn off the energy for the energy loss annotation
annot = get(f1, 'Annotation');
set(get(annot{1},'LegendInformation'),'IconDisplayStyle', 'off')
set(f1(1), 'FaceColor', [0.5 0.5 0.5]);
for eh = 2:size(py,2)
    set(f1(eh), 'FaceColor', cols{eh-1});
end %for
set(ax(1), 'XTickLabels',{'Energy lost from beam', 'Energy accounted for'})
set(ax(1),'XTickLabelRotation',45)
ylabel('Energy from 1 pulse (nJ)')
legend(ax(1), leg, 'Location', 'EastOutside')
savemfmt(h_wake, pth,'Thermal_Losses_within_the_structure')
clf(h_wake)
clear leg

if ~isnan(mat_loss)
    ax(2) = axes('Parent', h_wake);
    plot_data = mat_loss/sum(mat_loss) *100;
    % matlab will ignore any values of zero which messes up the maping of the
    % lables. This just makes any zero values a very small  positive value to avoid
    % this.
    plot_data(plot_data == 0) = 1e-12;
    % add numerical value to label
    leg = {};
    for ena = length(plot_data):-1:1
        leg{ena} = strcat(model_mat_data{ena,2}, ' (',num2str(round(plot_data(ena)*100)/100),'%)');
    end %for
    p = pie(ax(2), plot_data, ones(length(plot_data),1));
    % setting the colours on the pie chart.
    pp = findobj(p, 'Type', 'patch');
    % check if both beam ports and signal ports are used.
    col_ofst = size(py,2) -1 - length(plot_data);
    for sh = 1:length(pp)
        set(pp(sh), 'FaceColor',cols{sh+col_ofst});
    end %for
    legend(ax(2), leg,'Location','EastOutside', 'Interpreter', 'none')
    clear leg
    title('Losses distribution within the structure', 'Parent', ax(2))
    savemfmt(h_wake, pth,'Thermal_Fractional_Losses_distribution_within_the_structure')
clf(h_wake)
end %if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isnan(m_time{1})
    ax(3) = axes('Parent', h_wake);
    for na = 1:length(m_time)
        hold on
        plot(ax(3), m_time{na} ,m_data{na}, 'Color', cols{na+col_ofst},'LineWidth',lw)
        leg{na} = model_mat_data{na,2};
        hold off
    end %for
    legend(ax(3), leg, 'Location', 'SouthEast')
    xlabel(ax(3), 'Time (ns)')
    ylabel(ax(3), 'Energy (nJ)')
    title('Material loss over time', 'Parent', ax(3))
    savemfmt(h_wake, pth,'Material_loss_over_time')
clf(h_wake)
    clear leg
end %if

%% Cumulative total energy.
if ~all(isnan(timebase_port)) && ~all(isnan(port_cumsum))
    ax(4) = axes('Parent', h_wake);
    plot(timebase_cs, e_total_cs,'b','LineWidth',lw, 'Parent', ax(4))
    graph_add_horizontal_lines(y_lev_t)
    title('Cumulative Energy seen at all ports', 'Parent', ax(4))
    xlabel('Time (ns)', 'Parent', ax(4))
    ylabel('Cumulative Energy (nJ)', 'Parent', ax(4))
    xlim([0 timebase_cs(end)])
    text(timebase_cs(end), y_lev_t(1), '100%')
    fr = (e_total_cs(end) / y_lev_t(1)) *100;
    text(timebase_cs(end), e_total_cs(end), [num2str(round(fr)),'%'])
    savemfmt(h_wake, pth,'cumulative_total_energy')
clf(h_wake)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Cumulative energy seen at each port.
    ax(5) = axes('Parent', h_wake);
    clk = 1;
    leg = cell(length(lab_ind),1);
    hold(ax(5), 'all')
    for ens = 1:length(lab_ind)
        plot(timebase_cs, e_ports_cs(:,lab_ind(ens)),...
            'Color',cols{ens},'LineWidth',lw, 'LineStyle', l_st{1}, 'Parent', ax(5))
        leg{clk} = port_names{lab_ind(ens)};
        clk = clk +1;
    end %for
    hold(ax(5), 'off')
    title('Cumulative energy seen at the ports (nJ)', 'Parent', ax(5))
    xlabel('Time (ns)', 'Parent', ax(5))
    ylabel('Cumulative Energy (nJ)', 'Parent', ax(5))
    xlim([timebase_cs(1) timebase_cs(end)])
    legend(ax(5), regexprep(leg,'_',' '), 'Location', 'SouthEast')
    savemfmt(h_wake, pth,'cumulative_energy')
clf(h_wake)
end %if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake potential over time.
ax(6) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(end);
hold(ax(6), 'all')
plot(timebase_wp, wp,...
    'LineWidth',lw, 'Parent', ax(6))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(end)]);
title('Evolution of longitudinal wake potential in the structure', 'Parent', ax(6))
xlabel('Time (ns)', 'Parent', ax(6))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(6))
savemfmt(h_wake, pth,'wake_potential')
clf(h_wake)

ax_num=50;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(end);
hold(ax(ax_num), 'all')
plot(timebase_wp, wpdx,...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(end)]);
title('Evolution of dipole transverse wake potential in the structure (x)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, pth,'transverse_dipole_y_wake_potential')
clf(h_wake)

ax_num=51;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(end);
hold(ax(ax_num), 'all')
plot(timebase_wp, wpdy,...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(end)]);
title('Evolution of dipole transverse wake potential in the structure (y)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, pth,'transverse_dipole_y_wake_potential')
clf(h_wake)

ax_num=52;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(end);
hold(ax(ax_num), 'all')
plot(timebase_wp, wpqx,...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(end)]);
title('Evolution of quadrupole transverse wake potential in the structure (x)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, pth,'transverse_quadrupole_x_wake_potential')
clf(h_wake)

ax_num=53;
ax(ax_num) = axes('Parent', h_wake);
minxlim = timebase_wp(1);
maxxlim = timebase_wp(end);
hold(ax(ax_num), 'all')
plot(timebase_wp, wpqy,...
    'LineWidth',lw, 'Parent', ax(ax_num))
minxlim = min([minxlim, timebase_wp(1)]);
maxxlim = max([maxxlim, timebase_wp(end)]);
title('Evolution of quadrupole transverse wake potential in the structure (y)', 'Parent', ax(ax_num))
xlabel('Time (ns)', 'Parent', ax(ax_num))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(ax_num))
savemfmt(h_wake, pth,'transverse_quadrupole_y_wake_potential')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake impedance.
ax(7) = axes('Parent', h_wake);
plot(frequency_scale_wi, wi_re, 'b', 'Parent', ax(7));
hold(ax(7), 'on')
plot(pp_data.Wake_impedance(:,1)*1e-9, pp_data.Wake_impedance(:,2), 'r', 'Parent', ax(7))
hold(ax(7), 'off')
title('Longditudinal real wake impedance', 'Parent', ax(7))
xlabel('Frequency (GHz)', 'Parent', ax(7))
ylabel('Impedance (Ohms)', 'Parent', ax(7))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, pth,'longditudinal_real_wake_impedance')
clf(h_wake)

ax(8) = axes('Parent', h_wake);
plot(frequency_scale_wi, wi_im, 'b', 'Parent', ax(8));
title('Longditudinal imaginary wake impedance', 'Parent', ax(8))
xlabel('Frequency (GHz)', 'Parent', ax(8))
ylabel('Impedance (Ohms)', 'Parent', ax(8))
xlim([0 graph_freq_lim])
savemfmt(h_wake, pth, 'longditudinal_imaginary_wake_impedance')
clf(h_wake)

ax(9) = axes('Parent', h_wake);
plot(wi_quad_x.scale, wi_quad_x.data, 'b', 'Parent', ax(9));
hold(ax(9), 'on')
plot(wi_quad_x_comp.scale, wi_quad_x_comp.data, 'b', 'Parent', ax(9));
hold(ax(9), 'off')
title('Transverse X real quadrupole wake impedance', 'Parent', ax(9))
legend('Matlab', 'GdfidL')
xlabel('Frequency (GHz)', 'Parent', ax(9))
ylabel('Impedance (Ohms)', 'Parent', ax(9))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, pth, 'Transverse_X_real_quadrupole_wake_impedance')
clf(h_wake)

ax(10) = axes('Parent', h_wake);
plot(wi_quad_y.scale, wi_quad_y.data, 'b', 'Parent', ax(10));
hold(ax(10), 'on')
plot(wi_quad_y_comp.scale, wi_quad_y_comp.data, 'b', 'Parent', ax(10));
hold(ax(10), 'off')
legend('Matlab', 'GdfidL')
title('Transverse Y real quadrupole wake impedance', 'Parent', ax(10))
xlabel('Frequency (GHz)', 'Parent', ax(10))
ylabel('Impedance (Ohms)', 'Parent', ax(10))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, pth,'Transverse_Y_real_quadrupole_wake_impedance')
clf(h_wake)

ax_num = 41;
ax(ax_num) = axes('Parent', h_wake);
plot(wi_dipole_x.scale, wi_dipole_x.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'on')
plot(wi_dipole_x_comp.scale, wi_dipole_x_comp.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'off')
legend('Matlab', 'GdfidL')
title('Transverse X real dipole wake impedance', 'Parent', ax(ax_num))
xlabel('Frequency (GHz)', 'Parent', ax(ax_num))
ylabel('Impedance (Ohms)', 'Parent', ax(ax_num))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, pth, 'Transverse_X_real_dipole_wake_impedance')
clf(h_wake)

ax_num = 42;
ax(ax_num) = axes('Parent', h_wake);
plot(wi_dipole_y.scale, wi_dipole_y.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'on')
plot(wi_dipole_y_comp.scale, wi_dipole_y_comp.data, 'b', 'Parent', ax(ax_num));
hold(ax(ax_num), 'off')
legend('Matlab', 'GdfidL')
title('Transverse Y real dipole wake impedance', 'Parent', ax(ax_num))
xlabel('Frequency (GHz)', 'Parent', ax(ax_num))
ylabel('Impedance (Ohms)', 'Parent', ax(ax_num))
xlim([0 graph_freq_lim])
ylim([0 inf])
savemfmt(h_wake, pth,'Transverse_Y_real_dipole_wake_impedance')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolating the wake loss factor for longer bunches.
comp = wake_data.frequency_domain_data.wlf * ...
    (wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time...
    ./(str2num(modelling_inputs.beam_sigma)./3E8)).^(-3/2);
ax(11) = axes('Parent', h_wake);
plot(wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time * 1e12,...
    wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.wlf * 1e-12,'b',...
    str2num(modelling_inputs.beam_sigma)./3E8 *1E12, wake_data.frequency_domain_data.wlf * 1e-12,'*k',...
    wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time * 1e12,...
    comp * 1e-12, 'm',...
    'LineWidth',lw, 'Parent', ax(11))
xlabel('beam sigma (ps)', 'Parent', ax(11))
ylabel('Wake lossfactor (V/pC)', 'Parent', ax(11))
if sign(wake_data.frequency_domain_data.wlf) == 1
    ylim([0 1.1*wake_data.frequency_domain_data.wlf * 1e-12])
end %if
legend(ax(11), 'Calculated from data', 'Simulated beam size',  'Resistive wall (\sigma^{-3/2})')
title({'Extrapolating wake loss factor', ' for longer bunch lengths'}, 'Parent', ax(11))
savemfmt(h_wake, pth, 'wake_loss_factor_extrapolation_bunch_length')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolating the wake loss factor for longer trains.
ax(12) = axes('Parent', h_wake, 'Position', [0.1300 0.1400 0.7750 0.7800]);
for jes = size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss,3):-1:1
    loss_data = squeeze(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss(:,:,jes));
    tmp =loss_data';
    loss(jes,:) = tmp(:);
end %for
bar(loss', 'Parent', ax(12));
set(gca,'XTickLabel',['','','',''])
lims = ylim;
lim_ext = lims(2) - lims(1);
lab_loc = lims(1) - 0.09 * lim_ext;
cur_tick = 1;
bt_tick = 1;
for naw = 1:length(ppi.current) * length(ppi.bt_length)
    text(naw,lab_loc,...
        {[num2str(ppi.current(cur_tick)*1000),'mA']; num2str(ppi.bt_length(bt_tick));' bunch'; 'fill'},...
        'HorizontalAlignment','Center', 'Parent', ax(12), 'FontSize', 9)
    if cur_tick >= length(ppi.current)
        cur_tick = 1;
        bt_tick = bt_tick +1;
    else
        cur_tick = cur_tick +1;
    end %if
end %for
ylabel('Power loss (W)', 'Parent', ax(12))
title({'Power loss from beam','for different machine conditions'}, 'Parent', ax(12))
for rh = length(ppi.rf_volts):-1:1
    leg2{rh} = [num2str(ppi.rf_volts(1)),'MV RF'];
end %for
legend(ax(12), leg2, 'Location', 'NorthWest')
savemfmt(h_wake, pth,'power_loss_for_different_machine_conditions')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(pp_data.port, 'timebase') && ~isnan(wake_data.frequency_domain_data.Total_energy_from_ports)
    structure_loss = wake_data.frequency_domain_data.Total_bunch_energy_loss...
        - wake_data.frequency_domain_data.Total_energy_from_ports;
    for ns = length(ppi.current):-1:1
        for eh = length(ppi.bt_length):-1:1
            single_bunch_losses(ns,eh) = ...
                structure_loss .*1e9./ run_logs.charge .* ...
                (ppi.current(ns)./(ppi.RF_freq .*...
                ppi.bt_length(eh)/936));
        end %for
    end %for
    single_bunch_losses = single_bunch_losses(:,:)';
    ax(13) = axes('Parent', h_wake);
    bar([single_bunch_losses(:), loss(1,:)'], 'Parent', ax(13));
    set(ax(13),'XTickLabel',['','','',''])
    cur_tick = 1;
    bt_tick = 1;
    for naw = 1:length(ppi.current) * length(ppi.bt_length)
        text(naw,lab_loc,...
            {[num2str(ppi.current(cur_tick)*1000),'mA']; [num2str(ppi.bt_length(bt_tick)),' bunches']},...
            'HorizontalAlignment','Center', 'Parent', ax(13))
        if cur_tick >= length(ppi.current)
            cur_tick = 1;
            bt_tick = bt_tick +1;
        else
            cur_tick = cur_tick +1;
        end %if
    end %for
    ylabel('Power loss (W)', 'Parent', ax(13))
    title({'Comparison of power loss', 'with scaled single bunch', 'and full spectral analysis'}, 'Parent', ax(13))
    legend(ax(13), 'Single bunch', 'Full analysis', 'Location', 'NorthWest')
    savemfmt(h_wake, pth,'power_loss_for_analysis')
clf(h_wake)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Port signals
%     if  iscell(modes)
        [hwn, ksn] = num_subplots(length(lab_ind));
        for ens = length(lab_ind):-1:1 % ports
            ax_sp(ens) = subplot(hwn,ksn,ens);
            plot(timebase_port, dominant_modes{ens}, 'b', 'Parent', ax_sp(ens))
            title([port_names{lab_ind(ens)}, ' (mode ',num2str(max_mode(ens)),')'], 'Parent', ax_sp(ens))
            xlim([timebase_port(1) timebase_port(end)])
            xlabel('Time (ns)', 'Parent', ax_sp(ens))
            graph_add_background_patch(pp_data.port.t_start(ens) * 1E9)
            ylabel('', 'Parent', ax_sp(ens))
        end %for
        savemfmt(h_wake, pth,'dominant_port_signals')
        clf(h_wake)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax(15) = axes('Parent', h_wake);
        [hwn, ksn] = num_subplots(length(lab_ind));
        for ens = length(lab_ind):-1:1 % ports
            ax_sp2(ens) = subplot(hwn,ksn,ens);
            hold(ax_sp2(ens), 'all')
            for seo = 1:length(modes{ens}) % modes
                plot(timebase_port, modes{ens}{seo}, 'Parent',ax_sp2(ens))
            end %for
            hold(ax_sp2(ens), 'off')
            title(port_names{lab_ind(ens)}, 'Parent', ax_sp2(ens))
            xlabel('Time (ns)', 'Parent', ax_sp2(ens))
            ylabel('', 'Parent', ax_sp2(ens))
            xlim([timebase_port(1) timebase_port(end)])
            graph_add_background_patch(pp_data.port.t_start(ens) * 1E9)
        end %for
        savemfmt(h_wake, pth,'port_signals')
clf(h_wake)
    end %if
% end %if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Comparison of bunch losses vs port signals on a per frequency basis.
if isfield(pp_data.port, 'timebase') && ~isempty(cut_off_freqs)
    y_data = {bls; pes};
else
    % set the second trace to zeros as there is no port energy.
    y_data = {bls; zeros(length(bls),1)};
end %if
name = {'Energy loss distribution of bunch,', 'and energy seen at ports'};
cols = {'m','c'};
leg = {'Bunch loss', 'Port signal'};
% Combining all the port cutoff freqencies into one list.
cuts_temp = unique(cell2mat(cut_off_freqs));
cuts_temp = cuts_temp(cuts_temp > 1E-10);
report_plot_frequency_graphs(fig_pos, pth, y_lev_f, frequency_scale_bls, y_data, ...
    cut_freq_ind, cuts_temp, lw, ...
    name, ...
    graph_freq_lim, cols, leg)
clear leg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy left in the structure on a per frequency basis.
if isfield(pp_data.port, 'timebase')
    if ~isempty(cut_off_freqs)
        power_diff = bls - pes;
    else
        power_diff = bls ;
    end %if
    report_plot_frequency_graphs(fig_pos, pth, y_lev_f,...
        frequency_scale_bls, power_diff, cut_freq_ind, cuts_temp,...
        lw, 'Energy_left_in_structure', graph_freq_lim, 'b', [])
end %if

if wake_data.port_time_data.total_energy ~=0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% port signals on a per frequency basis for different port types.
    % assumes the beam ports are ports 1 and 2.
    % if isfield(wake_data.raw_data.port, 'timebase') && ~isnan(sum(wake_data.frequency_domain_data.signal_port_spectrum)) &&...
    %         ~isnan(sum(wake_data.frequency_domain_data.beam_port_spectrum))
    ax(16) = axes('Parent', h_wake);
    if bp_only_flag == 0
        plot(frequency_scale_ports, signal_port_spectrum,'r',...
            frequency_scale_ports, beam_port_spectrum,'k','LineWidth',lw)
        graph_add_vertical_lines(cuts_temp)
        legend('Signal ports', 'Beam ports')
        title('Energy loss distribution')
        xlabel('Frequency (GHz)')
        ylabel('Energy (nJ) per ')
        xlim([0 graph_freq_lim])
    end %if
    savemfmt(h_wake, pth,'Energy_loss_distribution')
clf(h_wake)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(17) = axes('Parent', h_wake);
    % the factor of 2 comes from the fact that we need to sum across both sides
    % of the fft. As these are real signals both sides are mirror images of
    % each other so you can just cumsum up half the frequency range and
    % multiply by 2.
    if bp_only_flag == 0
        plot(frequency_scale_ports, cumsum(signal_port_spectrum) .*2,'r',...
            frequency_scale_ports, cumsum(beam_port_spectrum).*2,'k','LineWidth',lw)
        graph_add_horizontal_lines(y_lev_f)
        graph_add_vertical_lines(cuts_temp)
        legend('Signal ports', 'Beam ports', 'Location','Best')
        title('Energy loss distribution')
        xlabel('Frequency (GHz)')
        ylabel('Cumlative sum of Energy (nJ)')
        xlim([0 graph_freq_lim])
    end %if
    savemfmt(h_wake, pth,'cumulative_energy_loss_distribution')
clf(h_wake)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(18) = axes('Parent', h_wake);
    fig_max = max(abs(beam_port_spectrum));
    hold(ax(18), 'on')
    for ns = 1:length(lab_ind)
        plot(frequency_scale_ports, port_energy_spectra{ns},'LineWidth',lw)
    end %for
    hold(ax(18), 'off')
    graph_add_vertical_lines(cuts_temp)
    legend(port_names(lab_ind), 'Location','Best')
    xlim([0 graph_freq_lim])
    if ylim > 0 & ~isnan(ylim)
        ylim([0 fig_max .* 1.1])
    end %if
    graph_add_vertical_lines(cuts_temp)
    title('Energy loss distribution ports')
    xlabel('Frequency (GHz)')
    ylabel('Energy (nJ)')
    xlim([0 graph_freq_lim])
    savemfmt(h_wake, pth,'energy_loss_port_types')
%     xlim([0 frequency_scale_ports(power_dist_ind)])
%     savemfmt(h(18), pth,'energy_loss_distribution_ports')
clf(h_wake)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(19) = axes('Parent', h_wake);
    % the factor of 2 comes from the fact that we need to sum across both sides
    % of the fft. As these are real signals both sides are mirror images of
    % each other so you can just cumsum up half the frequency range and
    % multiply by 2.
    hold(ax(19), 'all')
    for ns = 1:length(lab_ind)
        plot(frequency_scale_ports,...
            cumsum(port_energy_spectra{ns}).*2,'LineWidth',lw)
    end %for
    hold(ax(19), 'off')
    graph_add_vertical_lines(cuts_temp)
    legend( port_names(lab_ind), 'Location', 'NorthWest')
    xlim([0 graph_freq_lim])
    graph_add_vertical_lines(cuts_temp)
    title('Energy loss distribution beam ports')
    xlabel('Frequency (GHz)')
    ylabel('Cumlative sum of Energy (nJ)')
    xlim([0 graph_freq_lim])
    savemfmt(h_wake, pth,'cumulative_energy_loss_port_types')
%     xlim([0 frequency_scale_ports(power_dist_ind)])
%     savemfmt(h(19), pth,'cumulative_energy_loss_distribution_ports')
clf(h_wake)
end %if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Displaying some logfile information
lab = cell(1,1);
for naw = 1:size(cut_off_freqs,1)
    lab{naw} = ['Port ',num2str(naw)];
end %for
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cut off frequencies
ax(20) = axes('Parent', h_wake);
hold(ax(20), 'on')
for sen = 1:length(cut_off_freqs)
    plot(cut_off_freqs{sen} .* 1e-9,'*')
end %for
hold(ax(20), 'off')
title('Cut off frequencies for different modes')
ylabel('cut off frequency (GHz)')
xlabel('port mode')
savemfmt(h_wake, pth,'Cut_off_frequencies')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(21) = axes('Parent', h_wake);
hold(ax(21), 'all')
for sen = 1:length(cut_off_freqs)
    plot(cut_off_freqs{sen} .* 1e-9,'*')
end %for
hold(ax(21), 'off')
title('Cut off frequencies for different modes')
ylabel('cut off frequency (GHz)')
xlabel('port mode')
ylim([0 graph_freq_lim])
savemfmt(h_wake, pth,'Cut_off_frequencies_hfoi')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Q stability graphs
ax(22) = axes('Parent', h_wake);
if isempty(Qs) == 0
    plot(wl,Qs, ':*','LineWidth',lw)
end %if
title({'Change in Q',' over the sweep'})
xlabel('Wake length (m)')
ylabel('Q')
if isempty(Qs) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end %if
savemfmt(h_wake, pth,'sweep_Q')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(23) = axes('Parent', h_wake);
if isempty(mags) == 0
    plot(wl,mags, ':*','LineWidth',lw)
end %if
title({'Change in peak magnitude',' over the sweep'})
xlabel('Wake length (m)')
ylabel('Peak magnitude')
if isempty(mags) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end %if
savemfmt(h_wake, pth,'sweep_mag')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(24) = axes('Parent', h_wake);
if isempty(bws) == 0
    plot(wl,bws, ':*','LineWidth',lw)
end %if
title({'Change in bandwidth',' over the sweep'})
xlabel('Wake length (m)')
ylabel('Bandwidth')
if isempty(bws) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end %if
savemfmt(h_wake, pth,'sweep_bw')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(25) = axes('Parent', h_wake);
if isempty(freqs) == 0
    plot(wl,freqs * 1E-9, ':*','LineWidth',lw)
end %if
title({'Change in peak frequency',' over the sweep'})
xlabel('Wake length (mm)')
ylabel('Frequency (GHz)')
if isempty(freqs) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end %if
savemfmt(h_wake, pth,'sweep_freqs')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time slice analysis.
ax(26) = axes('Parent', h_wake);
imagesc(1:n_slices, frequency_scale_ts,log10(abs(spectra_ts)))
ylabel('Frequency(GHz)')
title('Block fft of wake potential')
xlabel('Time slices')
savemfmt(h_wake, pth,'time_slices_blockfft')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(27) = axes('Parent', h_wake);
plot(frequency_scale_ts,...
    abs(spectra_ts(:,end)))
legs = {'Data'};
hold(ax(27), 'on')
for mers = 1:size(peaks_ts,1)
    plot(peaks_ts(mers,1), peaks_ts(mers,2),'*r','LineWidth',lw)
    legs{mers+1} = [num2str(round(peaks_ts(mers,1) .* 10)./10), ' GHz'];
end %for
hold(ax(27), 'off')
xlabel('Frequency (GHz)')
title('FFT of final time slice')
legend(legs)
savemfmt(h_wake, pth,'time_slices_endfft')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(28) = axes('Parent', h_wake);
legs = cell(size(peaks_ts,1),1);
for wana = 1:size(peaks_ts,1)
    if wana >1
        hold(ax(28), 'all')
    end %if
    f_ind = frequency_scale_ts == peaks_ts(wana,1);
    %     f_ind = find(f_ind ==1)
    semilogy((abs(spectra_ts(f_ind,:))),'LineWidth',lw);
    %length of a time slice.
    lts = slice_length * slice_timestep;
    num_slices_gap = size(spectra_ts,2);
    x2 = num_slices_gap* lts;
    y1 = log10(abs(spectra_ts(f_ind,end - num_slices_gap +1)));
    y2 = log10(abs(spectra_ts(f_ind,end)));
    tau =  - x2 ./(y2 - y1);
    Q_graph = pi .* peaks_ts(wana,1)*1E9 .* tau;
    legs{wana} = [num2str(round(peaks_ts(wana,1) .* 10)./10), ' GHz   :Q: ',num2str(round(Q_graph))];
    
end %for
hold(ax(28), 'off')
xlabel('Time slice')
ylabel('Magnitude (log scale)')
title('Trend of individual frequencies over time')
legend(legs)
savemfmt(h_wake, pth,'time_slices_trend')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show the energy in the port modes.
% This is to make sure that enough modes were used in the simulation.
if isfield(pp_data.port, 'timebase') && ...
        isfield(wake_data.port_time_data, 'port_mode_energy')
    ax(29) = axes('Parent', h_wake);
    [hwn, ksn] = num_subplots(size(pme,1));
    for ydh = 1:size(pme,1) % Ports
        x_vals = 1:size(pme,2);
%         x_vals = linspace(1,size(pme),...
%             length(pme{lab_ind(ydh)}));
        subplot(hwn,ksn,ydh)
        plot(x_vals, pme(ydh,:),'LineWidth',lw);
        xlabel('mode number')
        title('Energy in port modes')
        ylabel('Energy (nJ)')
        title(port_names{lab_ind(ydh)})
    end %for
    savemfmt(h_wake, pth,'energy_in_port_modes')
clf(h_wake)
end %if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Showing the overlap of the bunch spectra and the wake impedance.
ax(30) = axes('Parent', h_wake);
maxy = max(wi_re);
plot(frequency_scale_wi, ...
    wi_re ./maxy,'b',...
    frequency_scale_bs, ...
    abs((bs).^2) ./ max(abs(bs).^2),'r','LineWidth',lw)
title('Overlap of bunch spectra^2 and wake impedance')
xlabel('Frequency (GHz)')
ylabel('Normalised units')
xlim([0 graph_freq_lim])
ylim([0 1])
savemfmt(h_wake, pth,'Overlap_of_bunch_spectra_and_wake_impedance')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(32) = axes('Parent', h_wake);
current_select = 1;
train_length_select = 2;
rf_select = 1;
plot(frequency_scale_mc, ...
    abs(spectra_mc{current_select, train_length_select, rf_select}).^2 ./ ...
    max(abs(spectra_mc{current_select, train_length_select, rf_select}).^2),'r',...
    frequency_scale_wi, wi_re ./maxy,'b','LineWidth',1)
xlabel('Frequency (GHz)')
ylabel('Normalised units')
xlim([0 graph_freq_lim])
ylim([0 1])
title(['Overlap of bunch spectra ^2 and wake impedance(current ', ...
    num2str(ppi.current(current_select)), 'mA Train length ', ...
    num2str(ppi.bt_length), ' RF ', num2str(ppi.rf_volts), 'MV'])
savemfmt(h_wake, pth,'wake_impedance_vs_bunch_spectrum')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy over time.
energy = extract_energy_results_from_wake_data(pp_data);
ax(33) = axes('Parent', h_wake);
if ~isnan(energy)
    minlim = energy(end,2);
    maxlim = max(energy(:,2));
    minxlim = energy(1,1);
    maxxlim = energy(end,1);
    if isnan(minlim) ==0
        if minlim >0
            semilogy(energy(:,1),energy(:,2),'b', 'LineWidth',lw)
            if isfield(wake_data.port_time_data, 'timebase') && isfield(wake_data.port_time_data, 'total_energy_cumsum')
                hold(ax(33), 'on')
                semilogy(timebase_port, squeeze(port_cumsum(:)) * 1e9,':k',...
                    'LineWidth',lw)
                legend('Energy decay', 'Energy at ports')
                hold(ax(33), 'off')
            end %if
            if minlim < maxlim
                ylim([minlim maxlim])
            end %if
            graph_add_horizontal_lines(y_lev_t)
            ylabel('Energy (nJ)')
        else
            plot(energy(:,1), energy(:,2),'LineWidth',lw)
            ylim([minlim 0])
            ylabel('Energy (relative)')
        end %if
    end %if
    xlim([minxlim maxxlim])
    title('Energy over time');
    xlabel('Time (ns)')
    for ies = 1:length(t_start)
        graph_add_background_patch(t_start(ies) * 1E9)
    end %for
end %if
savemfmt(h_wake, pth,'Energy')
if max(t_start) ~=0
    xlim([0 max(t_start) * 1E9 * 2])
end %if
savemfmt(h_wake, pth,'tstart_check')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=length(wake_sweep_data.frequency_domain_data):-1:1
    ws_wake_length(n) = wake_sweep_data.frequency_domain_data{n}.Wake_length;
    ws_wake_length_labels{n} = [num2str(wake_sweep_data.frequency_domain_data{n}.Wake_length), 'm'];
    ws_wlf(n) = wake_sweep_data.frequency_domain_data{n}.wlf;
    ws_Total_bunch_energy_loss(n) = wake_sweep_data.frequency_domain_data{n}.Total_bunch_energy_loss;
    ws_Total_energy_from_signal_ports(n) = wake_sweep_data.frequency_domain_data{n}.Total_energy_from_signal_ports;
    ws_Total_energy_from_beam_ports(n) = wake_sweep_data.frequency_domain_data{n}.Total_energy_from_beam_ports;
    ws_n_samples(n) = length(wake_sweep_data.frequency_domain_data{n}.f_raw);
    ws_frequency_scales{n} = wake_sweep_data.frequency_domain_data{n}.f_raw;
    ws_signal_port_spectrum(n,1:ws_n_samples(n)) = wake_sweep_data.frequency_domain_data{n}.signal_port_spectrum;
    ws_beam_port_spectrum(n,1:ws_n_samples(n)) = wake_sweep_data.frequency_domain_data{n}.beam_port_spectrum;
    ws_port_impedances(n,1:ws_n_samples(n), :) = wake_sweep_data.frequency_domain_data{n}.port_impedances;
    ws_Wake_Impedance(n,1:ws_n_samples(n)) = wake_sweep_data.frequency_domain_data{n}.Wake_Impedance_data;
end %for
plot(ws_wake_length, ws_wlf)
title('Wake loss factor')
xlabel('Wakelength (m)')
savemfmt(h_wake, pth,'wake_sweep_wlf')
clf(h_wake)

plot(ws_wake_length, ws_Total_energy_from_beam_ports)
title('Total energy from beam ports')
xlabel('Wakelength (m)')
savemfmt(h_wake, pth,'wake_sweep_energy_beam_ports')
clf(h_wake)

plot(ws_wake_length, ws_Total_energy_from_signal_ports)
title('Total energy from signal ports')
xlabel('Wakelength (m)')
savemfmt(h_wake, pth,'wake_sweep_energy_signal_ports')
clf(h_wake)

plot(ws_wake_length, ws_Total_bunch_energy_loss)
title('Total bunch energy loss')
xlabel('Wakelength (m)')
savemfmt(h_wake, pth,'wake_sweep_energy_losses')
clf(h_wake)

ax(35,1) = axes('Parent', h_wake, 'Position', [0.1, 0.6, 0.9, 0.2]);
ax(35,2) = axes('Parent', h_wake, 'Position', [0.1, 0.35, 0.9, 0.2]);
ax(35,3) = axes('Parent', h_wake, 'Position', [0.1, 0.1, 0.9, 0.2]);
hold(ax(35,1), 'on')
hold(ax(35,2), 'on')
hold(ax(35,3), 'on')
for nea = 1:length(wake_sweep_data.frequency_domain_data)
    plot(ax(35,1), ws_frequency_scales{nea}*1e-9, ws_signal_port_spectrum(nea,1:ws_n_samples(nea)))
    plot(ax(35,2), ws_frequency_scales{nea}*1e-9, ws_beam_port_spectrum(nea,1:ws_n_samples(nea)))
    plot(ax(35,3), ws_frequency_scales{nea}*1e-9, ws_Wake_Impedance(nea,1:ws_n_samples(nea)))
end %for
hold(ax(35,1), 'off')
hold(ax(35,2), 'off')
hold(ax(35,3), 'off')
ax(35,1).XTickLabel = [];
ax(35,2).XTickLabel = [];
ylim(ax(35,1), [0 Inf])
ylim(ax(35,2), [0 Inf])
ylim(ax(35,3), [0 Inf])
legend(ax(35,1), ws_wake_length_labels, 'Location', 'EastOutside')
title(ax(35,1), 'Signal port spectrum')
title(ax(35,2), 'Beam port spectrum')
title(ax(35,3), 'Wake Impedance')
xlabel(ax(35,3), 'Frequency (GHz)')
% find the new width of the top graph after adding the legend. Then apply
% it to the other graphs
ax(35,2).Position = [ax(35,2).Position(1) ax(35,2).Position(2) ax(35).Position(3) ax(35,2).Position(4)];
ax(35,3).Position = [ax(35,3).Position(1) ax(35,3).Position(2) ax(35).Position(3) ax(35,3).Position(4)];
savemfmt(h_wake, pth,'wake_sweep_spectra')
clf(h_wake)

for dhj = 1:length(port_names)
    subplot(ceil(length(port_names)/2),2,dhj)
        hold on
    for nne = 1:length(wake_sweep_data.frequency_domain_data)
        plot(ws_frequency_scales{nne}*1e-9, squeeze(ws_port_impedances(nne,1:ws_n_samples(nne),dhj)))
    end %for
    hold off
    xlabel('Frequency (GHz)')
    title(regexprep(pp_data.port.labels{dhj},'_', ' '));
end %for
savemfmt(h_wake, pth,'wake_sweep_port_impedance')
clf(h_wake)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking the cumsum scaling
if isfield(pp_data.port, 'timebase') &&...
        ~isnan(sum(wake_data.frequency_domain_data.Total_port_spectrum))
    ax(37) = axes('Parent', h_wake);
    data = wake_data.frequency_domain_data.Total_port_spectrum;
    plot(wake_data.frequency_domain_data.f_raw .*1e-9,cumsum(data)*1e9,':k')
    hold(ax(37), 'on')
    plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,...
        wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
        [wake_data.frequency_domain_data.Total_energy_from_ports .*1e9,...
        wake_data.frequency_domain_data.Total_energy_from_ports .*1e9],'r')
    plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,...
        wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
        [wake_data.port_time_data.total_energy .*1e9, ...
        wake_data.port_time_data.total_energy .*1e9],':g')
    plot([wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9,...
        wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9],...
        [0,...
        wake_data.frequency_domain_data.Total_energy_from_ports .*1e9],':c')
    hold(ax(37), 'off')
    % ylim([0 max(wake_data.frequency_domain_data.Total_energy_from_ports, wake_data.time_domain_data.loss_from_beam) .*1e9 .*1.1])
    xlabel('Frequency (GHz)')
    ylabel('Energy (nJ)')
    legend('cumsum', 'F domain max', 'T domain max','hfoi','Location','SouthEast')
    title('Sanity check for ports')
    savemfmt(h_wake, pth,'port_cumsum_check')
clf(h_wake)
end %if
%from beam
ax(38) = axes('Parent', h_wake);
plot(wake_data.frequency_domain_data.f_raw .*1e-9,cumsum(wake_data.frequency_domain_data.Bunch_loss_energy_spectrum)*1e9,':k','LineWidth',lw)
hold(ax(38), 'on')
plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
    [wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9, wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9],'r','LineWidth',lw)
plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
    [wake_data.time_domain_data.loss_from_beam .*1e9, wake_data.time_domain_data.loss_from_beam .*1e9],':g','LineWidth',lw)
plot([wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9,wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9],...
    [0, wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9],':c','LineWidth',lw)
hold(ax(38), 'off')
% ylim([0 max(wake_data.frequency_domain_data.Total_bunch_energy_loss, wake_data.time_domain_data.loss_from_beam) .*1e9 .*1.1])
xlabel('Frequency (GHz)')
ylabel('Energy (nJ)')
legend('cumsum', 'F domain max', 'T domain max','hfoi','Location','SouthEast')
title('Sanity check for beam loss')
savemfmt(h_wake, pth,'beam_cumsum_check')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking alignment of the input signals
ax(39) = axes('Parent', h_wake);
plot(pp_data.Wake_potential(:,1)* 1E9,pp_data.Wake_potential(:,2) ./ max(abs(pp_data.Wake_potential(:,2))),'b',...
    wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.wakepotential ./ max(abs(pp_data.Wake_potential(:,2))),'.c',...
    pp_data.Charge_distribution(:,1) * 1E9,pp_data.Charge_distribution(:,2) ./ max(pp_data.Charge_distribution(:,2)),'r',...
    wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.charge_distribution ./ max(wake_data.time_domain_data.charge_distribution),'.g',...
    'LineWidth',lw)
hold(ax(39), 'on')
[~,ind] =  max(pp_data.Wake_potential(:,2));
plot([pp_data.Wake_potential(ind,1) pp_data.Wake_potential(ind,1)], [-1.05 1.05], ':m','LineWidth',lw)
hold(ax(39), 'off')
xlim([-inf, 0.2])
ylim([-1.05 1.05])
xlabel('time (ns)')
ylabel('a.u.')
legend('Wake potential (raw)', 'Wake potential (pp)', 'Charge distrubution (raw)','Charge distribution (pp)','Location','SouthEast')
title('Alignment check')
savemfmt(h_wake, pth,'input_signal_alignment_check')
clf(h_wake)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(40) = axes('Parent', h_wake);
beg_ind = find(pp_data.Wake_potential(:,1) * 1e9 > -0.05, 1, 'first');
scaled_wp = pp_data.Wake_potential(:,2) ./ max(abs(pp_data.Wake_potential(:,2)));
scaled_wp_time = pp_data.Wake_potential(:,1)* 1E9;
scaled_cd = interp1(pp_data.Charge_distribution(:,1) .* 1E9, pp_data.Charge_distribution(:,2),scaled_wp_time);
[~ ,centre_ind] = min(abs(pp_data.Wake_potential(:,1) * 1e9));
span = centre_ind - beg_ind;
scaled_wp = scaled_wp(centre_ind - span:centre_ind + span);
scaled_wp_time = scaled_wp_time(centre_ind - span:centre_ind + span);
real_wp = scaled_wp + flipud(scaled_wp);
imag_wp = scaled_wp - flipud(scaled_wp);
scaled_cd = scaled_cd(centre_ind - span:centre_ind + span) ./ ...
    max(scaled_cd(centre_ind - span:centre_ind + span));
plot(scaled_wp_time,real_wp,'b',...
    scaled_wp_time,imag_wp,'m',...
    scaled_wp_time, scaled_cd,':r',...
    'LineWidth',lw, 'Parent', ax(40))
hold(ax(40), 'on')
[~,ind] =  max(pp_data.Wake_potential(:,2));
plot([pp_data.Wake_potential(ind,1) pp_data.Wake_potential(ind,1)], get(gca,'Ylim'), ':m')
hold(ax(40), 'off')
xlabel('time (ns)')
ylabel('a.u.')
title('Lossy and reactive signal')
legend('Real','Imaginary','Charge','Location','SouthEast')
savemfmt(h_wake, pth,'input_signal_lossy_reactive_check')
clf(h_wake)
close(h_wake)
