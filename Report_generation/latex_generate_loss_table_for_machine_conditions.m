function combined = latex_generate_loss_table_for_machine_conditions(extrap_data, ppi)


% col_titles = {'Machine setup',...
%     'Bunch charge (pC)',...
%     'Bunch length (ps)',...
%     'Power loss from beam',...
%     'Fraction lost down the beam pipe (\%)',...
%     'Fraction lost into signal ports (\%)',...
%     'Fraction lost into structure (\%)',...
%     'Power lost down the beam pipe',...
%     'Power lost into ports (W)',...
%     'Power lost into structure'...
%     };

clk = 0;
for cur_ind = 1:length(ppi.current)
    for bl_ind = 1:length(ppi.bt_length)
        for volts_ind = 1:length(ppi.rf_volts)
            clk = clk +1;
            power_loss = extrap_data.diff_machine_conds.power_loss(cur_ind,bl_ind,volts_ind);
            beam_pipe_fraction = extrap_data.diff_machine_conds.loss_beam_pipe(cur_ind,bl_ind,volts_ind);
            structure_fraction = extrap_data.diff_machine_conds.loss_structure(cur_ind,bl_ind,volts_ind);
            signal_port_fraction = extrap_data.diff_machine_conds.loss_signal_ports(cur_ind,bl_ind,volts_ind);
            [pl_val, pl_scale] = rescale_value(power_loss,'');
            [pl_bp_val, pl_bp_scale] = rescale_value(power_loss * beam_pipe_fraction, '');
            [pl_st_val, pl_st_scale] = rescale_value(power_loss * structure_fraction,'');
            [pl_sp_val, pl_sp_scale] = rescale_value(power_loss * signal_port_fraction,'');
            
            pl{clk} = [num2str(round(pl_val*10)/10), pl_scale, 'W'];
            vals{clk} = [num2str(ppi.current(cur_ind)*1e3), 'mA, ', num2str(ppi.rf_volts(volts_ind)), 'MV, ' num2str(ppi.bt_length(bl_ind)), ' bunches'];
            bc{clk} = num2str(round(extrap_data.diff_machine_conds.bunch_charge(cur_ind,bl_ind,volts_ind) * 1e12*100)/100);
            bl{clk} = num2str(round(extrap_data.diff_machine_conds.bunch_length(cur_ind,bl_ind,volts_ind) *1E12*10)/10);
            mc_wlf{clk} = num2str(round(extrap_data.diff_machine_conds.wlf(cur_ind,bl_ind,volts_ind)* 1e-12*10)/10);
            pl_sp{clk} = [num2str(round(pl_sp_val * 10)/10), pl_sp_scale, 'W'];
            pl_bp{clk} = [num2str(round(pl_bp_val * 10)/10), pl_bp_scale, 'W'];
            pl_st{clk} = [num2str(round(pl_st_val* 10) / 10), pl_st_scale, 'W'];
            fl_bp{clk} = [num2str(round(beam_pipe_fraction .*100)),'\%'];
            fl_st{clk} = [num2str(round(structure_fraction .*100)),'\%'];
            fl_sp{clk} = [num2str(round(signal_port_fraction .*100)),'\%'];
        end %for
    end %for
end %for
if isfield(extrap_data.diff_machine_conds, 'loss_signal_ports')
    clk = 0;
    for cur_ind = 1:length(ppi.current)
        for bl_ind = 1:length(ppi.bt_length)
            for volts_ind = 1:length(ppi.rf_volts)
                clk = clk +1;
                pl_sp{clk} = num2str(round(extrap_data.diff_machine_conds.power_loss(cur_ind,bl_ind,volts_ind) * extrap_data.diff_machine_conds.loss_signal_ports(cur_ind,bl_ind,volts_ind) * 10)/10);
                fl_sp{clk} = [num2str(round(extrap_data.diff_machine_conds.loss_signal_ports(cur_ind,bl_ind,volts_ind) .*100)),'\%'];
                
            end %for
        end %for
    end %for
end %if

combined = cell(1,1);
combined = cat(1,combined, '\clearpage');
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.3}');
% tab_setup = '\begin{tabular}{|p{0.14\textwidth}|';
% for naw = 1:length(col_titles) - 1
%     tab_setup = cat(2,tab_setup, 'p{0.05\textwidth}|');
% end %for
% tab_setup = cat(2,tab_setup, '}');
combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, '\begin{tabular}{|p{0.16\textwidth}|p{0.05\textwidth}|p{0.05\textwidth}|p{0.08\textwidth}|p{0.055\textwidth}|p{0.055\textwidth}|p{0.07\textwidth}|p{0.08\textwidth}|p{0.08\textwidth}|p{0.08\textwidth}|}');
% combined = cat(1,combined, tab_setup);
combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\multicolumn{10}{|c|}{\textbf{Losses vs machine parameters}}\\');
combined = cat(1,combined, '\hline');
combined = cat(1,combined, 'Machine setup & \multirow{2}{0.05\textwidth}{Bunch charge (pC)} & \multirow{2}{0.05\textwidth}{Bunch length (ps)} & \multirow{2}{0.05\textwidth}{Power loss - beam} & \multicolumn{3}{|c|}{Fraction lost (\%)} & \multicolumn{3}{|c|}{Power lost} \\');
combined = cat(1,combined, '\cline{5 -10}');
combined = cat(1,combined, ' &  &  &  & beam pipe & signal ports & structure & beam pipe & signal ports & structure \\');
% ttls = col_titles{1};
% for aje = 2:length(col_titles)
%     ttls = cat(2, ttls, ' & ', col_titles{aje});
% end %for
%     ttls = cat(2, ttls, ' \\ ');
% combined = cat(1,combined, ttls);
combined = cat(1,combined, '\hline');
for enaw = 1:clk -1
    combined = cat(1,combined, [vals{enaw},' & ', bc{enaw},' & ',...
        bl{enaw},' & ', pl{enaw},' & ',...
        fl_bp{enaw},' & ', fl_sp{enaw},' & ', fl_st{enaw},' & ',...
        pl_bp{enaw},' & ', pl_sp{enaw},' & ', pl_st{enaw},...
        '\\' ]);
    combined = cat(1,combined, '\hline');
end %for
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, ['\caption{Losses vs machine parameters. ',...
    'The losses into the structure are infered from '...
    'the fraction of energy accounted for from emmission from the ports. '...
    'This will have a large error if the total energy accounted for in the '...
    'single bunch case is far from 100\%',...
    '}']);
combined = cat(1,combined, '\end{table}');

combined = cat(1,combined, '\renewcommand{\arraystretch}{1.0}');

combined = cat(1,combined,'$\sigma$ scaled using $(3.87 + 2.41 * I_b ^ {0.81}) * \sqrt{\frac{2.5MV}{V_{RF}}}$');



