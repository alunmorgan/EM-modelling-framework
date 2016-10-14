function GdfidL_plot_wake(wake_data, ppi, mi, run_log,  pth, range)
% Generate the graphs based on the wake simulation data.
% Graphs are saved in fig format and png, eps.
% wake data is the simulation data.
% graph freq lim is the upper frequency cutoff used as the upper boundary
% in the frequency graphs.
% pth is where the resulting files are saved to.
% range is to do with peak identification for Q values, and
% is the separation peaks have to have to be counted as separate.
%
% Example GdfidL_plot_wake(wake_data, ppi, mi, run_log,  pth, range)

%Line width of the graphs
lw = 2;
% limit to the horizontal axis.
graph_freq_lim = ppi.hfoi * 1e-9;
% find the coresponding index.
cut_ind = find(wake_data.frequency_domain_data.f_raw*1E-9 < graph_freq_lim,1,'last');
% also find the index for 9GHz for zoomed graphs
power_dist_ind = find(wake_data.frequency_domain_data.f_raw > 9E9, 1,'First');

% location and size of the default figures.
fig_pos = [10000 678 560 420];

% Set the level vector to show the total energy loss on graphs (nJ).
y_lev = [wake_data.frequency_domain_data.Total_bunch_energy_loss *1e9,...
    wake_data.frequency_domain_data.Total_bunch_energy_loss * 1e9];

cut_off_freqs = wake_data.raw_data.port.frequency_cutoffs;
cut_off_freqs = cellfun(@(x) x*1e-9,cut_off_freqs, 'UniformOutput', false);

% setting up some style lists for the graphs.
cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[1, 0, 0.5],[0.5, 0, 1],[0.5, 1, 0] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};

% Identifying the non replica ports.
for sjew = length(wake_data.raw_data.port.labels_table):-1:1
    lab_ind(sjew) = find(strcmp(wake_data.raw_data.port.labels,...
        wake_data.raw_data.port.labels_table{sjew}));
end
% can I just do a search using the original names in raw data?

% Some pre processing to pull out trends.
[wl, freqs, Qs, mags, bws] = find_Q_trends(wake_data.frequency_domain_data.wake_sweeps, range);
% Show the Q values of the resonances shows if the simulation has stablised.
for ehw = size(freqs,1):-1:1
    Q_leg{ehw} = [num2str(round(freqs(ehw,1)./1e7)./1e2), 'GHz'];
end
% These are the plots to generate for a single value of sigma.
% sigma = round(str2num(mi.beam_sigma) ./3E8 *1E12 *10)/10;
if isfield(wake_data.raw_data.port, 'timebase')
    port_names = regexprep(wake_data.raw_data.port.labels,'_',' ');
end
if size(wake_data.frequency_domain_data.raw_port_energy_spectrum,2) == 2
    % assume that only beam ports are involved and set a flag so that the
    % signal port values are not displayed.
    bp_only_flag = 1;
else
    bp_only_flag = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Summary graph
report_generate_single_model_summary_graph(pth, ppi, mi,  ...
    wake_data, run_log, bp_only_flag);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal graphs
leg = {};
% make the array that the bar function understands.
% this is the total energy lossed from the beam.
py(1,1) = wake_data.frequency_domain_data.Total_bunch_energy_loss * 1e9;
py(2,1)=0;
% These are the places that energy has been recorded.
% assume beam ports are always there.
py(2,2) = wake_data.frequency_domain_data.Total_energy_from_beam_ports* 1e9;
py(1,2) =0;
leg{1} = ['Beam ports (',num2str(py(2,2)) ,'nJ)'];
if wake_data.frequency_domain_data.Total_energy_from_signal_ports >0
    % add signal ports if there is any signal.
    py(2,3) = wake_data.frequency_domain_data.Total_energy_from_signal_ports* 1e9;
    py(1,3) =0;
    leg{2} = ['Signal ports (',num2str(py(2,3)) ,'nJ)'];
end %if


pyl = size(py,2);
for ka = size(wake_data.raw_data.mat_losses.single_mat_data,1):-1:1
    py(1,pyl + ka) = 0;
    if isempty(wake_data.raw_data.mat_losses.single_mat_data{ka,4})
        py(2,pyl + ka) = 0;
        leg{pyl-1 + ka} = [wake_data.raw_data.mat_losses.single_mat_data{ka,2}, ' (0nJ)'];
    else
        py(2,pyl + ka) =  wake_data.raw_data.mat_losses.single_mat_data{ka,4}(end,2) .* 1E9;
        leg{pyl-1 + ka} = [wake_data.raw_data.mat_losses.single_mat_data{ka,2}, ' (',...
            num2str(wake_data.raw_data.mat_losses.single_mat_data{ka,4}(end,2).* 1E9),'nJ)'];
    end %if
end %for

h(1) = figure('Position',fig_pos);
ax(1) = axes('Parent', h(1));
f1 = bar(ax(1), py,'stacked');
% turn off the energy for the energy loss annotation
annot = get(f1, 'Annotation');
set(get(annot{1},'LegendInformation'),'IconDisplayStyle', 'off')
set(f1(1), 'FaceColor', [0.5 0.5 0.5]);
for eh = 2:size(py,2)
    set(f1(eh), 'FaceColor', cols{eh-1});
end
set(ax(1), 'XTickLabel',{'Energy lost from beam', 'Energy accounted for'})
ylabel('Energy from 1 pulse (nJ)')
legend(ax(1), leg, 'Location', 'EastOutside')
savemfmt(h(1), pth,'Thermal_Losses_within_the_structure')
close(h(1))
clear leg

h(2) = figure('Position',fig_pos);
ax(2) = axes('Parent', h(2));
if ~isempty(wake_data.raw_data.mat_losses.loss_time)
    for hsa = size(wake_data.raw_data.mat_losses.single_mat_data,1):-1:1
        tmp = strcmp(mi.extension_names, wake_data.raw_data.mat_losses.single_mat_data{hsa,2});
        if sum(tmp) == 0
            % material is part of the model.
            model_mat_index(hsa) = 1;
        else
            % material is part of the port extensions.
            model_mat_index(hsa) = 0;
        end %if
    end %for
    %select on only those materials which are in the model proper.
    model_mat_data = wake_data.raw_data.mat_losses.single_mat_data(model_mat_index == 1,:);
    if ~isempty(model_mat_data)
        for mes = size(model_mat_data,1):-1:1;
            mat_loss(mes) = model_mat_data{mes,4}(end,2);
        end %for
        plot_data = mat_loss/sum(mat_loss) *100;
        
        % add numerical value to label
        leg = {};
        for ena = length(plot_data):-1:1
            leg{ena} = strcat(model_mat_data{ena,2}, ' (',num2str(round(plot_data(ena)*100)/100),'%)');
        end %for
        % matlab will ignore any values of zero which messes up the maping of the
        % lables. This just makes any zero values a very small  positive value to avoid
        % this.
        plot_data(plot_data == 0) = 1e-12;
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
    end %if
end %if
title('Losses distribution within the structure', 'Parent', ax(2))
savemfmt(h(2), pth,'Thermal_Fractional_Losses_distribution_within_the_structure')
close(h(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(3) = figure('Position',fig_pos);
ax(3) = axes('Parent', h(3));
if isempty(wake_data.raw_data.mat_losses.loss_time) == 0
    leg = {};
    hold on
    for na = size(model_mat_data,1):-1:1
        if isempty(model_mat_data{na,4})
            m_time = 0;
            m_data = 0;
        else
            m_time = model_mat_data{na,4}(:,1).*1e9;
            m_data = model_mat_data{na,4}(:,2).* 1e9;
        end
        plot(ax(3), m_time ,m_data, 'Color', cols{na+col_ofst},'LineWidth',lw)
        leg{na} = model_mat_data{na,2};
    end
    hold off
    legend(ax(3), leg, 'Location', 'SouthEast')
end
xlabel(ax(3), 'Time (ns)')
ylabel(ax(3), 'Energy (nJ)')
title('Material loss over time', 'Parent', ax(3))
savemfmt(h(3), pth,'Material_loss_over_time')
close(h(3))
clear leg


if wake_data.port_time_data.total_energy ~=0
    t_step = wake_data.port_time_data.timebase(2) - wake_data.port_time_data.timebase(1);
    for jsff = length(wake_data.port_time_data.data):-1:1 % number of ports
        tmp = sum(wake_data.port_time_data.data{jsff},2);
        e_ports_cs(:,jsff) = cumsum(tmp.^2) * t_step;
    end
    e_total_cs = sum(e_ports_cs,2);
end

%% Cumulative total energy.
if isfield(wake_data.raw_data.port, 'timebase') && isfield(wake_data.port_time_data, 'total_energy_cumsum')
    h(4) = figure('Position',fig_pos);
    ax(4) = axes('Parent', h(4));
    plot(wake_data.port_time_data.timebase *1e9, e_total_cs * 1e9,'b','LineWidth',lw, 'Parent', ax(4))
    graph_add_horizontal_lines(y_lev)
    title('Cumulative Energy seen at all ports', 'Parent', ax(4))
    xlabel('Time (ns)', 'Parent', ax(4))
    ylabel('Cumulative Energy (nJ)', 'Parent', ax(4))
    xlim([0 wake_data.port_time_data.timebase(end) *1e9])
    text(wake_data.port_time_data.timebase(end) *1e9, y_lev(1), '100%')
    fr = (e_total_cs(end) *1e9/ y_lev(1)) *100;
    text(wake_data.port_time_data.timebase(end) *1e9, e_total_cs(end) * 1e9, [num2str(round(fr)),'%'])
    savemfmt(h(4), pth,'cumulative_total_energy')
    close(h(4))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Cumulative energy seen at each port.
    h(5) = figure('Position',fig_pos);
    ax(5) = axes('Parent', h(5));
    clk = 1;
    leg = cell(length(lab_ind),1);
    hold(ax(5), 'all')
    for ens = 1:length(lab_ind)
        plot(wake_data.port_time_data.timebase *1e9, e_ports_cs(:,lab_ind(ens)) * 1e9,...
            'Color',cols{ens},'LineWidth',lw, 'LineStyle', l_st{1}, 'Parent', ax(5))
        leg{clk} = port_names{lab_ind(ens)};
        clk = clk +1;
    end
    hold(ax(5), 'off')
    title('Cumulative energy seen at the ports (nJ)', 'Parent', ax(5))
    xlabel('Time (ns)', 'Parent', ax(5))
    ylabel('Cumulative Energy (nJ)', 'Parent', ax(5))
    xlim([wake_data.port_time_data.timebase(1) * 1e9 wake_data.port_time_data.timebase(end) * 1e9])
    legend(ax(5), regexprep(leg,'_',' '), 'Location', 'SouthEast')
    savemfmt(h(5), pth,'cumulative_energy')
    close(h(5))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake potential over time.
h(6) = figure('Position',fig_pos);
ax(6) = axes('Parent', h(6));
minxlim = wake_data.time_domain_data.timebase(1).*1E9;
maxxlim = wake_data.time_domain_data.timebase(end).*1E9;
hold(ax(6), 'all')
plot(wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.wakepotential * 1E-12,...
    'LineWidth',lw, 'Parent', ax(6))
minxlim = min([minxlim, wake_data.time_domain_data.timebase(1).*1E9]);
maxxlim = max([maxxlim, wake_data.time_domain_data.timebase(end).*1E9]);
title('Evolution of wake potential in the structure', 'Parent', ax(6))
xlabel('Time (ns)', 'Parent', ax(6))
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)', 'Parent', ax(6))
savemfmt(h(6), pth,'wake_potential')
close(h(6))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake impedance.
h(7) = figure('Position',fig_pos);
ax(7) = axes('Parent', h(7));
plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9, ...
    wake_data.frequency_domain_data.Wake_Impedance_data(1:cut_ind),...
    'b', 'Parent', ax(7));
title('Longditudinal real wake impedance', 'Parent', ax(7))
xlabel('Frequency (GHz)', 'Parent', ax(7))
ylabel('Impedance (Ohms)', 'Parent', ax(7))
xlim([0 graph_freq_lim])
savemfmt(h(7), pth,'longditudinal_real_wake_impedance')
close(h(7))

h(8) = figure('Position',fig_pos);
ax(8) = axes('Parent', h(8));
plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9, ...
    wake_data.frequency_domain_data.Wake_Impedance_data_im(1:cut_ind),...
    'b', 'Parent', ax(8));
title('Longditudinal imaginary wake impedance', 'Parent', ax(8))
xlabel('Frequency (GHz)', 'Parent', ax(8))
ylabel('Impedance (Ohms)', 'Parent', ax(8))
xlim([0 graph_freq_lim])
savemfmt(h(8), pth, 'longditudinal_imaginary_wake_impedance')
close(h(8))

%% Wake impedance.
h(9) = figure('Position',fig_pos);
ax(9) = axes('Parent', h(9));
plot(wake_data.raw_data.Wake_impedance_trans_X(:,1)*1E-9,...
    wake_data.raw_data.Wake_impedance_trans_X(:,2),...
    'b', 'Parent', ax(9));
title('Transverse X real wake impedance', 'Parent', ax(9))
xlabel('Frequency (GHz)', 'Parent', ax(9))
ylabel('Impedance (Ohms)', 'Parent', ax(9))
xlim([0 graph_freq_lim])
savemfmt(h(9), pth, 'Transverse_X_real_wake_impedance')
close(h(9))

%% Wake impedance.
h(10) = figure('Position',fig_pos);
ax(10) = axes('Parent', h(10));
plot(wake_data.raw_data.Wake_impedance_trans_Y(:,1)*1E-9,...
    wake_data.raw_data.Wake_impedance_trans_Y(:,2),...
    'b', 'Parent', ax(10));
title('Transverse Y real wake impedance', 'Parent', ax(10))
xlabel('Frequency (GHz)', 'Parent', ax(10))
ylabel('Impedance (Ohms)', 'Parent', ax(10))
xlim([0 graph_freq_lim])
savemfmt(h(10), pth,'Transverse_Y_real_wake_impedance')
close(h(10))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolating the wake loss factor for longer bunches.
comp = wake_data.frequency_domain_data.wlf * ...
    (wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time...
    ./(str2num(mi.beam_sigma)./3E8)).^(-3/2);
h(11) = figure('Position',fig_pos);
ax(11) = axes('Parent', h(11));
plot(wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time * 1e12,...
    wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.wlf * 1e-12,'b',...
    str2num(mi.beam_sigma)./3E8 *1E12, wake_data.frequency_domain_data.wlf * 1e-12,'*k',...
    wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time * 1e12,...
    comp * 1e-12, 'm',...
    'LineWidth',lw, 'Parent', ax(11))
xlabel('beam sigma (ps)', 'Parent', ax(11))
ylabel('Wake lossfactor (V/pC)', 'Parent', ax(11))
if sign(wake_data.frequency_domain_data.wlf) == 1
    ylim([0 1.1*wake_data.frequency_domain_data.wlf * 1e-12])
end
legend(ax(11), 'Calculated from data', 'Simulated beam size',  'Resistive wall (\sigma^{-3/2})')
title('Extrapolating wake loss factor for longer bunch lengths', 'Parent', ax(11))
savemfmt(h(11), pth, 'wake_loss_factor_extrapolation_bunch_length')
close(h(11))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolating the wake loss factor for longer trains.
h(12) = figure('Position',fig_pos);
ax(12) = axes('Parent', h(12));
for jes = size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss,3):-1:1
    loss_data = squeeze(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss(:,:,jes));
    tmp =loss_data';
    loss(jes,:) = tmp(:);
end
bar(loss', 'Parent', ax(12));
set(gca,'XTickLabel',['','','',''])
lims = ylim;
lim_ext = lims(2) - lims(1);
lab_loc = lims(1) - 0.05 * lim_ext;
cur_tick = 1;
bt_tick = 1;
for naw = 1:length(ppi.current) * length(ppi.bt_length)
    text(naw,lab_loc,...
        {[num2str(ppi.current(cur_tick)*1000),'mA']; [num2str(ppi.bt_length(bt_tick)),' bunches']},...
        'HorizontalAlignment','Center', 'Parent', ax(12))
    if cur_tick >= length(ppi.current)
        cur_tick = 1;
        bt_tick = bt_tick +1;
    else
        cur_tick = cur_tick +1;
    end
end
ylabel('Power loss (W)', 'Parent', ax(12))
title('Power loss from beam for different machine conditions', 'Parent', ax(12))
for rh = length(ppi.rf_volts):-1:1
    leg2{rh} = [num2str(ppi.rf_volts(1)),'MV RF'];
end
legend(ax(12), leg2, 'Location', 'NorthWest')
savemfmt(h(12), pth,'power_loss_for_different_machine_conditions')
close(h(12))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(wake_data.raw_data.port, 'timebase') && ~isnan(wake_data.frequency_domain_data.Total_energy_from_ports)
    structure_loss = wake_data.frequency_domain_data.Total_bunch_energy_loss...
        - wake_data.frequency_domain_data.Total_energy_from_ports;
    for ns = length(ppi.current):-1:1
        for eh = length(ppi.bt_length):-1:1
            single_bunch_losses(ns,eh) = ...
                structure_loss .*1e9./ run_log.charge .* ...
                (ppi.current(ns)./(ppi.RF_freq .*...
                ppi.bt_length(eh)/936));
        end
    end
    single_bunch_losses = single_bunch_losses(:,:)';
    h(13) = figure('Position',fig_pos);
    ax(13) = axes('Parent', h(13));
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
        end
    end
    ylabel('Power loss (W)', 'Parent', ax(13))
    title('Comparison of power loss with scaled single bunch and full spectral analysis', 'Parent', ax(13))
    legend(ax(13), 'Single bunch', 'Full analysis', 'Location', 'NorthWest')
    savemfmt(h(13), pth,'power_loss_for_analysis')
    close(h(13))
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Port signals
    if  isfield(wake_data.port_time_data, 'data')
        h(14) = figure('Position',fig_pos);
        [hwn, ksn] = num_subplots(length(lab_ind));
        for ens = length(lab_ind):-1:1 % ports
            ax_sp(ens) = subplot(hwn,ksn,ens);
            [~, max_mode] = max(squeeze(wake_data.port_time_data.port_mode_energy{lab_ind(ens)}(:)));
            plot(wake_data.port_time_data.timebase *1E9,...
                squeeze(wake_data.port_time_data.data{lab_ind(ens)}(:,max_mode)),...
                'b', 'Parent', ax_sp(ens))
            title([port_names{lab_ind(ens)}, ' (mode ',num2str(max_mode),')'], 'Parent', ax_sp(ens))
            xlim([wake_data.port_time_data.timebase(1) *1E9 wake_data.port_time_data.timebase(end) *1E9])
            xlabel('Time (ns)', 'Parent', ax_sp(ens))
            graph_add_background_patch(wake_data.raw_data.port.t_start(ens) * 1E9)
            ylabel('', 'Parent', ax_sp(ens))
        end
        savemfmt(h(14), pth,'dominant_port_signals')
        close(h(14))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        h(15) = figure('Position',fig_pos);
        ax(15) = axes('Parent', h(15));
        [hwn, ksn] = num_subplots(length(lab_ind));
        for ens = length(lab_ind):-1:1 % ports
            ax_sp2(ens) = subplot(hwn,ksn,ens);
            hold(ax_sp2(ens), 'all')
            for seo = 1:size(wake_data.port_time_data.data{lab_ind(ens)},2) % modes
                plot(wake_data.port_time_data.timebase *1E9,...
                    squeeze(wake_data.port_time_data.data{lab_ind(ens)}(:,seo)), 'Parent',ax_sp2(ens))
            end
            hold(ax_sp2(ens), 'off')
            title(port_names{lab_ind(ens)}, 'Parent', ax_sp2(ens))
            xlabel('Time (ns)', 'Parent', ax_sp2(ens))
            ylabel('', 'Parent', ax_sp2(ens))
            xlim([wake_data.port_time_data.timebase(1)*1e9 wake_data.port_time_data.timebase(end) * 1e9])
            graph_add_background_patch(wake_data.raw_data.port.t_start(ens) * 1E9)
        end
        savemfmt(h(15), pth,'port_signals')
        close(h(15))
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Comparison of bunch losses vs port signals on a per frequency basis.
x_axis = wake_data.frequency_domain_data.f_raw*1E-9;
if isfield(wake_data.raw_data.port, 'timebase') && ~isempty(cut_off_freqs)
    y_data = {(wake_data.frequency_domain_data.Bunch_loss_energy_spectrum)*1e9;...
        (wake_data.frequency_domain_data.Total_port_spectrum)*1e9};
else
    % set the second trace to zeros as there is no port energy.
    y_data = {(wake_data.frequency_domain_data.Bunch_loss_energy_spectrum)*1e9;...
        zeros(length(wake_data.frequency_domain_data.Bunch_loss_energy_spectrum),1)};
end
name = 'Energy loss distribution of bunch, and energy seen at ports';
cols = {'m','c'};
leg = {'Bunch loss', 'Port signal'};
% Combining all the port cutoff freqencies into one list.
cuts_temp = unique(cell2mat(cut_off_freqs));
cuts_temp = cuts_temp(cuts_temp > 1E-10);
report_plot_frequency_graphs(fig_pos, pth, y_lev, x_axis, y_data, ...
    cut_ind, power_dist_ind, cuts_temp, lw, name, graph_freq_lim, cols, leg)
clear leg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy left in the structure on a per frequency basis.
if isfield(wake_data.raw_data.port, 'timebase')
    if ~isempty(cut_off_freqs)
        power_diff = ((wake_data.frequency_domain_data.Bunch_loss_energy_spectrum) - (wake_data.frequency_domain_data.Total_port_spectrum)) * 1e9;
    else
        power_diff = (wake_data.frequency_domain_data.Bunch_loss_energy_spectrum) ;
    end
    report_plot_frequency_graphs(fig_pos, pth, y_lev,...
        x_axis, power_diff, cut_ind, power_dist_ind, cuts_temp,...
        lw, 'Energy left in structure', graph_freq_lim, 'b', [])
end

if wake_data.port_time_data.total_energy ~=0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% port signals on a per frequency basis for different port types.
    % assumes the beam ports are ports 1 and 2.
    % if isfield(wake_data.raw_data.port, 'timebase') && ~isnan(sum(wake_data.frequency_domain_data.signal_port_spectrum)) &&...
    %         ~isnan(sum(wake_data.frequency_domain_data.beam_port_spectrum))
    h(16) = figure('Position',fig_pos);
    ax(16) = axes('Parent', h(16));
    if bp_only_flag == 0
        plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
            (wake_data.frequency_domain_data.signal_port_spectrum(1:cut_ind))*1e9,'r',...
            wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
            (wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind))*1e9,'k','LineWidth',lw)
        graph_add_vertical_lines(cuts_temp)
        legend('Signal ports', 'Beam ports')
        title('Energy loss distribution')
        xlabel('Frequency (GHz)')
        ylabel('Energy (nJ) per ')
        xlim([0 graph_freq_lim])
    end
    savemfmt(h(16), pth,'Energy_loss_distribution')
    close(h(16))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h(17) = figure('Position',fig_pos);
    ax(17) = axes('Parent', h(17));
    % the factor of 2 comes from the fact that we need to sum across both sides
    % of the fft. As these are real signals both sides are mirror images of
    % each other so you can just cumsum up half the frequency range and
    % multiply by 2.
    if bp_only_flag == 0
        plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
            cumsum((wake_data.frequency_domain_data.signal_port_spectrum(1:cut_ind))*1e9) .*2,'r',...
            wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
            cumsum((wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind))*1e9).*2,'k','LineWidth',lw)
        graph_add_horizontal_lines(y_lev)
        graph_add_vertical_lines(cuts_temp)
        legend('Signal ports', 'Beam ports', 'Location','Best')
        title('Energy loss distribution')
        xlabel('Frequency (GHz)')
        ylabel('Cumlative sum of Energy (nJ)')
        xlim([0 graph_freq_lim])
    end
    savemfmt(h(17), pth,'cumulative_energy_loss_distribution')
    close(h(17))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h(18) = figure('Position',fig_pos);
    ax(18) = axes('Parent', h(18));
    fig_max = max(abs(wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind))*1e9);
    hold(ax(18), 'on')
    for ns = 1:length(lab_ind)
        plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
            wake_data.frequency_domain_data.raw_port_energy_spectrum(1:cut_ind,lab_ind(ns))*1e9,'LineWidth',lw)
    end
    hold(ax(18), 'off')
    graph_add_vertical_lines(cuts_temp)
    legend(port_names(lab_ind), 'Location','Best')
    xlim([0 graph_freq_lim])
    if ylim > 0 & ~isnan(ylim)
        ylim([0 fig_max .* 1.1])
    end
    graph_add_vertical_lines(cuts_temp)
    title('Energy loss distribution ports')
    xlabel('Frequency (GHz)')
    ylabel('Energy (nJ)')
    xlim([0 graph_freq_lim])
    savemfmt(h(18), pth,'energy_loss_port_types')
    xlim([0 wake_data.frequency_domain_data.f_raw(power_dist_ind)*1E-9])
    savemfmt(h(18), pth,'energy_loss_distribution_ports')
    close(h(18))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h(19) = figure('Position',fig_pos);
    ax(19) = axes('Parent', h(19));
    % the factor of 2 comes from the fact that we need to sum across both sides
    % of the fft. As these are real signals both sides are mirror images of
    % each other so you can just cumsum up half the frequency range and
    % multiply by 2.
    hold(ax(19), 'all')
    for ns = 1:length(lab_ind)
        plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
            cumsum((wake_data.frequency_domain_data.raw_port_energy_spectrum(1:cut_ind,lab_ind(ns)))*1e9).*2,'LineWidth',lw)
    end
    hold(ax(19), 'off')
    graph_add_vertical_lines(cuts_temp)
    legend( port_names(lab_ind), 'Location', 'NorthWest')
    xlim([0 graph_freq_lim])
    graph_add_vertical_lines(cuts_temp)
    title('Energy loss distribution beam ports')
    xlabel('Frequency (GHz)')
    ylabel('Cumlative sum of Energy (nJ)')
    xlim([0 graph_freq_lim])
    savemfmt(h(19), pth,'cumulative_energy_loss_port_types')
    xlim([0 wake_data.frequency_domain_data.f_raw(power_dist_ind)*1E-9])
    savemfmt(h(19), pth,'cumulative_energy_loss_distribution_ports')
    close(h(19))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Displaying some logfile information
lab = cell(1,1);
for naw = 1:size(cut_off_freqs,1)
    lab{naw} = ['Port ',num2str(naw)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cut off frequencies
h(20) = figure('Position',fig_pos);
ax(20) = axes('Parent', h(20));
hold(ax(20), 'on')
for sen = 1:length(cut_off_freqs)
    plot(cut_off_freqs{sen} .* 1e-9,'*')
end
hold(ax(20), 'off')
title('Cut off frequencies for different modes')
ylabel('cut off frequency (GHz)')
xlabel('port mode')
savemfmt(h(20), pth,'Cut_off_frequencies')
close(h(20))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(21) = figure('Position',fig_pos);
ax(21) = axes('Parent', h(21));
hold(ax(21), 'all')
for sen = 1:length(cut_off_freqs)
    plot(cut_off_freqs{sen} .* 1e-9,'*')
end
hold(ax(21), 'off')
title('Cut off frequencies for different modes')
ylabel('cut off frequency (GHz)')
xlabel('port mode')
ylim([0 graph_freq_lim])
savemfmt(h(21), pth,'Cut_off_frequencies_hfoi')
close(h(21))
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Q stability graphs
h(22) = figure('Position',fig_pos);
ax(22) = axes('Parent', h(22));
if isempty(Qs) == 0
    plot(wl,Qs, ':*','LineWidth',lw)
end
title('Change in Q over the sweep')
xlabel('Wake length (m)')
ylabel('Q')
if isempty(Qs) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(h(22), pth,'sweep_Q')
close(h(22))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(23) = figure('Position',fig_pos);
ax(23) = axes('Parent', h(23));
if isempty(mags) == 0
    plot(wl,mags, ':*','LineWidth',lw)
end
title('Change in peak magnitude over the sweep')
xlabel('Wake length (m)')
ylabel('Peak magnitude')
if isempty(mags) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(h(23), pth,'sweep_mag')
close(h(23))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(24) = figure('Position',fig_pos);
ax(24) = axes('Parent', h(24));
if isempty(bws) == 0
    plot(wl,bws, ':*','LineWidth',lw)
end
title('Change in bandwidth over the sweep')
xlabel('Wake length (m)')
ylabel('Bandwidth')
if isempty(bws) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(h(24), pth,'sweep_bw')
close(h(24))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(25) = figure('Position',fig_pos);
ax(25) = axes('Parent', h(25));
if isempty(freqs) == 0
    plot(wl,freqs * 1E-9, ':*','LineWidth',lw)
end
title('Change in peak frequency over the sweep')
xlabel('Wake length (mm)')
ylabel('Frequency (GHz)')
if isempty(freqs) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(h(25), pth,'sweep_freqs')
close(h(25))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time slice analysis.
h(26) = figure('Position',fig_pos);
ax(26) = axes('Parent', h(26));
imagesc(1:wake_data.frequency_domain_data.time_slices.n_slices,...
    wake_data.frequency_domain_data.time_slices.fscale*1e-9,log10(abs(wake_data.frequency_domain_data.time_slices.ffts)))
ylabel('Frequency(GHz)')
title('Block fft of wake potential')
xlabel('Time slices')
savemfmt(h(26), pth,'time_slices_blockfft')
close(h(26))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(27) = figure('Position',fig_pos);
ax(27) = axes('Parent', h(27));
plot(wake_data.frequency_domain_data.time_slices.fscale*1e-9,...
    abs(wake_data.frequency_domain_data.time_slices.ffts(:,end)))
legs = {'Data'};
hold(ax(27), 'off')
for mers = 1:size(wake_data.frequency_domain_data.time_slices.peaks,1)
    plot(wake_data.frequency_domain_data.time_slices.peaks(mers,1)*1e-9,...
        wake_data.frequency_domain_data.time_slices.peaks(mers,2),'*r','LineWidth',lw)
    legs{mers+1} = [num2str(round(wake_data.frequency_domain_data.time_slices.peaks(mers,1)*1e-9 .* 10)./10), ' GHz'];
end
hold(ax(27), 'off')
xlabel('Frequency (GHz)')
title('FFT of final time slice')
legend(legs)
savemfmt(h(27), pth,'time_slices_endfft')
close(h(27))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(28) = figure('Position',fig_pos);
ax(28) = axes('Parent', h(28));
legs = cell(size(wake_data.frequency_domain_data.time_slices.peaks,1),1);
for wana = 1:size(wake_data.frequency_domain_data.time_slices.peaks,1)
    if wana >1
        hold(ax(28), 'all')
    end
    f_ind = wake_data.frequency_domain_data.time_slices.fscale == wake_data.frequency_domain_data.time_slices.peaks(wana,1);
    %     f_ind = find(f_ind ==1)
    semilogy((abs(wake_data.frequency_domain_data.time_slices.ffts(f_ind,:))),'LineWidth',lw);
    %length of a time slice.
    lts = wake_data.frequency_domain_data.time_slices.slice_length * wake_data.frequency_domain_data.time_slices.timestep;
    x2 = 4* lts;
    y1 = log10(abs(wake_data.frequency_domain_data.time_slices.ffts(f_ind,end-4)));
    y2 = log10(abs(wake_data.frequency_domain_data.time_slices.ffts(f_ind,end)));
    m = (y2 - y1)./ x2;
    % this is eqivalent to -1/Tau.
    Q_graph =  - pi .* wake_data.frequency_domain_data.time_slices.peaks(wana,1) .* 1./m;
    legs{wana} = [num2str(round(wake_data.frequency_domain_data.time_slices.peaks(wana,1)*1e-9 .* 10)./10), ' GHz   :Q: ',num2str(round(Q_graph))];
    
end
hold(ax(28), 'off')
xlabel('Time slice')
ylabel('Magnitude (log scale)')
title('Trend of individual frequencies over time')
legend(legs)
savemfmt(h(28), pth,'time_slices_trend')
close(h(28))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show the energy in the port modes.
% This is to make sure that enough modes were used in the simulation.
if isfield(wake_data.raw_data.port, 'timebase') && ...
   isfield(wake_data.port_time_data, 'port_mode_energy')
    h(29) = figure('Position',fig_pos);
    ax(29) = axes('Parent', h(29));
    [hwn, ksn] = num_subplots(length(lab_ind));
    for ydh = 1:length(lab_ind) % Ports
        x_vals = linspace(1,length(wake_data.port_time_data.port_mode_energy{lab_ind(ydh)}),...
            length(wake_data.port_time_data.port_mode_energy{lab_ind(ydh)}));
        subplot(hwn,ksn,ydh)
        plot(x_vals, wake_data.port_time_data.port_mode_energy{lab_ind(ydh)},'LineWidth',lw);
        xlabel('mode number')
        title('Energy in port modes')
        ylabel('Energy (nJ)')
        title(port_names{lab_ind(ydh)})
    end
    savemfmt(h(29), pth,'energy_in_port_modes')
    close(h(29))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Showing the overlap of the bunch spectra and the wake impedance.
h(30) = figure('Position',fig_pos);
ax(30) = axes('Parent', h(30));
maxy = max(wake_data.frequency_domain_data.Wake_Impedance_data(1:cut_ind));
plot(wake_data.frequency_domain_data.f_raw*1E-9, ...
    (wake_data.frequency_domain_data.Wake_Impedance_data) ./maxy,'b',...
    wake_data.frequency_domain_data.f_raw*1E-9, ...
    abs((wake_data.frequency_domain_data.bunch_spectra).^2) ./ max(abs(wake_data.frequency_domain_data.bunch_spectra).^2),'r','LineWidth',lw)
title('Overlap of bunch spectra^2 and wake impedance')
xlabel('Frequency (GHz)')
ylabel('Normalised units')
xlim([0 graph_freq_lim])
ylim([0 1])
savemfmt(h(30), pth,'Overlap_of_bunch_spectra_and_wake_impedance')
close(h(30))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bunch spectra wake impedance overlap
% Make the figure twice the size as usual.
fig_pos_2 = fig_pos;
fig_pos_2(3) = 2*fig_pos_2(3);
fig_pos_2(4) = 2*fig_pos_2(4);
h(31) = figure('Position',fig_pos_2);
ax(31) = axes('Parent', h(31));
for sne = 1:size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_charge,1)
    for ena = 1:size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_charge,2)
        subplot(size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_charge,1),...
            size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_charge,2),...
            ena +(sne-1) * size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_charge,2))
        plot(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.f_raw*1E-9, ...
            abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{sne, ena,3}).^2 ./...
            max(abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{sne, ena,3}).^2),'r',...
            wake_data.frequency_domain_data.extrap_data.diff_machine_conds.f_raw*1E-9, ...
            abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{sne, ena,2}).^2 ./...
            max(abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{sne, ena,2}).^2),'g',...
            wake_data.frequency_domain_data.extrap_data.diff_machine_conds.f_raw*1E-9, ...
            abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{sne, ena,1}).^2 ./...
            max(abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{sne, ena,1}).^2),'k',...
            wake_data.frequency_domain_data.f_raw*1E-9, ...
            (wake_data.frequency_domain_data.Wake_Impedance_data) ./maxy,'b','LineWidth',1)
        title([num2str(ppi.current(sne)*1000), 'mA ' ,num2str(ppi.bt_length(ena)), ' bunches'])
        xlabel('Frequency (GHz)')
        %        ylabel('Normalised units')
        xlim([0 graph_freq_lim])
        ylim([0 1])
    end
end
axes('Position', [0 0 1 1])
set(gca,'Visible' ,'off')
text(0.05, 0.5, 'Normalised Units', 'Rotation',90,'HorizontalAlignment', 'center')
text(0.5,0.98, 'Overlap of bunch spectra ^2 and wake impedance','HorizontalAlignment', 'center')
text(0.95,0.5, '\color{black}{2.5MV}   \color{green}{3.5MV}   \color{red}{4.5MV}','Rotation',90,'HorizontalAlignment', 'center')
savemfmt(h(31), pth,'wake_impedance_vs_bunch_spectra')
close(h(31))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(32) = figure('Position',fig_pos);
ax(32) = axes('Parent', h(32));
plot(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.f_raw*1E-9, ...
    abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{2, 2, 1}).^2 ./...
    max(abs(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec{2, 2, 1}).^2),'r',...
    wake_data.frequency_domain_data.f_raw*1E-9, ...
    (wake_data.frequency_domain_data.Wake_Impedance_data) ./maxy,'b','LineWidth',1)
xlabel('Frequency (GHz)')
ylabel('Normalised units')
xlim([0 graph_freq_lim])
ylim([0 1])
title('Overlap of bunch spectra ^2 and wake impedance')
savemfmt(h(32), pth,'wake_impedance_vs_bunch_spectrum')
close(h(32))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy over time.
h(33) = figure('Position',fig_pos);
ax(33) = axes('Parent', h(33));
minlim = wake_data.raw_data.Energy(end,2)*1e9;
maxlim = max(wake_data.raw_data.Energy(:,2)*1e9);
minxlim = wake_data.raw_data.Energy(1,1).*1E9;
maxxlim = wake_data.raw_data.Energy(end,1).*1E9;
if isnan(minlim) ==0
    if minlim >0
        semilogy(wake_data.raw_data.Energy(:,1).*1E9,wake_data.raw_data.Energy(:,2)*1e9,'b', 'LineWidth',lw)
        if isfield(wake_data.port_time_data, 'timebase') && isfield(wake_data.port_time_data, 'total_energy_cumsum')
            hold(ax(33), 'on')
            semilogy(wake_data.port_time_data.timebase *1e9, squeeze(wake_data.port_time_data.total_energy_cumsum(:)) * 1e9,':k',...
                'LineWidth',lw)
            legend('Energy decay', 'Energy at ports')
            hold(ax(33), 'off')
        end
        if minlim < maxlim
            ylim([minlim maxlim])
        end
        graph_add_horizontal_lines(y_lev)
        ylabel('Energy (nJ)')
    else
        plot(wake_data.raw_data.Energy(:,1).*1E9,wake_data.raw_data.Energy(:,2)*1e9,'LineWidth',lw)
        ylim([minlim 0])
        ylabel('Energy (relative)')
    end
end
xlim([minxlim maxxlim])
title('Energy over time');
xlabel('Time (ns)')
for ies = 1:length(wake_data.raw_data.port.t_start)
    graph_add_background_patch(wake_data.raw_data.port.t_start(ies) * 1E9)
end
savemfmt(h(33), pth,'Energy')
if max(wake_data.raw_data.port.t_start) ~=0
    xlim([0 max(wake_data.raw_data.port.t_start) * 1E9 * 2])
end
savemfmt(h(33), pth,'tstart_check')
close(h(33))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking the cumsum scaling
if isfield(wake_data.raw_data.port, 'timebase') && ~isnan(sum(wake_data.frequency_domain_data.Total_port_spectrum))
    h(34) = figure('Position',fig_pos);
    ax(34) = axes('Parent', h(34));
    data = wake_data.frequency_domain_data.Total_port_spectrum;
    plot(wake_data.frequency_domain_data.f_raw .*1e-9,cumsum(data)*1e9,':k')
    hold(ax(34), 'on')
    plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
        [wake_data.frequency_domain_data.Total_energy_from_ports .*1e9, wake_data.frequency_domain_data.Total_energy_from_ports .*1e9],'r')
    plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
        [wake_data.port_time_data.total_energy .*1e9, wake_data.port_time_data.total_energy .*1e9],':g')
    plot([wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9,wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9],...
        [0, wake_data.frequency_domain_data.Total_energy_from_ports .*1e9],':c')
    hold(ax(34), 'off')
    % ylim([0 max(wake_data.frequency_domain_data.Total_energy_from_ports, wake_data.time_domain_data.loss_from_beam) .*1e9 .*1.1])
    xlabel('Frequency (GHz)')
    ylabel('Energy (nJ)')
    legend('cumsum', 'F domain max', 'T domain max','hfoi','Location','SouthEast')
    title('Sanity check for ports')
    savemfmt(h(34), pth,'port_cumsum_check')
    close(h(34))
end
%from beam
h(35) = figure('Position',fig_pos);
ax(35) = axes('Parent', h(35));
plot(wake_data.frequency_domain_data.f_raw .*1e-9,cumsum(wake_data.frequency_domain_data.Bunch_loss_energy_spectrum)*1e9,':k')
hold(ax(35), 'on')
plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
    [wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9, wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9],'r')
plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
    [wake_data.time_domain_data.loss_from_beam .*1e9, wake_data.time_domain_data.loss_from_beam .*1e9],':g')
plot([wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9,wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9],...
    [0, wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9],':c')
hold(ax(35), 'off')
% ylim([0 max(wake_data.frequency_domain_data.Total_bunch_energy_loss, wake_data.time_domain_data.loss_from_beam) .*1e9 .*1.1])
xlabel('Frequency (GHz)')
ylabel('Energy (nJ)')
legend('cumsum', 'F domain max', 'T domain max','hfoi','Location','SouthEast')
title('Sanity check for beam loss')
savemfmt(h(35), pth,'beam_cumsum_check')
close(h(35))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking alignment of the input signals
h(36) = figure('Position',fig_pos);
ax(36) = axes('Parent', h(36));
plot(wake_data.raw_data.Wake_potential(:,1)* 1E9,wake_data.raw_data.Wake_potential(:,2) ./ max(abs(wake_data.raw_data.Wake_potential(:,2))),'b',...
    wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.wakepotential ./ max(abs(wake_data.raw_data.Wake_potential(:,2))),'.c',...
    wake_data.raw_data.Charge_distribution(:,1) * 1E9,wake_data.raw_data.Charge_distribution(:,2) ./ max(wake_data.raw_data.Charge_distribution(:,2)),'r',...
    wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.charge_distribution ./ max(wake_data.time_domain_data.charge_distribution),'.g',...
    'LineWidth',lw)
hold(ax(36), 'on')
[~,ind] =  max(wake_data.raw_data.Wake_potential(:,2));
plot([wake_data.raw_data.Wake_potential(ind,1) wake_data.raw_data.Wake_potential(ind,1)], [-1.05 1.05], ':m')
hold(ax(36), 'off')
xlim([-inf, 0.2])
ylim([-1.05 1.05])
xlabel('time (ns)')
ylabel('a.u.')
title('Alignment check')
savemfmt(h(36), pth,'input_signal_alignment_check')
close(h(36))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(37) = figure('Position',fig_pos);
ax(37) = axes('Parent', h(37));
beg_ind = find(wake_data.raw_data.Wake_potential(:,1) * 1e9 > -0.05, 1, 'first');
scaled_wp = wake_data.raw_data.Wake_potential(:,2) ./ max(abs(wake_data.raw_data.Wake_potential(:,2)));
scaled_wp_time = wake_data.raw_data.Wake_potential(:,1)* 1E9;
scaled_cd = interp1(wake_data.raw_data.Charge_distribution(:,1) .* 1E9, wake_data.raw_data.Charge_distribution(:,2),scaled_wp_time);
[~ ,centre_ind] = min(abs(wake_data.raw_data.Wake_potential(:,1) * 1e9));
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
    'LineWidth',lw, 'Parent', ax(37))
hold(ax(37), 'on')
[~,ind] =  max(wake_data.raw_data.Wake_potential(:,2));
plot([wake_data.raw_data.Wake_potential(ind,1) wake_data.raw_data.Wake_potential(ind,1)], get(gca,'Ylim'), ':m')
hold(ax(37), 'off')
xlabel('time (ns)')
ylabel('a.u.')
title('Lossy and reactive signal')
legend('Real','Imaginary','Charge','Location','SouthEast')
savemfmt(h(37), pth,'input_signal_lossy_reactive_check')
close(h(37))

