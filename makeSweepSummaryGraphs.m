function makeSweepSummaryGraphs(valsX, dataInds, base_val, base_ind, extracted_data, model_set, xunit, sweep_name, root)

h = figure(983);
plot_sweep(h, valsX, round(extracted_data.wlf(dataInds) .* 1E-9), ...
    base_val, round(extracted_data.wlf(base_ind) .* 1E-9), ...
    [sweep_name, ' (' , xunit, ')'] , 'Wake loss factor (mV/pC)');
savemfmt(h, fullfile(root, model_set), [model_set, '_', sweep_name, '_wlf_sweep'])
plot_sweep(h, valsX, extracted_data.beam_port_loss(dataInds) * 100, ...
    base_val, extracted_data.beam_port_loss(base_ind) * 100, ...
    [sweep_name, ' (' , xunit, ')'] , 'Beam port loss (%)');
savemfmt(h, fullfile(root, model_set), [model_set, '_', sweep_name, '_bpl_sweep'])
plot_sweep(h, valsX, extracted_data.signal_port_loss(dataInds) * 100, ...
    base_val, extracted_data.signal_port_loss(base_ind) * 100, ...
    [sweep_name, ' (' , xunit, ')'] , 'Signal port loss (%)');
savemfmt(h, fullfile(root, model_set), [model_set, '_', sweep_name, '_spl_sweep'])
plot_sweep(h, valsX, extracted_data.structure_loss(dataInds) * 100, ...
    base_val, extracted_data.structure_loss(base_ind) * 100, ...
    [sweep_name, ' (' , xunit, ')'] , 'Structure loss (%)');
savemfmt(h, fullfile(root, model_set), [model_set, '_', sweep_name, '_sl_sweep'])
close(h)
end %function

function plot_sweep(h, dataX, dataY, baseX, baseY, Xlab, Ylab)

clf(h)
plot(dataX, dataY, ':.k', baseX, baseY, '*r')
xlabel(regexprep(Xlab, '_', ' '))
ylabel(regexprep(Ylab, '_', ' '))
end %function

