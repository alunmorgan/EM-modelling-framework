function combined = latex_generate_wake_summary(wake_data, mi, ppi, run_log)

% Generates a summary table fo the results on loss.
%
% INPUTS
% wake_data: (structure) contains the results of teh wake simulation.
%
% Example: combined = latex_generate_wake_summary(wake_data)

% vals_sim = 'Simulated single bunch loss';
sb_Settings_list{1} = 'Bunch charge (nC)';
sb_Values_list{1} = num2str(round(run_log.charge *1E9));
sb_Settings_list{2} = 'Bunch length (ps)';
sb_Values_list{2} = num2str(round(str2num(mi.beam_sigma) ./3E8 * 1E12*10)/10);
sb_Settings_list{3} = 'Fraction lost down the beam pipe (\%)';
sb_Values_list{3} = [num2str(round(wake_data.frequency_domain_data.fractional_loss_beam_ports * 100)),'\%'];
sb_Settings_list{4} = 'Fraction lost into ports (\%)';
sb_Values_list{4} = [num2str(round(wake_data.frequency_domain_data.fractional_loss_signal_ports * 100)),'\%'];
sb_Settings_list{5} = 'Fraction lost into the structure (\%)';
if isfield(wake_data.raw_data, 'mat_losses')
    sb_Values_list{5} = [num2str(round(wake_data.raw_data.mat_losses.total_loss(end)/wake_data.frequency_domain_data.Total_bunch_energy_loss * 100)),'\%'];
else
    % no loss data so assume all is PEC
    sb_Values_list{5} = '0\%';
end %if
% preallocation
extrap_data =  wake_data.frequency_domain_data.extrap_data;
pl = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
vals = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
bc = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
bl = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
pl_bp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
pl_sp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
pl_st = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
fl_bp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
fl_sp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
fl_st = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
mc_wlf = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
for l1 = 1:length(ppi.current)
    for l2 = 1:length(ppi.bt_length)
        for l3 = 1:length(ppi.rf_volts)
            pl{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3)*10)/10);
            vals{l1,l2,l3} = [num2str(ppi.current(l1)*1e3), 'mA in ' num2str(ppi.bt_length(l2)), ' bunches'];
            bc{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.bunch_charge(l1,l2,l3) * 1e9*100)/100);
            bl{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.bunch_length(l1,l2,l3) *1E12*10)/10);
            mc_wlf{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.wlf(l1,l2,l3)* 1e-12*10)/10);
            if isfield(wake_data.raw_data.port, 'timebase')
                pl_bp{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3) * extrap_data.diff_machine_conds.loss_beam_pipe(l1,l2,l3) * 10)/10);
                pl_sp{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3) * extrap_data.diff_machine_conds.loss_signal_ports(l1,l2,l3) * 10)/10);
                pl_st{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3) * extrap_data.diff_machine_conds.loss_structure(l1,l2,l3) * 10) / 10);
                fl_bp{l1,l2,l3} = [num2str(round(extrap_data.diff_machine_conds.loss_beam_pipe(l1,l2,l3) .*100)),'%'];
                fl_sp{l1,l2,l3} = [num2str(round(extrap_data.diff_machine_conds.loss_signal_ports(l1,l2,l3) .*100)),'%'];
                fl_st{l1,l2,l3} = [num2str(round(extrap_data.diff_machine_conds.loss_structure(l1,l2,l3) .*100)),'%'];
            end
        end
    end
end


combined = cell(1,1);
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.3}');
[wlf_f, wlf_f_scale] = rescale_value(wake_data.frequency_domain_data.wlf * 1E-12,'');
[wlf_t, wlf_t_scale] = rescale_value(wake_data.time_domain_data.wake_loss_factor * 1E-12,'');
combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, '\begin{tabular}{|p{0.4\textwidth}|p{0.4\textwidth}|}');
combined = cat(1,combined, '\hline');
combined = cat(1,combined, ['Wakeloss factor (', wlf_t_scale, 'V/pC)', ' & Wakeloss factor (', wlf_f_scale, 'V/pC)','\\']);
combined = cat(1,combined, '\hline');
combined = cat(1,combined, ' From time analysis & From frequency analysis \\');
combined = cat(1,combined, '\hline');
    combined = cat(1,combined, [num2str(round(wlf_t*100)/100),' & ', num2str(round(wlf_f*100)/100), '\\' ]);
    combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, '\caption{Symetry settings}');
combined = cat(1,combined, '\end{table}');

combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, '\begin{tabular}{|p{0.16\textwidth}|p{0.16\textwidth}|p{0.16\textwidth}|p{0.16\textwidth}|p{0.16\textwidth}|}');
combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\multicolumn{5}{|c|}{\textbf{Single bunch loss distribution}}\\');
combined = cat(1,combined, '\hline');
sb_titles = sb_Settings_list{1};
sb_values = sb_Values_list{1};
for akw = 2:length(sb_Settings_list)
   sb_titles = [sb_titles, ' & ',  sb_Settings_list{akw}];
   sb_values = [sb_values, ' & ',  sb_Values_list{akw}];
end
combined = cat(1,combined, [sb_titles,' \\']);
combined = cat(1,combined, '\hline');
    combined = cat(1,combined, [sb_values, '\\' ]);
    combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, '\caption{Single bunch loss distribution}');
combined = cat(1,combined, '\end{table}');
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.0}');