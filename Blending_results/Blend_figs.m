function Blend_figs(report_input)
% Take existing fig files and combines them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
%
%
% Example: Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2);

graph_metadata.swept_name = report_input.swept_name;
graph_metadata.output_loc = report_input.output_loc;
graph_metadata.sweep_type = report_input.sweep_type;

%% wake graphs
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
        %         load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_from_run_logs.mat'), 'run_logs');
        data_out(ck, :) = blend_wake_data(pp_data, report_input.swept_vals{hse});
        ck = ck +1;
    end %if
end %for
if sum(good_wake_data) > 0
    for egvn = 1:size(data_out,2)
        Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,egvn)))
    end
end %if
clear data_out

%% S-parameter graphs
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
        data_out(ck, :) = blend_s_param_data(sparameter_data, report_input.swept_vals{hse});
        ck = ck +1;
    end %if
end %for
if sum(good_s_data) > 0
    for egvn = 1:size(data_out,2)
        Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,egvn)))
    end %for
end %if
clear data_out

%% Field graphs
good_field_data = zeros(length(report_input.sources),1);
for hse = 1:length(report_input.sources)
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'field_data.mat'), 'file') == 2
        good_field_data(hse) = 1;
    end %if
end %for
ck = 1;
for hse = length(good_field_data):-1 :1
    if good_field_data(hse) == 1
        load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'field_data.mat'), 'field_data');
        for ens = 1:length(report_input.field_snapshot_times)
            data_out(ck, ens, :) = blend_field_data(field_data, report_input.swept_vals{hse}, report_input.field_snapshot_times(ens));
        end %for
        data_out(ck, ens +1, :) = blend_field_data(field_data, report_input.swept_vals{hse}, 'max');
        ck = ck +1;
    end %if
end %for
if sum(good_field_data) > 0
    for fns = 1:length(report_input.field_snapshot_times) + 1
        for egvn = 1:size(data_out,2)
            Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,fns, egvn)))
        end %for
    end %for
end %if