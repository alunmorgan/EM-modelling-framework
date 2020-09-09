function Blend_figs(report_input, sub_folder , chosen_wake_length, frequency_display_range)
% Take existing fig files and combine them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
%
%
% Example: Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2);

cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5],[0.5, 1, 0] };
l_st ={'-','--',':','-.','--',':','-.','--',':','-.'};

chosen_wake_length = str2double(chosen_wake_length);
for hse = 1:length(report_input.sources)
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, sub_folder, 'data_analysed_wake.mat'), 'file') == 2
        good_data(hse) = 1;
    else
        good_data(hse) = 0;
    end %if
end %for
ck = 1;
graph_metadata.swept_name = report_input.swept_name;
graph_metadata.output_loc = report_input.output_loc;
for hse = length(good_data):-1 :1
    if good_data(hse) == 1
        load(fullfile(report_input.source_path, report_input.sources{hse}, sub_folder, 'data_analysed_wake.mat'), 'wake_sweep_data');
        for nw = 1:length(wake_sweep_data.raw)
            wake_sweep_vals(nw) = wake_sweep_data.raw{1, nw}.wake_setup.Wake_length;
        end %for
        chosen_wake_ind = find(wake_sweep_vals == chosen_wake_length);
        if isempty(chosen_wake_ind)
            chosen_wake_ind = find(wake_sweep_vals == max(wake_sweep_vals));
            warning('Chosen wake length not found. Setting the wakelength to maximum value.')
        end %if
        
        ind = find_data_end(wake_sweep_data.time_domain_data{chosen_wake_ind}.timebase', wake_sweep_vals(chosen_wake_ind));
        f_disp_ind = find(wake_sweep_data.frequency_domain_data{chosen_wake_ind}.f_raw > frequency_display_range, 1, 'first');
        
        data_out(ck, 1).ydata = wake_sweep_data.time_domain_data{chosen_wake_ind}.wakepotential(1:ind) * 1E-9;
        data_out(ck, 1).xdata = wake_sweep_data.time_domain_data{chosen_wake_ind}.timebase(1:ind)' * 1E9;
        data_out(ck, 1).Ylab = 'Wake potential (mV/pC)';
        data_out(ck, 1).Xlab = 'Time (ns)';
        data_out(ck, 1).out_name = 'wake_potential';
        data_out(ck, 1).linewidth = 2;
        data_out(ck, 1).islog = 0;
        data_out(ck, 2).ydata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.Wake_Impedance_data(1:f_disp_ind);
        data_out(ck, 2).xdata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.f_raw(1:f_disp_ind)' * 1E-9;
        data_out(ck, 2).Ylab = 'Real longitudinal wake impedance (\Omega)';
        data_out(ck, 2).Xlab = 'Frequency (GHz)';
        data_out(ck, 2).out_name = 'longitudinal_wake_impedance_real';
        data_out(ck, 2).linewidth = 2;
        data_out(ck, 2).islog = 0;
        data_out(ck, 3).ydata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.Wake_Impedance_data_im(1:f_disp_ind);
        data_out(ck, 3).xdata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.f_raw(1:f_disp_ind)' * 1E-9;
        data_out(ck, 3).Ylab = 'Imaginary wake impedance (\Omega)';
        data_out(ck, 3).Xlab = 'Frequency (GHz)';
        data_out(ck, 3).out_name = 'longitudinal_wake_impedance_imaginary';
        data_out(ck, 3).linewidth = 2;
        data_out(ck, 3).islog = 0;
        data_out(ck, 4).ydata = cumsum(wake_sweep_data.raw{chosen_wake_ind}.time_series_data.Energy(1:ind));
        data_out(ck, 4).xdata = wake_sweep_data.raw{chosen_wake_ind}.time_series_data.timescale_common(1:ind)' * 1e9;
        data_out(ck, 4).Ylab = 'Cumulative energy (J)';
        data_out(ck, 4).Xlab = 'Time (ns)';
        data_out(ck, 4).out_name = 'cumulative_total_energy';
        data_out(ck, 4).linewidth = 2;
        data_out(ck, 4).islog = 0;
        data_out(ck, 5).ydata = wake_sweep_data.raw{chosen_wake_ind}.time_series_data.Energy(1:ind);
        data_out(ck, 5).xdata = wake_sweep_data.raw{chosen_wake_ind}.time_series_data.timescale_common(1:ind)' * 1e9;
        data_out(ck, 5).Ylab = 'Energy (J)';
        data_out(ck, 5).Xlab = 'Time (ns)';
        data_out(ck, 5).out_name = 'Energy';
        data_out(ck, 5).linewidth = 2;
        data_out(ck, 5).islog = 1;
        graph_metadata.sources(ck) = report_input.sources(hse);
        graph_metadata.swept_vals(ck) = report_input.swept_vals(hse);
        ck = ck +1;
    end %if
end %for


%% Plot graphs
for egvn = 1:size(data_out,2)
    Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,egvn)), cols, l_st)
end %for

% Generate_2D_graph_showing_the_difference_to_the_first_trace(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)

% Generate_3D_graph_with_no_legend(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)