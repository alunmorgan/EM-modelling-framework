function combined = latex_generate_loss_table_for_machine_conditions(extrap_data, ppi)


col_titles = {'Machine setup',...
    'Bunch charge (nC)',...
    'Bunch length (ps)',...
    'Power loss from beam (W)',...
    'Fraction lost down the beam pipe (\%)',...
    'Fraction lost into signal ports (\%)',...
    'Fraction lost into structure (\%)',...
    'Power lost down the beam pipe (W)',...
    'Power lost into ports (W)',...
    'Power lost into structure (W)'...
    };

clk = 0;
for cur_ind = 1:length(ppi.current)
    for bl_ind = 1:length(ppi.bt_length)
        for volts_ind = 1:length(ppi.rf_volts)
            clk = clk +1;
            pl{clk} = num2str(round(extrap_data.diff_machine_conds.power_loss(cur_ind,bl_ind,volts_ind)*10)/10);
            vals{clk} = [num2str(ppi.current(cur_ind)*1e3), 'mA in ' num2str(ppi.bt_length(bl_ind)), ' bunches, with ', num2str(ppi.rf_volts(volts_ind)), 'MV'];
            bc{clk} = num2str(round(extrap_data.diff_machine_conds.bunch_charge(cur_ind,bl_ind,volts_ind) * 1e9*100)/100);
            bl{clk} = num2str(round(extrap_data.diff_machine_conds.bunch_length(cur_ind,bl_ind,volts_ind) *1E12*10)/10);
            mc_wlf{clk} = num2str(round(extrap_data.diff_machine_conds.wlf(cur_ind,bl_ind,volts_ind)* 1e-12*10)/10);
            pl_sp{clk} = '';
            pl_bp{clk} = num2str(round(extrap_data.diff_machine_conds.power_loss(cur_ind,bl_ind,volts_ind) * extrap_data.diff_machine_conds.loss_beam_pipe(cur_ind,bl_ind,volts_ind) * 10)/10);
            pl_st{clk} = num2str(round(extrap_data.diff_machine_conds.power_loss(cur_ind,bl_ind,volts_ind) * extrap_data.diff_machine_conds.loss_structure(cur_ind,bl_ind,volts_ind) * 10) / 10);
            fl_bp{clk} = [num2str(round(extrap_data.diff_machine_conds.loss_beam_pipe(cur_ind,bl_ind,volts_ind) .*100)),'\%'];
            fl_st{clk} = [num2str(round(extrap_data.diff_machine_conds.loss_structure(cur_ind,bl_ind,volts_ind) .*100)),'\%'];
            fl_sp{clk} = '';
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
tab_setup = '\begin{tabular}{|p{0.32\textwidth}|';
for naw = 1:length(col_titles) - 1
    tab_setup = cat(2,tab_setup, 'p{0.05\textwidth}|');
end %for
tab_setup = cat(2,tab_setup, '}');
combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, tab_setup);
combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\multicolumn{10}{|c|}{\textbf{Losses vs machine parameters}}\\');
combined = cat(1,combined, '\hline');
ttls = col_titles{1};
for aje = 2:length(col_titles)
    ttls = cat(2, ttls, ' & ', col_titles{aje});
end %for
    ttls = cat(2, ttls, ' \\ ');
combined = cat(1,combined, ttls);
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



