function out = add_blend_table(model_name, subtitle, swept_vals, summary)
% Generate a table comparing the run times and modelling setups of the
% models in the blend.
%
% Example: out = add_blend_table(model_name, subtitle, swept_vals, summary)

for lse = 1:length(summary.wall_time)
CPU_time_sections_list(lse) = length(strfind(summary.CPU_time{lse},','));
wall_time_sections_list(lse) = length(strfind(summary.wall_time{lse},','));
end %for
CPU_time_sections = max(CPU_time_sections_list);
wall_time_sections = max(wall_time_sections_list);
% adding extra , to make all the time strings have the same number of
% sections
for lse = 1:length(summary.wall_time)
    if CPU_time_sections - CPU_time_sections_list(lse) == 1
        summary.CPU_time{lse} = cat(2, ',', summary.CPU_time{lse});
    elseif CPU_time_sections - CPU_time_sections_list(lse) == 2
        summary.CPU_time{lse} = cat(2, ',,', summary.CPU_time{lse});
    elseif CPU_time_sections - CPU_time_sections_list(lse) == 3
        summary.CPU_time{lse} = cat(2, ',,,', summary.CPU_time{lse});
    end %if
    if wall_time_sections - wall_time_sections_list(lse) == 1
        summary.wall_time{lse} = cat(2, ',', summary.wall_time{lse});
    elseif wall_time_sections - wall_time_sections_list(lse) == 2
        summary.wall_time{lse} = cat(2, ',,', summary.wall_time{lse});
    elseif wall_time_sections - wall_time_sections_list(lse) == 3
        summary.wall_time{lse} = cat(2, ',,,', summary.wall_time{lse});
    end %if
end %for
time_section_size = 0.55;
tab1 = '\begin{tabular}{|m{1.2cm}|';
for ne = 1:CPU_time_sections
    tab1 = strcat(tab1, ' m{', num2str(time_section_size), 'cm}');
end %if
tab1 = strcat(tab1, ' | ');
for nw = 1:wall_time_sections
    tab1 = strcat(tab1, ' m{', num2str(time_section_size), 'cm}');
end %if
tab1 = strcat(tab1, ' | m{1.7cm} | m{1.7cm} | m{1.5cm} |}');
out{1} = ' ';
out = cat(1,out,'\vspace{0.25cm} ');
out = cat(1,out, tab1);
out = cat(1,out,'\hline');
out = cat(1,out,['\multicolumn{'...
    ,num2str(1 + CPU_time_sections + wall_time_sections + 3),...
    '}{|c|}{\textbf{',model_name,' - ', subtitle,'}}\\']);
out = cat(1,out,'\hline');
out = cat(1,out,['Sweep value & ',...
    '\multicolumn{',num2str(CPU_time_sections),...
    '}{|m{',num2str(time_section_size * CPU_time_sections),'cm}|}{Calculation~time (single~CPU)} & \multicolumn{', ...
    num2str(wall_time_sections),...
    '}{|m{',num2str(time_section_size * wall_time_sections),'cm}|}{Calculation~time (wall~clock)} & ',...
    'Number of mesh cells & Memory used & Timestep\\' ]);
out = cat(1,out,'\hline');
for hea = 1:length(summary.wlf)
    CPU_time = regexprep(summary.CPU_time{hea}, ',', ' & ');
    if isempty(CPU_time)
        CPU_time = ' & & & ';
    end %if
    wall_time = regexprep(summary.wall_time{hea}, ',', ' & ');
    if isempty(wall_time)
        wall_time = ' & & ';
    end %if
    num_mesh_cells = summary.num_mesh_cells{hea};
    mem_used = summary.mem_used{hea};
    timestep = summary.timestep{hea};
    % this is to cope with the fact that MATLAB tries to be clever and
    % truncates the cell array if the last row is empty.
    if length(swept_vals) == length(summary.wlf) -1 && hea == length(summary.wlf)
        swept_vals_tmp ='';
    else
        if isempty(swept_vals{hea})
            swept_vals_tmp ='';
        else
        swept_vals_tmp = swept_vals{hea};
        end %if
        % adding in the maths environment wrapping
        swept_vals_tmp = regexprep(swept_vals_tmp, '\\mu{}', '$\\mu{}$');
    end
    
    out = cat(1,out,[swept_vals_tmp,' & ',...
        CPU_time, wall_time,...
        num_mesh_cells ' & ' ,mem_used, ' & ',timestep, '\\' ]);
    out = cat(1,out,'\hline ');
end
out = cat(1,out,'\end{tabular}');
out = cat(1,out,'\vspace{0.25cm} ');