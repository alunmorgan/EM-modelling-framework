function out = add_blend_table(model_name, subtitle, swept_vals, summary)
% Generate a table comparing the run times and modelling setups of the
% models in the blend.
%
% Example: out = add_blend_table(model_name, subtitle, swept_vals, summary)

out{1} = ' ';
out = cat(1,out,'\vspace{0.25cm} ');
out = cat(1,out, '\begin{tabular}{|m{1.2cm}| m{0.55cm} m{0.55cm} m{0.55cm} | m{0.55cm} m{0.55cm} | m{1.7cm} | m{1.7cm} | m{1.7cm} | m{1.5cm} |}');
out = cat(1,out,'\hline');
out = cat(1,out,['\multicolumn{9}{|c|}{\textbf{',model_name,' - ', subtitle,'}}\\']);
out = cat(1,out,'\hline');
out = cat(1,out,['Sweep value & ',...
    '\multicolumn{3}{|m{1.65cm}|}{Calculation time (single~CPU)} & \multicolumn{2}{|m{1.65cm}|}{Calculation time (wall~clock)} & ',...
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
        swept_vals_tmp =[];
    else
        swept_vals_tmp = swept_vals{hea};
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