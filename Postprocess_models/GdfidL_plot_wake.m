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
for sjew = 1:length(wake_data.raw_data.port.labels_table)
    lab_ind(sjew) = find(strcmp(wake_data.raw_data.port.labels,...
                                wake_data.raw_data.port.labels_table{sjew}));
end
% can I just do a search using the original names in raw data?

% Some pre processing to pull out trends.
[wl, freqs, Qs, mags, bws] = find_Q_trends(wake_data.frequency_domain_data.wake_sweeps, range);
% Show the Q values of the resonances shows if the simulation has stablised.
for ehw = 1:size(freqs,1)
    Q_leg{ehw} = [num2str(round(freqs(ehw,1)./1e7)./1e2), 'GHz'];
end
% These are the plots to generate for a single value of sigma.
sigma = round(str2num(mi.beam_sigma) ./3E8 *1E12 *10)/10;
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
figure('Position',fig_pos)
figure_setup_bounding_box
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
end


pyl = size(py,2);
for ka = 1:size(wake_data.raw_data.mat_losses.single_mat_data,1)
    py(1,pyl + ka) = 0;
    if isempty(wake_data.raw_data.mat_losses.single_mat_data{ka,4})
        py(2,pyl + ka) = 0;
        leg{pyl-1 + ka} = [wake_data.raw_data.mat_losses.single_mat_data{ka,2}, ' (0nJ)'];
    else
        py(2,pyl + ka) =  wake_data.raw_data.mat_losses.single_mat_data{ka,4}(end,2) .* 1E9;
        leg{pyl-1 + ka} = [wake_data.raw_data.mat_losses.single_mat_data{ka,2}, ' (',...
            num2str(wake_data.raw_data.mat_losses.single_mat_data{ka,4}(end,2).* 1E9),'nJ)'];
    end
end
% end

f1 = bar(py,'stacked');
% turn off the energy for the energy loss annotation
annot = get(f1, 'Annotation');
set(get(annot{1},'LegendInformation'),'IconDisplayStyle', 'off')
set(f1(1), 'FaceColor', [0.5 0.5 0.5]);
for eh = 2:size(py,2)
    set(f1(eh), 'FaceColor', cols{eh-1});
end
set(gca, 'XTickLabel',{'Energy lost from beam', 'Energy accounted for'})
ylabel('Energy from 1 pulse (nJ)')
legend(leg, 'Location', 'EastOutside')
clear leg
savemfmt(pth,'Thermal_Losses_within_the_structure')
close(gcf)

figure('Position',fig_pos)
figure_setup_bounding_box
if ~isempty(wake_data.raw_data.mat_losses.loss_time)
    for hsa = 1:size(wake_data.raw_data.mat_losses.single_mat_data,1)
        tmp = strcmp(mi.extension_names, wake_data.raw_data.mat_losses.single_mat_data{hsa,2});
        if sum(tmp) == 0
            % material is part of the model.
            model_mat_index(hsa) = 1;
        else
            % material is part of the port extensions.
            model_mat_index(hsa) = 0;
        end
    end
    %select on only those materials which are in the model proper.
    model_mat_data = wake_data.raw_data.mat_losses.single_mat_data(model_mat_index == 1,:);
    if ~isempty(model_mat_data)
        for mes = 1:size(model_mat_data,1);
            mat_loss(mes) = model_mat_data{mes,4}(end,2);
        end
        plot_data = mat_loss/sum(mat_loss) *100;
        
        % add numerical value to label
        leg = {};
        for ena = 1:length(plot_data)
            leg{ena} = strcat(model_mat_data{ena,2}, ' (',num2str(round(plot_data(ena)*100)/100),'%)');
        end
        % matlab will ignore any values of zero which messes up the maping of the
        % lables. This just makes any zero values a very small  positive value to avoid
        % this.
        plot_data(plot_data == 0) = 1e-12;
        p = pie(plot_data, ones(length(plot_data),1));
        % setting the colours on the pie chart.
        pp = findobj(p, 'Type', 'patch');
        % check if both beam ports and signal ports are used.
        col_ofst = size(py,2) -1 - length(plot_data);
        for sh = 1:length(pp)
            set(pp(sh), 'FaceColor',cols{sh+col_ofst});
        end
        legend(leg,'Location','EastOutside', 'Interpreter', 'none')
        clear leg
    end
end
title('Losses distribution within the structure')
savemfmt(pth,'Thermal_Fractional_Losses_distribution_within_the_structure')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
if isempty(wake_data.raw_data.mat_losses.loss_time) == 0
    leg = {};
    hold on
    for na = 1:size(model_mat_data,1)
        if isempty(model_mat_data{na,4})
            m_time = 0;
            m_data = 0;
        else
            m_time = model_mat_data{na,4}(:,1).*1e9;
            m_data = model_mat_data{na,4}(:,2).* 1e9;
        end
        plot(m_time ,m_data, 'Color', cols{na+col_ofst},'LineWidth',lw)
        leg{na} = model_mat_data{na,2};
    end
    hold off
    legend(leg,'Location', 'SouthEast')
    clear leg
end
xlabel('Time (ns)')
ylabel('Energy (nJ)')
title('Material loss over time')
savemfmt(pth,'Material_loss_over_time')
close(gcf)
if wake_data.port_time_data.total_energy ~=0
t_step = wake_data.port_time_data.timebase(2) - wake_data.port_time_data.timebase(1);
for jsff = 1:length(wake_data.port_time_data.data) % number of ports
    tmp = sum(wake_data.port_time_data.data{jsff},2);
    e_ports_cs(:,jsff) = cumsum(tmp.^2) * t_step;
end
e_total_cs = sum(e_ports_cs,2);
end

%% Cumulative total energy.
if isfield(wake_data.raw_data.port, 'timebase') && isfield(wake_data.port_time_data, 'total_energy_cumsum')
    figure('Position',fig_pos)
    figure_setup_bounding_box
    
    plot(wake_data.port_time_data.timebase *1e9, e_total_cs * 1e9,'b','LineWidth',lw)
    graph_add_horizontal_lines(y_lev)
    title('Cumulative Energy seen at all ports')
    xlabel('Time (ns)')
    ylabel('Cumulative Energy (nJ)')
    xlim([0 wake_data.port_time_data.timebase(end) *1e9])
    text(wake_data.port_time_data.timebase(end) *1e9, y_lev(1), '100%')
    fr = (e_total_cs(end) *1e9/ y_lev(1)) *100;
    text(wake_data.port_time_data.timebase(end) *1e9, e_total_cs(end) * 1e9, [num2str(round(fr)),'%'])
    savemfmt(pth,'cumulative_total_energy')
    close(gcf)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Cumulative energy seen at each port.
    figure('Position',fig_pos)
    figure_setup_bounding_box
    clk = 1;
    leg = cell(length(lab_ind),1);
    for ens = 1:length(lab_ind)
        hold all
        plot(wake_data.port_time_data.timebase *1e9, e_ports_cs(:,lab_ind(ens)) * 1e9,...
            'Color',cols{ens},'LineWidth',lw, 'LineStyle', l_st{1})
        leg{clk} = port_names{lab_ind(ens)};
        clk = clk +1;
    end
    hold off
    title('Cumulative energy seen at the ports (nJ)')
    xlabel('Time (ns)')
    ylabel('Cumulative Energy (nJ)')
    xlim([wake_data.port_time_data.timebase(1) * 1e9 wake_data.port_time_data.timebase(end) * 1e9])
    legend(regexprep(leg,'_',' '), 'Location', 'SouthEast')
    savemfmt(pth,'cumulative_energy')
    close(gcf)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake potential over time.
figure('Position',fig_pos)
figure_setup_bounding_box
minxlim = wake_data.time_domain_data.timebase(1).*1E9;
maxxlim = wake_data.time_domain_data.timebase(end).*1E9;
hold all
% plot(wake_data.raw_data.Wake_potential(:,1) * 1E9,wake_data.raw_data.Wake_potential(:,2) * 1E-12,'LineWidth',lw)
plot(wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.wakepotential * 1E-12,'LineWidth',lw)
minxlim = min([minxlim, wake_data.time_domain_data.timebase(1).*1E9]);
maxxlim = max([maxxlim, wake_data.time_domain_data.timebase(end).*1E9]);
title('Evolution of wake potential in the structure')
xlabel('Time (ns)')
xlim([minxlim maxxlim])
ylabel('Wake potential (V/pC)')
savemfmt(pth,'wake_potential')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wake impedance.
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9, wake_data.frequency_domain_data.Wake_Impedance_data(1:cut_ind),'b');
title('Longditudinal real wake impedance')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
xlim([0 graph_freq_lim])
savemfmt(pth,'longditudinal_real_wake_impedance')
close(gcf)

figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9, wake_data.frequency_domain_data.Wake_Impedance_data_im(1:cut_ind),'b');
title('Longditudinal imaginary wake impedance')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
xlim([0 graph_freq_lim])
savemfmt(pth,'longditudinal_imaginary_wake_impedance')
close(gcf)

%% Wake impedance.
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.raw_data.Wake_impedance_trans_X(:,1)*1E-9, wake_data.raw_data.Wake_impedance_trans_X(:,2),'b');
% plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9, wake_data.frequency_domain_data.Wake_Impedance_trans_X(1:cut_ind),'b');
title('Transverse X real wake impedance')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
xlim([0 graph_freq_lim])
savemfmt(pth,'Transverse_X_real_wake_impedance')
close(gcf)

%% Wake impedance.
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.raw_data.Wake_impedance_trans_Y(:,1)*1E-9, wake_data.raw_data.Wake_impedance_trans_Y(:,2),'b');
% plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9, wake_data.frequency_domain_data.Wake_Impedance_trans_Y(1:cut_ind),'b');
title('Transverse Y real wake impedance')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
xlim([0 graph_freq_lim])
savemfmt(pth,'Transverse_Y_real_wake_impedance')
close(gcf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolating the wake loss factor for longer bunches.
comp = wake_data.frequency_domain_data.wlf * ...
    (wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time...
    ./(str2num(mi.beam_sigma)./3E8)).^(-3/2);
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time * 1e12,...
    wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.wlf * 1e-12,'b',...
    str2num(mi.beam_sigma)./3E8 *1E12, wake_data.frequency_domain_data.wlf * 1e-12,'*k',...
    wake_data.frequency_domain_data.extrap_data.beam_sigma_sweep.sig_time * 1e12,...
    comp * 1e-12, 'm',...
    'LineWidth',lw)
xlabel('beam sigma (ps)')
ylabel('Wake lossfactor (V/pC)')
if sign(wake_data.frequency_domain_data.wlf) == 1
    ylim([0 1.1*wake_data.frequency_domain_data.wlf * 1e-12])
end
legend('Calculated from data', 'Simulated beam size',  'Resistive wall (\sigma^{-3/2})')
title('Extrapolating wake loss factor for longer bunch lengths')
savemfmt(pth,'wake_loss_factor_extrapolation_bunch_length')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extrapolating the wake loss factor for longer trains.
figure('Position',fig_pos)
figure_setup_bounding_box
for jes = 1:size(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss,3)
loss_data = squeeze(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss(:,:,jes));
tmp =loss_data';
loss(jes,:) = tmp(:);
end
% loss1(1) = loss_data(1,1);
% loss1(2) = loss_data(1,2);
% loss1(3) = loss_data(2,1);
% loss1(4) = loss_data(2,2);
% loss_data = squeeze(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss(:,:,2));
% tmp =loss_data';loss2 = tmp(:);
% loss2(1) = loss_data(1,1);
% loss2(2) = loss_data(1,2);
% loss2(3) = loss_data(2,1);
% loss2(4) = loss_data(2,2);
% loss_data = squeeze(wake_data.frequency_domain_data.extrap_data.diff_machine_conds.power_loss(:,:,3));
% tmp =loss_data';loss3 = tmp(:);
% loss3(1) = loss_data(1,1);
% loss3(2) = loss_data(1,2);
% loss3(3) = loss_data(2,1);
% loss3(4) = loss_data(2,2);
% bar([loss1',loss2',loss3']);
bar(loss');
set(gca,'XTickLabel',['','','',''])
lims = ylim;
lim_ext = lims(2) - lims(1);
lab_loc = lims(1) - 0.05 * lim_ext;
cur_tick = 1;
bt_tick = 1;
for naw = 1:length(ppi.current) * length(ppi.bt_length)
    text(naw,lab_loc,{[num2str(ppi.current(cur_tick)*1000),'mA']; [num2str(ppi.bt_length(bt_tick)),' bunches']},'HorizontalAlignment','Center')
    if cur_tick >= length(ppi.current)
        cur_tick = 1;
        bt_tick = bt_tick +1;
    else
        cur_tick = cur_tick +1;
    end
end

% text(1,lab_loc,{[num2str(ppi.current(1)*1000),'mA']; [num2str(ppi.bt_length(1)),' bunches']},'HorizontalAlignment','Center')
% text(2,lab_loc,{[num2str(ppi.current(1)*1000),'mA']; [num2str(ppi.bt_length(2)),' bunches']},'HorizontalAlignment','Center')
% text(3,lab_loc,{[num2str(ppi.current(2)*1000),'mA']; [num2str(ppi.bt_length(1)),' bunches']},'HorizontalAlignment','Center')
% text(4,lab_loc,{[num2str(ppi.current(2)*1000),'mA']; [num2str(ppi.bt_length(2)),' bunches']},'HorizontalAlignment','Center')
ylabel('Power loss (W)')
title('Power loss from beam for different machine conditions')
for rh = 1:length(ppi.rf_volts)
leg2{rh} = [num2str(ppi.rf_volts(1)),'MV RF'];
end
legend(leg2, 'Location', 'NorthWest')
savemfmt(pth,'power_loss_for_different_machine_conditions')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(wake_data.raw_data.port, 'timebase') && ~isnan(wake_data.frequency_domain_data.Total_energy_from_ports)
    structure_loss = wake_data.frequency_domain_data.Total_bunch_energy_loss...
        - wake_data.frequency_domain_data.Total_energy_from_ports;
    for ns = 1:length(ppi.current)
        for eh = 1:length(ppi.bt_length)
            single_bunch_losses(ns,eh) = ...
                structure_loss .*1e9./ run_log.charge .* ...
                (ppi.current(ns)./(ppi.RF_freq .*...
                ppi.bt_length(eh)/936));
        end
    end
    single_bunch_losses = single_bunch_losses(:,:)';
    figure('Position',fig_pos)
    figure_setup_bounding_box
    bar([single_bunch_losses(:), loss(1,:)']);
    set(gca,'XTickLabel',['','','',''])
    cur_tick = 1;
    bt_tick = 1;
    for naw = 1:length(ppi.current) * length(ppi.bt_length)
        text(naw,lab_loc,{[num2str(ppi.current(cur_tick)*1000),'mA']; [num2str(ppi.bt_length(bt_tick)),' bunches']},'HorizontalAlignment','Center')
        if cur_tick >= length(ppi.current)
            cur_tick = 1;
            bt_tick = bt_tick +1;
        else
            cur_tick = cur_tick +1;
        end
    end
%     text(1,lab_loc,{[num2str(ppi.current(1)*1000),'mA']; [num2str(ppi.bt_length(1)),' bunches']},'HorizontalAlignment','Center')
%     text(2,lab_loc,{[num2str(ppi.current(1)*1000),'mA']; [num2str(ppi.bt_length(2)),' bunches']},'HorizontalAlignment','Center')
%     text(3,lab_loc,{[num2str(ppi.current(2)*1000),'mA']; [num2str(ppi.bt_length(1)),' bunches']},'HorizontalAlignment','Center')
%     text(4,lab_loc,{[num2str(ppi.current(2)*1000),'mA']; [num2str(ppi.bt_length(2)),' bunches']},'HorizontalAlignment','Center')
    ylabel('Power loss (W)')
    title('Comparison of power loss with scaled single bunch and full spectral analysis')
    legend('Single bunch', 'Full analysis', 'Location', 'NorthWest')
    savemfmt(pth,'power_loss_for_analysis')
    close(gcf)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Port signals
    if  isfield(wake_data.port_time_data, 'data')
        figure('Position',fig_pos)
        figure_setup_bounding_box
        [hwn, ksn] = num_subplots(length(lab_ind));
        for ens = 1:length(lab_ind) % ports
            subplot(hwn,ksn,ens)
            [~, max_mode] = max(squeeze(wake_data.port_time_data.port_mode_energy{lab_ind(ens)}(:)));
            plot(wake_data.port_time_data.timebase *1E9, squeeze(wake_data.port_time_data.data{lab_ind(ens)}(:,max_mode)),'b')
            title([port_names{lab_ind(ens)}, ' (mode ',num2str(max_mode),')'])
            xlim([wake_data.port_time_data.timebase(1) *1E9 wake_data.port_time_data.timebase(end) *1E9])
            xlabel('Time (ns)')
            graph_add_background_patch(wake_data.raw_data.port.t_start(ens) * 1E9)
            ylabel('')
        end
        savemfmt(pth,'dominant_port_signals')
        close(gcf)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure('Position',fig_pos)
        figure_setup_bounding_box
        [hwn, ksn] = num_subplots(length(lab_ind));
        for ens = 1:length(lab_ind) % ports
            subplot(hwn,ksn,ens)
            for seo = 1:size(wake_data.port_time_data.data{lab_ind(ens)},2) % modes
                hold all
                plot(wake_data.port_time_data.timebase *1E9,squeeze(wake_data.port_time_data.data{lab_ind(ens)}(:,seo)))
                hold off
            end
            title(port_names{lab_ind(ens)})
            xlabel('Time (ns)')
            ylabel('')
            xlim([wake_data.port_time_data.timebase(1)*1e9 wake_data.port_time_data.timebase(end) * 1e9])
            graph_add_background_patch(wake_data.raw_data.port.t_start(ens) * 1E9)
        end
        savemfmt(pth,'port_signals')
        close(gcf)
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
figure('Position',fig_pos)
figure_setup_bounding_box
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
savemfmt(pth,'Energy_loss_distribution')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
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
savemfmt(pth,'cumulative_energy_loss_distribution')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
fig_max = max(abs(wake_data.frequency_domain_data.beam_port_spectrum(1:cut_ind))*1e9);
hold all
for ns = 1:length(lab_ind)
    plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
        wake_data.frequency_domain_data.raw_port_energy_spectrum(1:cut_ind,lab_ind(ns))*1e9,'LineWidth',lw)
end
hold off
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
savemfmt(pth,'energy_loss_port_types')
xlim([0 wake_data.frequency_domain_data.f_raw(power_dist_ind)*1E-9])
savemfmt(pth,'energy_loss_distribution_ports')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
% the factor of 2 comes from the fact that we need to sum across both sides
% of the fft. As these are real signals both sides are mirror images of
% each other so you can just cumsum up half the frequency range and
% multiply by 2.
hold all
for ns = 1:length(lab_ind)
    plot(wake_data.frequency_domain_data.f_raw(1:cut_ind)*1E-9,...
        cumsum((wake_data.frequency_domain_data.raw_port_energy_spectrum(1:cut_ind,lab_ind(ns)))*1e9).*2,'LineWidth',lw)
end
hold off
graph_add_vertical_lines(cuts_temp)
legend( port_names(lab_ind), 'Location', 'NorthWest')
xlim([0 graph_freq_lim])
graph_add_vertical_lines(cuts_temp)
title('Energy loss distribution beam ports')
xlabel('Frequency (GHz)')
ylabel('Cumlative sum of Energy (nJ)')
xlim([0 graph_freq_lim])
savemfmt(pth,'cumulative_energy_loss_port_types')
xlim([0 wake_data.frequency_domain_data.f_raw(power_dist_ind)*1E-9])
savemfmt(pth,'cumulative_energy_loss_distribution_ports')
close(gcf)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Displaying some logfile information
lab = cell(1,1);
for naw = 1:size(cut_off_freqs,1)
    lab{naw} = ['Port ',num2str(naw)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cut off frequencies
figure('Position',fig_pos)
figure_setup_bounding_box
hold all
for sen = 1:length(cut_off_freqs)
    plot(cut_off_freqs{sen} .* 1e-9,'*')
end
hold off
title('Cut off frequencies for different modes')
ylabel('cut off frequency (GHz)')
xlabel('port mode')
savemfmt(pth,'Cut_off_frequencies')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
hold all
for sen = 1:length(cut_off_freqs)
    plot(cut_off_freqs{sen} .* 1e-9,'*')
end
hold off
title('Cut off frequencies for different modes')
ylabel('cut off frequency (GHz)')
xlabel('port mode')
ylim([0 graph_freq_lim])
savemfmt(pth,'Cut_off_frequencies_hfoi')
close(gcf)
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Q stability graphs
figure('Position',fig_pos)
figure_setup_bounding_box
if isempty(Qs) == 0
    plot(wl,Qs, ':*','LineWidth',lw)
end
title('Change in Q over the sweep')
xlabel('Wake length (m)')
ylabel('Q')
if isempty(Qs) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(pth,'sweep_Q')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
if isempty(mags) == 0
    plot(wl,mags, ':*','LineWidth',lw)
end
title('Change in peak magnitude over the sweep')
xlabel('Wake length (m)')
ylabel('Peak magnitude')
if isempty(mags) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(pth,'sweep_mag')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
if isempty(bws) == 0
    plot(wl,bws, ':*','LineWidth',lw)
end
title('Change in bandwidth over the sweep')
xlabel('Wake length (m)')
ylabel('Bandwidth')
if isempty(bws) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(pth,'sweep_bw')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
if isempty(freqs) == 0
    plot(wl,freqs * 1E-9, ':*','LineWidth',lw)
end
title('Change in peak frequency over the sweep')
xlabel('Wake length (mm)')
ylabel('Frequency (GHz)')
if isempty(freqs) == 0
    legend(Q_leg, 'Location', 'EastOutside')
end
savemfmt(pth,'sweep_freqs')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time slice analysis.
figure('Position',fig_pos)
figure_setup_bounding_box
imagesc(1:wake_data.frequency_domain_data.time_slices.n_slices,...
    wake_data.frequency_domain_data.time_slices.fscale*1e-9,log10(abs(wake_data.frequency_domain_data.time_slices.ffts)))
ylabel('Frequency(GHz)')
title('Block fft of wake potential')
xlabel('Time slices')
savemfmt(pth,'time_slices_blockfft')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.frequency_domain_data.time_slices.fscale*1e-9,...
    abs(wake_data.frequency_domain_data.time_slices.ffts(:,end)))
legs = {'Data'};
hold on
for mers = 1:size(wake_data.frequency_domain_data.time_slices.peaks,1)
    plot(wake_data.frequency_domain_data.time_slices.peaks(mers,1)*1e-9,...
        wake_data.frequency_domain_data.time_slices.peaks(mers,2),'*r','LineWidth',lw)
    legs{end+1} = [num2str(round(wake_data.frequency_domain_data.time_slices.peaks(mers,1)*1e-9 .* 10)./10), ' GHz'];
end
hold off
xlabel('Frequency (GHz)')
title('FFT of final time slice')
legend(legs)
savemfmt(pth,'time_slices_endfft')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
legs = cell(size(wake_data.frequency_domain_data.time_slices.peaks,1),1);
for wana = 1:size(wake_data.frequency_domain_data.time_slices.peaks,1)
    if wana >1
        hold all
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
hold off
xlabel('Time slice')
ylabel('Magnitude (log scale)')
title('Trend of individual frequencies over time')
legend(legs)
savemfmt(pth,'time_slices_trend')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Show the energy in the port modes.
% This is to make sure that enough modes were used in the simulation.
if isfield(wake_data.raw_data.port, 'timebase') && isfield(wake_data.port_time_data, 'port_mode_energy')
    figure('Position',fig_pos)
    figure_setup_bounding_box
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
    savemfmt(pth,'energy_in_port_modes')
    close(gcf)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Showing the overlap of the bunch spectra and the wake impedance.
figure('Position',fig_pos)
figure_setup_bounding_box
maxy = max(wake_data.frequency_domain_data.Wake_Impedance_data(1:cut_ind));
plot(wake_data.frequency_domain_data.f_raw*1E-9, ...
    (wake_data.frequency_domain_data.Wake_Impedance_data) ./maxy,'b',...
    wake_data.frequency_domain_data.f_raw*1E-9, ...
    abs((wake_data.frequency_domain_data.bunch_spectra).^2) ./ max(abs(wake_data.frequency_domain_data.bunch_spectra).^2),'r','LineWidth',lw)
title('Overlap of bunch spectra ^2 and wake impedance')
xlabel('Frequency (GHz)')
ylabel('Normalised units')
xlim([0 graph_freq_lim])
ylim([0 1])
savemfmt(pth,'Overlap_of_bunch_spectra_and_wake_impedance')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bunch spectra wake impedance overlap
% Make the figure twice a wide as usual.
fig_pos_2 = fig_pos;
fig_pos_2(3) = 2*fig_pos_2(3);
figure('Position',fig_pos_2)
figure_setup_bounding_box
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
        ylabel('Normalised units')
        xlim([0 graph_freq_lim])
        ylim([0 1])
    end
end
axes('Position', [0 0 1 1])
set(gca,'Visible' ,'off')
text(0.5,0.98, 'Overlap of bunch spectra ^2 and wake impedance','HorizontalAlignment', 'center')
text(0.95,0.5, '\color{black}{2.5MV}   \color{green}{3.5MV}   \color{red}{4.5MV}','Rotation',90,'HorizontalAlignment', 'center')
savemfmt(pth,'wake_impedance_vs_bunch_spectra')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
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
savemfmt(pth,'wake_impedance_vs_bunch_spectrum')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy over time.
figure('Position',fig_pos)
figure_setup_bounding_box
minlim = wake_data.raw_data.Energy(end,2)*1e9;
maxlim = max(wake_data.raw_data.Energy(:,2)*1e9);
minxlim = wake_data.raw_data.Energy(1,1).*1E9;
maxxlim = wake_data.raw_data.Energy(end,1).*1E9;
if isnan(minlim) ==0
    if minlim >0
        semilogy(wake_data.raw_data.Energy(:,1).*1E9,wake_data.raw_data.Energy(:,2)*1e9,'b', 'LineWidth',lw)
        if isfield(wake_data.port_time_data, 'timebase') && isfield(wake_data.port_time_data, 'total_energy_cumsum')
            hold on
            semilogy(wake_data.port_time_data.timebase *1e9, squeeze(wake_data.port_time_data.total_energy_cumsum(:)) * 1e9,':k',...
                'LineWidth',lw)
            legend('Energy decay', 'Energy at ports')
            hold off
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
savemfmt(pth,'Energy')
if max(wake_data.raw_data.port.t_start) ~=0
    xlim([0 max(wake_data.raw_data.port.t_start) * 1E9 * 2])
end
savemfmt(pth,'tstart_check')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking the cumsum scaling
if isfield(wake_data.raw_data.port, 'timebase') && ~isnan(sum(wake_data.frequency_domain_data.Total_port_spectrum))
    figure('Position',fig_pos)
    figure_setup_bounding_box
    data = wake_data.frequency_domain_data.Total_port_spectrum;
    plot(wake_data.frequency_domain_data.f_raw .*1e-9,cumsum(data)*1e9,':k')
    hold on
    plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
        [wake_data.frequency_domain_data.Total_energy_from_ports .*1e9, wake_data.frequency_domain_data.Total_energy_from_ports .*1e9],'r')
    plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
        [wake_data.port_time_data.total_energy .*1e9, wake_data.port_time_data.total_energy .*1e9],':g')
    plot([wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9,wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9],...
        [0, wake_data.frequency_domain_data.Total_energy_from_ports .*1e9],':c')
    hold off
    % ylim([0 max(wake_data.frequency_domain_data.Total_energy_from_ports, wake_data.time_domain_data.loss_from_beam) .*1e9 .*1.1])
    xlabel('Frequency (GHz)')
    ylabel('Energy (nJ)')
    legend('cumsum', 'F domain max', 'T domain max','hfoi','Location','SouthEast')
    title('Sanity check for ports')
    savemfmt(pth,'port_cumsum_check')
    close(gcf)
end
%from beam
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.frequency_domain_data.f_raw .*1e-9,cumsum(wake_data.frequency_domain_data.Bunch_loss_energy_spectrum)*1e9,':k')
hold on
plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
    [wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9, wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9],'r')
plot([wake_data.frequency_domain_data.f_raw(1) .*1e-9,wake_data.frequency_domain_data.f_raw(end) .*1e-9],...
    [wake_data.time_domain_data.loss_from_beam .*1e9, wake_data.time_domain_data.loss_from_beam .*1e9],':g')
plot([wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9,wake_data.frequency_domain_data.f_raw(floor(end/2)) .*1e-9],...
    [0, wake_data.frequency_domain_data.Total_bunch_energy_loss .*1e9],':c')
hold off
% ylim([0 max(wake_data.frequency_domain_data.Total_bunch_energy_loss, wake_data.time_domain_data.loss_from_beam) .*1e9 .*1.1])
xlabel('Frequency (GHz)')
ylabel('Energy (nJ)')
legend('cumsum', 'F domain max', 'T domain max','hfoi','Location','SouthEast')
title('Sanity check for beam loss')
savemfmt(pth,'beam_cumsum_check')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checking alignment of the input signals
figure('Position',fig_pos)
figure_setup_bounding_box
plot(wake_data.raw_data.Wake_potential(:,1)* 1E9,wake_data.raw_data.Wake_potential(:,2) ./ max(abs(wake_data.raw_data.Wake_potential(:,2))),'b',...
    wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.wakepotential ./ max(abs(wake_data.raw_data.Wake_potential(:,2))),'.c',...
    wake_data.raw_data.Charge_distribution(:,1) * 1E9,wake_data.raw_data.Charge_distribution(:,2) ./ max(wake_data.raw_data.Charge_distribution(:,2)),'r',...
    wake_data.time_domain_data.timebase * 1E9,wake_data.time_domain_data.charge_distribution ./ max(wake_data.time_domain_data.charge_distribution),'.g',...
    'LineWidth',lw)
hold on
[~,ind] =  max(wake_data.raw_data.Wake_potential(:,2));
plot([wake_data.raw_data.Wake_potential(ind,1) wake_data.raw_data.Wake_potential(ind,1)], [-1.05 1.05], ':m')
hold off
xlim([-inf, 0.2])
ylim([-1.05 1.05])
xlabel('time (ns)')
ylabel('a.u.')
title('Alignment check')
savemfmt(pth,'input_signal_alignment_check')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Position',fig_pos)
figure_setup_bounding_box
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
    'LineWidth',lw)
hold on
[~,ind] =  max(wake_data.raw_data.Wake_potential(:,2));
plot([wake_data.raw_data.Wake_potential(ind,1) wake_data.raw_data.Wake_potential(ind,1)], get(gca,'Ylim'), ':m')
hold off
xlabel('time (ns)')
ylabel('a.u.')
title('Lossy and reactive signal')
legend('Real','Imaginary','Charge','Location','SouthEast')
savemfmt(pth,'input_signal_lossy_reactive_check')
close(gcf)

