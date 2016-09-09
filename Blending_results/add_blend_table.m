function out = add_blend_table(model_name, subtitle, swept_vals, summary)
% Generate a table comparing the run times and modelling setups of the
% models in the blend.
%
% Example: out = add_blend_table(model_name, subtitle, swept_vals, summary)

out{1} = ' ';
out = cat(1,out,'\vspace{0.25cm} ');
out = cat(1,out, '\begin{tabular}{|m{1.2cm}| m{1.7cm} | m{1.7cm} | m{1.7cm} | m{1.7cm} | m{1.5cm} |}');
out = cat(1,out,'\hline');
out = cat(1,out,['\multicolumn{6}{ |c| }{',model_name,' - ', subtitle,'}\\']);
out = cat(1,out,'\hline');
out = cat(1,out,['Sweep value & ',...
    'Calculation time (single CPU) & Calculation time (wall clock) & ',...
    'Number of mesh cells & Memory used & Timestep\\' ]);
out = cat(1,out,'\hline');
for hea = 1:length(summary.wlf)
    CPU_time = summary.CPU_time{hea};
    wall_time = summary.wall_time{hea};
    num_mesh_cells = summary.num_mesh_cells{hea};
    mem_used = summary.mem_used{hea};
    timestep = summary.timestep{hea};
    if isempty(CPU_time)
        CPU_time = {'','','',''};
    end
    if isempty(wall_time)
        wall_time = {'','','',''};
    end
    out = cat(1,out,['\multirow{4}{1.2cm}{',swept_vals{hea},'} & ',...
        CPU_time{1},' & ',wall_time{1}, ' & ',...
        '\multirow{4}{1.7cm}{',num_mesh_cells,...
        '} & \multirow{4}{1.7cm}{',mem_used,...
        '} & \multirow{4}{1.5cm}{',timestep, '} \\' ]);
    out = cat(1,out,['& ',CPU_time{2},' & ',wall_time{2}, ' &&& \\']);
    out = cat(1,out,['& ',CPU_time{3},' & ',wall_time{3}, ' &&& \\']);
    out = cat(1,out,['& ',CPU_time{4},' & ',wall_time{4}, ' &&& \\']);
    out = cat(1,out,'\hline ');
end
out = cat(1,out,'\end{tabular}');
out = cat(1,out,'\vspace{0.25cm} ');