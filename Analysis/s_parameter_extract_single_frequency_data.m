function s_parameter_extract_single_frequency_data(report_input)

top_of_range = [750E6, 5e9];
for kds = 1:length(top_of_range) % different frequency extents
    for jef = 1:length(report_input.sources) % different models in sweep
        if exist(fullfile(report_input.source_path, report_input.sources{jef}, 's_parameter'), 'dir') == 7
            good_data(jef) = 1;
        else
            good_data(jef) = 0;
        end %if
    end %for
    ck = 1;
    for jef = 1:length(good_data)
        if good_data(jef) == 1
            load(fullfile(report_input.source_path, report_input.sources{jef}, 's_parameter', 'data_postprocessed.mat'), 'pp_data')
            range_ind = find(pp_data.scale{1}(1,:) > (top_of_range(kds) - 1e6), 1, 'first');
            % data(excitation port, mesurement port, model)
            data_out2(1:length(pp_data.port_list),1:length(pp_data.all_ports),ck) = ...
                cellfun(@(x)x(1,1:range_ind),pp_data.data, 'UniformOutput',false);
            scale_out(1:range_ind,ck) = pp_data.scale{1, 1}(1, 1:range_ind);
            clear pp_data
            swept_vals(ck) = report_input.swept_vals(jef);
            ck = ck + 1;
        end %if
    end %for
    
    h = figure('Position', [0, 0, 1200, 1200]);
    plot_names = {'Reflection','Transmission Horizontal','Transmission Vertical','Transmission Diagonal'};
    for kse = 1:size(data_out2,1) %plots
        subplot(2,2,kse)
        for hrg = 1:length(swept_vals) % models
            title([regexprep(report_input.swept_name, '_', ' '), ' - ', plot_names{kse}])
            x_data = squeeze(scale_out(:,hrg)) * 1E-6;
            % data(excitation port, mesurement port, model)
            % the +2 is because we are not exciting the beam ports
            y_data = 20* log10(data_out2{1,kse+2 ,hrg});
            if ~isempty(y_data)
                plot(x_data(:), y_data(:), 'DisplayName', num2str(swept_vals{hrg}),...
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