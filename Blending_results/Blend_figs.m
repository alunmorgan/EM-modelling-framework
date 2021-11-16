function Blend_figs(report_input, chosen_wake_length, upper_frequency)
% Take existing fig files and combine them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
%
%
% Example: Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2);

cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5],[0.5, 1, 0] };
l_st ={'-','--',':','-.','--',':','-.','--',':','-.'};

graph_metadata.swept_name = report_input.swept_name;
graph_metadata.output_loc = report_input.output_loc;
if iscell(chosen_wake_length)
    chosen_wake_length = str2double(chosen_wake_length{1});
end %if
good_wake_data = zeros(length(report_input.sources),1);
for hse = 1:length(report_input.sources)
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_analysed_wake.mat'), 'file') == 2
        good_wake_data(hse) = 1;
    end %if
end %for
ck = 1;
for hse = length(good_wake_data):-1 :1
    if good_wake_data(hse) == 1
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_analysed_wake.mat'), 'wake_sweep_data');
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_from_run_logs.mat'), 'run_logs');
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake','data_postprocessed.mat'), 'pp_data');
        %         for nw = 1:length(wake_sweep_data.raw)
        %             wake_sweep_vals(nw) = wake_sweep_data.raw{1, nw}.wake_setup.Wake_length;
        %         end %for
        %         chosen_wake_ind = find(wake_sweep_vals == chosen_wake_length);
        %         if isempty(chosen_wake_ind)
        %             chosen_wake_ind = find(wake_sweep_vals == max(wake_sweep_vals));
        %             disp('Chosen wake length not found. Setting the wakelength to maximum value.')
        %         end %if
        chosen_wake_ind = 1; % Wake sweep has been disabled for now.
        
        f_upper_ind = find(wake_sweep_data.frequency_domain_data{chosen_wake_ind}.f_raw > upper_frequency,1 ,'first');
        data_out(ck, 1).ydata = wake_sweep_data.time_domain_data{chosen_wake_ind}.wakepotential * 1E-9;
        data_out(ck, 1).xdata = wake_sweep_data.time_domain_data{chosen_wake_ind}.timebase' * 1E9;
        data_out(ck, 1).Ylab = 'Wake potential (mV/pC)';
        data_out(ck, 1).Xlab = 'Time (ns)';
        data_out(ck, 1).out_name = 'wake_potential';
        data_out(ck, 1).linewidth = 2;
        data_out(ck, 1).islog = 0;
        data_out(ck, 2).ydata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.Wake_Impedance_data(1:f_upper_ind);
        data_out(ck, 2).xdata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.f_raw(1:f_upper_ind)' * 1E-9;
        data_out(ck, 2).Ylab = 'Real longitudinal wake impedance (\Omega)';
        data_out(ck, 2).Xlab = 'Frequency (GHz)';
        data_out(ck, 2).out_name = 'longitudinal_wake_impedance_real';
        data_out(ck, 2).linewidth = 2;
        data_out(ck, 2).islog = 0;
        data_out(ck, 3).ydata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.Wake_Impedance_data_im(1:f_upper_ind);
        data_out(ck, 3).xdata = wake_sweep_data.frequency_domain_data{chosen_wake_ind}.f_raw(1:f_upper_ind)' * 1E-9;
        data_out(ck, 3).Ylab = 'Imaginary wake impedance (\Omega)';
        data_out(ck, 3).Xlab = 'Frequency (GHz)';
        data_out(ck, 3).out_name = 'longitudinal_wake_impedance_imaginary';
        data_out(ck, 3).linewidth = 2;
        data_out(ck, 3).islog = 0;
        if isfield(pp_data, 'Energy')
            data_out(ck, 4).ydata = cumsum(pp_data.Energy(:,2));
            data_out(ck, 4).xdata = pp_data.Energy(:,1) * 1e9;
            
            data_out(ck, 4).Ylab = 'Cumulative energy (J)';
            data_out(ck, 4).Xlab = 'Time (ns)';
            data_out(ck, 4).out_name = 'cumulative_total_energy';
            data_out(ck, 4).linewidth = 2;
            data_out(ck, 4).islog = 0;
            data_out(ck, 5).ydata = pp_data.Energy(:,2);
            data_out(ck, 5).xdata = pp_data.Energy(:,1) * 1e9;
            
            data_out(ck, 5).Ylab = 'Energy (J)';
            data_out(ck, 5).Xlab = 'Time (ns)';
            data_out(ck, 5).out_name = 'Energy';
            data_out(ck, 5).linewidth = 2;
            data_out(ck, 5).islog = 1;
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
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, 's_parameter', 'data_postprocessed.mat'), 'file') == 2
        good_s_data(hse) = 1;
    end %if
end %for
ck = 1;
for hse = length(good_s_data):-1 :1
    if good_s_data(hse) == 1
        load(fullfile(report_input.source_path, report_input.sources{hse}, 's_parameter', 'data_postprocessed.mat'), 'pp_data');
        upper_ind = size(pp_data.scale{1,1},2) -2; % removing odd last point
        data_out(ck, 1).ydata = 20* log10(pp_data.data{1,3}(1,1:upper_ind));
        data_out(ck, 1).xdata = pp_data.scale{1,3}(1,1:upper_ind) * 1E-9;
        data_out(ck, 1).Ylab = 'S parameters (dB)';
        data_out(ck, 1).Xlab = 'Frequency (GHz)';
        data_out(ck, 1).out_name = 'S33';
        data_out(ck, 1).linewidth = 2;
        data_out(ck, 1).islog = 0;
        data_out(ck, 2).ydata = 20* log10(pp_data.data{2,4}(1,1:upper_ind));
        data_out(ck, 2).xdata = pp_data.scale{2,4}(1,1:upper_ind) * 1E-9;
        data_out(ck, 2).Ylab = 'S parameters (dB)';
        data_out(ck, 2).Xlab = 'Frequency (GHz)';
        data_out(ck, 2).out_name = 'S44';
        data_out(ck, 2).linewidth = 2;
        data_out(ck, 2).islog = 0;
        data_out(ck, 3).ydata = 20* log10(pp_data.data{1,4}(1,1:upper_ind));
        data_out(ck, 3).xdata = pp_data.scale{1,4}(1,1:upper_ind) * 1E-9;
        data_out(ck, 3).Ylab = 'S parameters (dB)';
        data_out(ck, 3).Xlab = 'Frequency (GHz)';
        data_out(ck, 3).out_name = 'S34';
        data_out(ck, 3).linewidth = 2;
        data_out(ck, 3).islog = 0;
        data_out(ck, 4).ydata = 20* log10(pp_data.data{2,3}(1,1:upper_ind));
        data_out(ck, 4).xdata = pp_data.scale{2,3}(1,1:upper_ind) * 1E-9;
        data_out(ck, 4).Ylab = 'S parameters (dB)';
        data_out(ck, 4).Xlab = 'Frequency (GHz)';
        data_out(ck, 4).out_name = 'S43';
        data_out(ck, 4).linewidth = 2;
        data_out(ck, 4).islog = 0;
        
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