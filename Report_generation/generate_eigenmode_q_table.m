function combined = generate_eigenmode_q_table(eigenmode_data)
% Generates a latex table of the Q values.
%
% eigenmode_data is 
% combined is the output latex code for the table.
%
% Example: combined = generate_eigenmode_q_table(eigenmode_data)

% generating the parameter table
combined = {'\clearpage'};
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.3}');


combined = cat(1,combined, '\begin{table}[ht]');
col_width = strcat(num2str(0.65/4), '\textwidth');
tab_start = '\begin{tabular}{|p{0.075\textwidth}|';
tab_titles = 'modes';
par_names = {'Frequencies (GHz)', 'Q'};
for esn = 1:length(par_names)
    tab_start = strcat(tab_start,'p{', col_width,'}|');
    tab_titles = [tab_titles,'& ', par_names{esn}];
end
tab_start = strcat(tab_start, '}');
tab_titles = [tab_titles, '\\'];
combined = cat(1,combined, tab_start);
combined = cat(1,combined, '\hline');
combined = cat(1,combined, tab_titles);
combined = cat(1,combined, '\hline');
if isfield(eigenmode_data, 'qs')
    for enaw = 1:length(eigenmode_data.qs.freq)
        temp_tab_vals = ['$',standard_form_text(eigenmode_data.qs.mode(enaw)),'$ & $',...
            standard_form_text(eigenmode_data.qs.freq(enaw)*1e-9),'$ & $',...
            standard_form_text(eigenmode_data.qs.q(enaw)), '$\\' ];
        combined = cat(1,combined, temp_tab_vals);
        combined = cat(1,combined, '\hline');
    end
end
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, '\caption{Q values}');
combined = cat(1,combined, '\end{table}');

combined = cat(1,combined, '\renewcommand{\arraystretch}{1.0}');
combined = cat(1,combined, '\clearpage');