function out = add_wlf_table(model_name, swept_name, swept_vals,summary)
% Generate a table of wake loss factors of the selected modelling runs.
%
% Example: out = add_wlf_table(model_name, swept_name, swept_vals,summary)

out{1} = ' ';
out = cat(1,out,'\vspace{1cm} ');
out = cat(1,out, '\begin{tabular}{|m{8cm}|m{4cm}|}');
out = cat(1,out,'\hline');
out = cat(1,out,['\multicolumn{2}{ |c| }{',model_name,' - sweep of ', swept_name,'}\\']);
out = cat(1,out,'\hline');
out = cat(1,out,'Swept value & Wake loss factor \\');
out = cat(1,out,'\hline');
for hea = 1:length(swept_vals)
    out = cat(1,out,[swept_vals{hea},' & ', summary.wlf{hea},' \\' ]);
    out = cat(1,out,'\hline');
end
out = cat(1,out,'\end{tabular}');
out = cat(1,out, ' ');