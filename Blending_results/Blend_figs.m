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
swept_vals = report_input.swept_vals;
if strcmp(graph_metadata.sweep_type, 'geometry')
    if strcmp(report_input.swept_name{1}, 'stripline_taper_end_width')
        %             convert radians to degrees
        for ks = 1:length(swept_vals)
            swept_vals{ks} = [num2str(round(str2double(swept_vals{ks})  ./ pi .* 180)), ' degrees'];
        end %for
    else
        %             convert to mm
        for ks = 1:length(swept_vals)
            swept_vals{ks} = [num2str(str2double(swept_vals{ks})  .* 1000), ' mm'];
        end %for
    end %if
elseif strcmp(graph_metadata.sweep_type, 'beam_offset_x')
    %             convert to mm
    for ks = 1:length(swept_vals)
        swept_vals{ks} = [num2str(str2double(swept_vals{ks})  .* 1000), ' mm'];
    end %for
elseif strcmp(graph_metadata.sweep_type, 'beam_offset_y')
    %             convert to mm
    for ks = 1:length(swept_vals)
        swept_vals{ks} = [num2str(str2double(swept_vals{ks})  .* 1000), ' mm'];
    end %for   
end %if

%% wake graphs
good_wake_data = zeros(length(report_input.sources),1);
for hse = 1:length(report_input.sources)
    if exist(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_analysed_wake.mat'), 'file') == 2
        good_wake_data(hse) = 1;
    end %if
end %for
if sum(good_wake_data) > 0
    ck = 1;
    for hse = length(good_wake_data):-1 :1
        if good_wake_data(hse) == 1
            load(fullfile(report_input.source_path, report_input.sources{hse}, 'wake', 'data_analysed_wake.mat'), 'pp_data');
            data_out(ck, :) = blend_wake_data(pp_data, swept_vals{hse});
            ck = ck +1;
        end %if
    end %for
    parfor egvn = 1:size(data_out,2)
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
if sum(good_s_data) > 0
    ck = 1;
    for hse = length(good_s_data):-1 :1
        if good_s_data(hse) == 1
            load(fullfile(report_input.source_path, report_input.sources{hse}, 'sparameter', 'data_analysed_sparameter.mat'), 'sparameter_data');
            
            data_out(ck, :) = blend_s_param_data(sparameter_data, swept_vals{hse});
            ck = ck +1;
        end %if
    end %for
    parfor egvn = 1:size(data_out,2)
        Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,egvn)))
    end %for
end %if
clear data_out

%% Field graphs
source_path = report_input.source_path;
sources = report_input.sources;
field_snapshot_times = report_input.field_snapshot_times;

good_field_data = zeros(length(sources),1);
for hse = 1:length(sources)
    if exist(fullfile(source_path, sources{hse}, 'wake', 'field_data.mat'), 'file') == 2
        good_field_data(hse) = 1;
    end %if
end %for
if sum(good_field_data) > 0
    data_out_temp = cell(length(good_field_data),1);
    parfor hse = 1:length(good_field_data)
        if good_field_data(hse) == 1
            T = load(fullfile(source_path, sources{hse}, 'wake', 'field_data.mat'), 'field_data');
            data_out_temp{hse}(1, :) = blend_field_data(T.field_data, report_input.mesh_stepsize{hse}, swept_vals{hse}, 'max');
            for ens = 2:length(field_snapshot_times) +1
                data_out_temp{hse}(ens, :) = blend_field_data(T.field_data, report_input.mesh_stepsize{hse}, swept_vals{hse}, field_snapshot_times(ens -1));
            end %for
        end %if
    end %parfor
    data_out_temp(good_field_data == 0) = [];
    for nes = 1:length(data_out_temp)
        data_out(nes, :, :) = data_out_temp{nes}(:,:);
    end %for
    for fns = 1:length(report_input.field_snapshot_times) + 1
        for egvn = 1:size(data_out,2) %par
            Generate_2D_graph_with_legend(graph_metadata, squeeze(data_out(:,fns, egvn)))
        end %for
    end %for
end %if