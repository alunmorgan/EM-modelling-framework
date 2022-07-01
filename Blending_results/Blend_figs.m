function Blend_figs(report_input)
% Take existing fig files and combines them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
%
%
% Example: Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2);

cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5],[0.5, 1, 0] };
l_st ={'-','--',':','-.','--',':','-.','--',':','-.'};

graph_metadata.swept_name = report_input.swept_name;
graph_metadata.output_loc = report_input.output_loc;

good_wake_data = zeros(length(report_input.sources),1);
for hse = 1:length(report_input.sources)
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_analysed_wake.mat'), 'file') == 2
        good_wake_data(hse) = 1;
    end %if
end %for
ck = 1;
for hse = length(good_wake_data):-1 :1
    if good_wake_data(hse) == 1
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_analysed_wake.mat'), 'pp_data');
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_from_run_logs.mat'), 'run_logs');
        np = 1;
        data_out(ck, np).ydata = pp_data.Wake_potential.s.data(:,2) * 1E-9;
        data_out(ck, np).xdata = pp_data.Wake_potential.s.data(:,1) * 1E9;
        data_out(ck, np).Ylab = 'Wake potential (mV/pC)';
        data_out(ck, np).Xlab = 'Time (ns)';
        data_out(ck, np).out_name = 'wake_potential';
        data_out(ck, np).linewidth = 2;
        data_out(ck, np).islog = 0;
        np = np + 1;
        data_out(ck, np).ydata = pp_data.Wake_impedance.s.data(:,2);
        data_out(ck, np).xdata = pp_data.Wake_impedance.s.data(:,1) * 1E-9;
        data_out(ck, np).Ylab = 'Real longitudinal wake impedance (\Omega)';
        data_out(ck, np).Xlab = 'Frequency (GHz)';
        data_out(ck, np).out_name = 'longitudinal_wake_impedance_real';
        data_out(ck, np).linewidth = 2;
        data_out(ck, np).islog = 0;
        np = np + 1;
        data_out(ck, np).ydata = pp_data.Wake_impedance_Im.s.data(:,2);
        data_out(ck, np).xdata = pp_data.Wake_impedance_Im.s.data(:,1) * 1E-9;
        data_out(ck, np).Ylab = 'Imaginary wake impedance (\Omega)';
        data_out(ck, np).Xlab = 'Frequency (GHz)';
        data_out(ck, np).out_name = 'longitudinal_wake_impedance_imaginary';
        data_out(ck, np).linewidth = 2;
        data_out(ck, np).islog = 0;
        np = np + 1;
        data_out(ck, np).ydata = cumsum(pp_data.Energy.data(:,2));
        data_out(ck, np).xdata = pp_data.Energy.data(:,1) * 1e9;
        data_out(ck, np).Ylab = 'Cumulative energy (J)';
        data_out(ck, np).Xlab = 'Time (ns)';
        data_out(ck, np).out_name = 'cumulative_total_energy';
        data_out(ck, np).linewidth = 2;
        data_out(ck, np).islog = 0;
        np = np + 1;
        data_out(ck, np).ydata = pp_data.Energy.data(:,2);
        data_out(ck, np).xdata = pp_data.Energy.data(:,1) * 1e9;
        data_out(ck, np).Ylab = 'Energy (J)';
        data_out(ck, np).Xlab = 'Time (ns)';
        data_out(ck, np).out_name = 'Energy';
        data_out(ck, np).linewidth = 2;
        data_out(ck, np).islog = 1;
        np = np + 1;
        if isfield(pp_data, 'mat_losses')
            data_out(ck, np).ydata = pp_data.mat_losses.total_loss * 1E9;
            data_out(ck, np).xdata = pp_data.mat_losses.loss_time * 1e9;
            data_out(ck, np).Ylab = 'Loss into materials (nJ)';
            data_out(ck, np).Xlab = 'Time (ns)';
            data_out(ck, np).out_name = 'Loss_into_materials';
            data_out(ck, np).linewidth = 2;
            data_out(ck, np).islog = 0;
            np = np + 1;
        end %if
        
        graph_metadata.sources(ck) = report_input.sources(hse);
        graph_metadata.swept_vals(ck) = report_input.swept_vals(hse);
        ck = ck +1;
    end %if
end %for
for egvn = 1:size(data_out,2)
    Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,egvn)), cols, l_st)
end
clear data_out
good_s_data = zeros(length(report_input.sources),1);
for hse = 1:length(report_input.sources)
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, 'sparameter', 'data_analysed_sparameter.mat'), 'file') == 2
        good_s_data(hse) = 1;
    end %if
end %for
ck = 1;
for hse = length(good_s_data):-1 :1
    if good_s_data(hse) == 1
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'sparameter', 'data_analysed_sparameter.mat'), 'sparameter_data');
        data_out(ck, :) = blend_s_param_data(sparameter_data);
        graph_metadata.sources(ck) = report_input.sources(hse);
        graph_metadata.swept_vals(ck) = report_input.swept_vals(hse);
        ck = ck +1;
    end %if
end %for
if sum(good_s_data) > 0
    for egvn = 1:size(data_out,2)
        Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,egvn)), cols, l_st)
    end %for
end %if