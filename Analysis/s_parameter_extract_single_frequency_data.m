function s_parameter_extract_single_frequency_data(report_input, requested_frequencies)

top_of_range = [750E6, 5e9];
for kds = 1:length(top_of_range)
    for jef = 1:length(report_input.sources)
        load(fullfile(report_input.source_path, report_input.sources{jef}, 's_parameter', 'data_postprocessed.mat'), 'pp_data')
        %     for hew = 1:length(requested_frequencies)
        %         freq_ind = find(pp_data.scale > (requested_frequencies(hew)- 1e6), 1, 'first');
        %         data_out{hew}(:,:,jef) = cellfun(@(x)x(1,freq_ind),pp_data.data);
        %     end %for
        range_ind = find(pp_data.scale > (top_of_range(kds) - 1e6), 1, 'first');
        data_out2(1:length(pp_data.port_list),1:length(pp_data.all_ports),jef) = cellfun(@(x)x(1,1:range_ind),pp_data.data, 'UniformOutput',false);
        scale_out(:,jef) = pp_data.scale(1:range_ind);
        clear pp_data
    end %for
    
    % ADD SOME TEMP PLOTTING
    % for seh = 1:length(requested_frequencies)
    %     h =figure(4305);
    %     x_data = cellfun(@(x)str2num(x), report_input.swept_vals);
    %     [x_data, I] = sort(x_data);
    %     y_data = squeeze(20* log10(data_out{seh}(1,4:6,:)))';
    %     y_data = y_data(I,:);
    %     plot(x_data, y_data, 'LineWidth', 2)
    %     xlabel(regexprep(report_input.swept_name, '_', ' '))
    %     ylabel('S parameters (dB)')
    %     legend('Horizontal', 'Vertical', 'Diagonal')
    %     title([num2str(requested_frequencies(seh)*1e-9),'GHz'])
    %     savemfmt(h, report_input.output_loc,regexprep(['s_parameters_port_3 - ',report_input.swept_name{1}, ' - ', num2str(requested_frequencies(seh)*1e-9),'GHz'],'\.', 'p'))
    %     close(h)
    % end %for
    h = figure('Position', [0, 0, 1200, 1200]);
    plot_nums = [1,2,3,4];
    plot_names = {'Reflection','Transmission Horizontal','Transmission Vertical','Transmission Diagonal'};
    data_loc = [3,4,5,6];
    for kse = 1:length(plot_nums)
        subplot(2,2,plot_nums(kse))
        for hrg = 1:length(report_input.swept_vals)
            title([regexprep(report_input.swept_name, '_', ' '), ' - ', plot_names{kse}])
            x_data = squeeze(scale_out(:,hrg)) * 1E-6;
            y_data = 20* log10(data_out2{1,data_loc(kse),hrg});
            if ~isempty(y_data)
                plot(x_data(:), y_data(:), 'DisplayName', num2str(report_input.swept_vals{hrg}),...
                    'LineWidth', 2)
            end %if
            hold on
        end %for
        hold off
        ylim([-Inf 0])
        legend('Location', 'EastOutside')
        xlabel('Frequency (MHz)')
        ylabel('S parameters (dB)')
    end %for
    [~, model_name] = fileparts(report_input.source_path);
    savemfmt(h, report_input.output_loc,[model_name, ' - s_parameters_port_3 - ',report_input.swept_name{1}, ' - ', '0-',num2str(top_of_range(kds) *1e-6),'MHz'])
    close(h)
    if kds < length(top_of_range)
        clear scale_out data_out data_out2
    end %if
end %for