function s_parameter_extract_single_frequency_data(report_input)

cols_sep = {'y','k','r','b','g','c','m'};
linewidth = 2;
% top_of_range = [750E6, 5e9];
% for kds = 1:length(top_of_range) % different frequency extents
good_data = zeros(length(report_input.sources),1);
for jef = 1:length(report_input.sources) % different models in sweep
    if exist(fullfile(report_input.source_path, report_input.sources{jef}, 's_parameter'), 'dir') == 7
        good_data(jef) = 1;
        %     else
        %         good_data(jef) = 0;
    end %if
end %for

[~,sim_name,~] = fileparts(report_input.source_path);
sim_name = regexprep(sim_name, '_', ' ');
A = strfind(report_input.sources, '_sweep_');
B = find(cellfun(@isempty, A)==0,1,'first');
if isempty(B)
    sweep_title = '';
else
    sweep_title = regexprep(report_input.sources{B}, '_sweep_.*', '');
    sweep_title = regexprep(sweep_title, '_', ' ');
    sweep_title = regexprep(sweep_title, sim_name, '');
end %if
trace_names = regexprep(report_input.sources, '_', ' ');
trace_names = regexprep(trace_names, sim_name ,'');
trace_names = regexprep(trace_names, [sweep_title, ' sweep value '] ,'');
C = strfind(trace_names, ' Base');
D = find(cellfun(@isempty, C)==0,1,'first');
E = strfind(trace_names, 'mm');
F = find(cellfun(@isempty, E)==0,1,'first');
if isempty(F)
trace_names{D} = num2str(report_input.swept_vals{D});
else
    trace_names{D} = [num2str(str2double(report_input.swept_vals{D})*1000), 'mm'];
end %if
ck = 1;
h(1, 1) = figure('Position', [0, 0, 800, 800]);
h(1, 2) = figure('Position', [0, 0, 800, 800]);
for jef = 1:length(good_data)
    if good_data(jef) == 1
        load(fullfile(report_input.source_path, report_input.sources{jef}, 'sparameter', 'data_analysed_sparameter.mat'), 'pp_data')
        trace_name = trace_names{jef};
        sets = unique(pp_data.set);
            n_ports = length(pp_data.all_ports);
            old_size_h = size(h);
            for kse = 1:n_ports
                for hsw = 1:n_ports
                    if old_size_h(1) < kse || old_size_h(2) < hsw
                        h(kse, hsw) = figure('Position', [0, 0, 800, 800]);
                    end %if
                end %for
            end %for
        
        %             range_ind = find(pp_data.scale{1}(1,:) > (top_of_range(kds) - 1e6), 1, 'first');
        for law = 1:length(sets)
            set_filter = strcmp(pp_data.set,sets{law});
            temp_data = pp_data.data(set_filter,:);
            temp_scale = pp_data.scale(set_filter,:);
            temp_excitation_port_list = pp_data.port_list(set_filter);
            for nre = 1:size(temp_data,1) % excitation ports
                s_in  = find_position_in_cell_lst(strfind(pp_data.all_ports, temp_excitation_port_list{nre}));
                for es = 1:size(temp_data,2) % receiving ports
                    tmp_data = temp_data{nre,es};
                    for m=1:1%size(tmp_data,1) % Iterate over modes
                        x_data = temp_scale{nre, es}(m,1:end-2) * 1e-9;
                        y_data = 20* log10(tmp_data(m, 1:end-2));
%                         % Trimming off the end 10% as this often contains artifacts.
%                         start_ind = ceil(length(x_data)/10);
%                         final_ind = floor(length(x_data) - length(x_data) /10);
                        figure(h(s_in,es))
                        hold on
%                         hl = plot(x_data(start_ind:final_ind), y_data(start_ind:final_ind), '-',...
                        hl = plot(x_data, y_data, '-',...
                            'Color', cols_sep{rem(ck,length(cols_sep))+1}, ...
                            'Linewidth', linewidth,...
                            'DisplayName',trace_name);
                        hold off
                        if law > 1
                            set(get(get(hl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                        end %if
                        %                             data_out2(1:length(pp_data.port_list),1:length(pp_data.all_ports),ck) = ...
                        %                                 cellfun(@(x)x(1,1:range_ind),pp_data.data, 'UniformOutput',false);
                        %                             scale_out(1:range_ind,ck) = pp_data.scale{1, 1}(1, 1:range_ind);
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