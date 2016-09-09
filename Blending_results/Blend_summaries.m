function summary = Blend_summaries(doc_root, slh, source_reps)
% Extacts data from the summary graph fig files.
%
% Example: summary = Blend_summaries(doc_root, slh, source_reps)
for hse = 1:length(source_reps)
    try
    hn = open([doc_root, slh, source_reps{hse}, slh, 'wake', slh, 'summary.fig']);
    catch
        warning(['Summary not available for ', num2str(source_reps{hse})])
        continue
    end
    a=get(gca,'Children');
    b = get(a,'Tag');
    summary.wlf{hse} = get(a(find_position_in_cell_lst(strfind(b,'wlf'))),'String');
    summary.date{hse} = get(a(find_position_in_cell_lst(strfind(b,'Date'))),'String');
    summary.soft_ver{hse} = get(a(find_position_in_cell_lst(strfind(b,'Software_version'))),'String');
    summary.soft_type{hse} = get(a(find_position_in_cell_lst(strfind(b,'Software_type'))),'String');
    temp_CPU = get(a(find_position_in_cell_lst(strfind(b,'CPU_time'))),'String');
    summary.CPU_time{hse} = sort_summary_dates(temp_CPU{2});
    summary.num_cores{hse} = get(a(find_position_in_cell_lst(strfind(b,'Num_cores'))),'String');
    temp_wall =  get(a(find_position_in_cell_lst(strfind(b,'Wall_time'))),'String');
    summary.wall_time{hse} = sort_summary_dates(temp_wall{2});
    summary.num_mesh_cells{hse} = regexprep(get(a(find_position_in_cell_lst(strfind(b,'Num_mesh_cells'))),'String'),'Number of mesh cells = ','');
    summary.mem_used{hse} = regexprep(get(a(find_position_in_cell_lst(strfind(b,'Memory_used'))),'String'), 'Memory used = ','');
    summary.mesh_spacing{hse} = get(a(find_position_in_cell_lst(strfind(b,'Mesh_spacing'))),'String');
    summary.timestep{hse} = regexprep(get(a(find_position_in_cell_lst(strfind(b,'Timestep'))),'String'), 'Timestep = ', '');
    summary.machine_settings{hse} = get(a(find_position_in_cell_lst(strfind(b,'Machine_settings'))),'String');
    summary.multipliers{hse} = get(a(find_position_in_cell_lst(strfind(b,'Multipliers'))),'String');
    summary.name{hse} = regexprep(source_reps{hse},'_',' ');
    close(hn)
end