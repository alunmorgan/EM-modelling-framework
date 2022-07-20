function s_parameter_extract_single_frequency_data(report_input)

cols_sep = {'y','k','r','b','g','c','m'};
linewidth = 2;
good_data = zeros(length(report_input.sources),1);
for jef = 1:length(report_input.sources) % different models in sweep
    if exist(fullfile(report_input.source_path, report_input.sources{jef}, 'sparameter'), 'dir') == 7
        good_data(jef) = 1;
    end %if
end %for

[~,sim_name,~] = fileparts(report_input.source_path);
sim_name = regexprep(sim_name, '_', ' ');
A = strfind(report_input.sources, '_sweep_');
B = find(cellfun(@isempty, A)==0,1,'first'); % first entry with the sweep name
if isempty(B)
    sweep_title = '';
else
    sweep_title = regexprep(report_input.sources{B}, '_sweep_.*', '');
    sweep_title = regexprep(sweep_title, '_', ' ');
    sweep_title = regexprep(sweep_title, sim_name, '');
end %if
trace_names = regexprep(report_input.sources, '_', ' ');
trace_names = regexprep(trace_names, sim_name ,'');
sweep_type = regexprep(report_input.sweep_type, '_', ' ');
trace_names = regexprep(trace_names, [sweep_type, ' sweep value .*'] ,'');
C = strfind(trace_names, ' Base');
D = find(cellfun(@isempty, C)==0,1,'first'); % base loc
E = strfind(trace_names, 'mm');
F = find(cellfun(@isempty, E)==0,1,'first');
if isempty(F)
    E = strfind(trace_names, 'deg');
    F = find(cellfun(@isempty, E)==0,1,'first');
    if isempty(F)
        trace_names{D} = num2str(report_input.swept_vals{D});
    else
        trace_names{D} = [num2str(round(report_input.swept_vals{D}./pi*180)), 'degrees'];
    end %if
else
    trace_names{D} = [num2str(str2double(report_input.swept_vals{D})*1000), 'mm'];
end %if
ck = 1;
for jef = 1:length(good_data)
    if good_data(jef) == 1
        load(fullfile(report_input.source_path, report_input.sources{jef}, 'sparameter', 'data_analysed_sparameter.mat'), 'sparameter_data')
        trace_name = trace_names{jef};
        sets = unique(sparameter_data.set);
            n_ports = length(sparameter_data.all_ports);
            old_size_h = size(h);
            for kse = 1:n_ports
                for hsw = 1:n_ports
                    if old_size_h(1) < kse || old_size_h(2) < hsw
                        h(kse, hsw) = figure('Position', [0, 0, 800, 800]);
                    end %if
                end %for
            end %for
        
        for law = 1:length(sets)
            set_filter = strcmp(sparameter_data.set,sets{law});
            temp_data = sparameter_data.data(set_filter,:);
            temp_scale = sparameter_data.scale(set_filter,:);
            temp_excitation_port_list = sparameter_data.port_list(set_filter);
            for nre = 1:size(temp_data,1) % excitation ports
                s_in  = find_position_in_cell_lst(strfind(sparameter_dataa.all_ports, temp_excitation_port_list{nre}));
                for es = 1:size(temp_data,2) % receiving ports
                    tmp_data = temp_data{nre,es};
                    for m=1:1%size(tmp_data,1) % Iterate over modes
                        x_data = temp_scale{nre, es}(m,1:end-2) * 1e-9;
                        y_data = 20* log10(tmp_data(m, 1:end-2));
                        figure(h(s_in,es))
                        hold on
                        hl = plot(x_data, y_data, '-',...
                            'Color', cols_sep{rem(ck,length(cols_sep))+1}, ...
                            'Linewidth', linewidth,...
                            'DisplayName',trace_name);
                        hold off
                        if law > 1
                            set(get(get(hl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        end %if
                    end %for
                    t_string1 = ['S(',num2str(s_in),',',num2str(es),')'];
                    legend('Location', 'EastOutside')
                    %                     ylim([min_y(s_in, es) 0])
                    xlabel('Frequency (GHz)')
                    ylabel('S parameters (dB)')
                    title([sim_name, sweep_title, ' S parameters ', t_string1])
                end %for
            end %for
        end %for
        clear pp_data trace_name
        swept_vals(ck) = report_input.swept_vals(jef);
        ck = ck + 1;
    end %if
end %for

if exist('n_ports')
    for kse = 1:n_ports
        for hsw = 1:n_ports
            savemfmt(h(kse, hsw), report_input.output_loc, ['s_parameters_S',num2str(kse),num2str(hsw)])
            close(h(kse, hsw))
        end %for
    end %for
end %if
% end %for
%     if exist('data_out2', 'var')
%         h = figure('Position', [0, 0, 1200, 1200]);
%         %         plot_names = {'Reflection','Transmission Horizontal','Transmission Vertical','Transmission Diagonal'};
%         n_plots = size(data_out2,1);
%         for kse = 1:n_plots %plots
%             subplot(floor(sqrt(n_plots)), ceil(sqrt(n_plots)), kse)
%             for hrg = 1:length(swept_vals) % models
%                 title([regexprep(report_input.swept_name, '_', ' '), ' - ', kse])
%                 x_data = squeeze(scale_out(:,hrg)) * 1E-6;
%                 % data(excitation port, mesurement port, model)
%                 y_data = 20* log10(data_out2{1, kse ,hrg});
%                 if ~isempty(y_data)
%                     plot(x_data(:), y_data(:), 'DisplayName', num2str(swept_vals{hrg}),...
%                         'LineWidth', 2)
%                 end %if
%                 hold on
%             end %for
%             hold off
%             ylim([-Inf 0])
%             legend('Location', 'EastOutside')
%             xlabel('Frequency (MHz)')
%             ylabel('S parameters (dB)')
%         end %for
%         [~, model_name] = fileparts(report_input.source_path);
%         savemfmt(h, report_input.output_loc,[model_name, ' - s_parameters_port_3 - ',report_input.swept_name{1}, ' - ', '0-',num2str(top_of_range(kds) *1e-6),'MHz'])
%         close(h)
%         if kds < length(top_of_range)
%             clear scale_out data_out data_out2
%         end %if
%     end %if
% end %for