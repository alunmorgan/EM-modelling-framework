function state = Blend_figs(report_input, sub_folder ,fig_nme, out_name, lg, lw, line_select, udcp)
% Take existing fig files and combine them.
% lg specifes if a log or linear scale it to be used (0 = linear, 1 = log)
% lw specifies the linewidth.
% line_select is a regular expression search based on the display name of
% the line.
%
% If there is no data returns state == 0 otherwise state ==1
%
% Example: state = Blend_figs(report_input, ['s_parameters_S',num2str(hs),num2str(ha)], 0, 2, '\s*S\d\d\(1\)\s*');

state = 1;

if nargin <7
    line_select = 'all';
end
cols = {'b','k','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[0.5, 0, 1],[1, 0, 0.5],[0.5, 1, 0] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};

any_data = 0;
for hse = length(report_input.sources):-1 :1
    graph_name = fullfile(report_input.source_path, report_input.sources{hse}, sub_folder,  [fig_nme, '.fig']);
%     graph_name = fullfile(report_input.source_path, report_input.sources{hse}, sub_folder, [fig_nme, '.fig']);
    if exist(graph_name,'file')
        data_out(hse) = extract_from_graph(graph_name, line_select);
        if data_out(hse).state == 1
            any_data = 1;
        end %if
    end %if
end %for
if any_data == 0
    state = 0;
    return
end
% Zlab = report_input.swept_name;
% xlims = data_out(1).xlims;
% ylims = data_out(1).ylims;
% for ew = 2:length(data_out);
%     xlims = cat(1, xlims, data_out(ew).xlims);
%     ylims = cat(1, ylims, data_out(ew).ylims);
% end %for

% This section is to remove the levels and other straight line which may be
% on the graphs.
for hwc = length(data_out):-1:1
    if isfield(data_out(hwc), 'xdata') && ~isempty(data_out(hwc).xdata)
        for wah = length(data_out(hwc).xdata):-1:1
            if ~isempty(data_out(hwc).xdata{wah})
                d_len(hwc, wah) = length(data_out(hwc).xdata{wah});
            else
                d_len(hwc, wah) = 0 ;
            end %if
        end %for
    else
        d_len(hwc,:) = 0;
    end %if
end %for

unwanted_lines = all(d_len <3, 1);
% Find first wanted line
fwl = find(unwanted_lines == 0,1, 'first');

%% Plot graphs
Generate_2D_graph_with_legend(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)

% Generate_2D_graph_showing_the_difference_to_the_first_trace(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)

% Generate_3D_graph_with_no_legend(report_input, data_out, fwl, cols, l_st, lw, lg, out_name)