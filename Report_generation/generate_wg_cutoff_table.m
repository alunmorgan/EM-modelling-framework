function combined = generate_wg_cutoff_table(alpha, beta, cutoff, tab_t)
% Generates a latex table of the waveguide cutoff data.
%
% alpha is 
% beta is 
% cutoff is 
% tab_t is 
% combined is the output latex code for the table.
%
% Example: combined = generate_wg_cutoff_table(alpha, beta, cutoff, tab_t)

% generating the parameter table
combined = {'\clearpage'};
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.3}');

for ndw = 1:length(cutoff)
    combined = cat(1,combined, '\begin{table}[ht]');
    col_width = strcat(num2str(0.8/4), '\textwidth');
    tab_start = '\begin{tabular}{|p{0.075\textwidth}|';
    tab_titles = '. ';
    par_names = {' attenuation $\alpha$ (1/m) ', ' propagation $\beta$ (1/m) ', ' frequency cutoff (GHz) '};
    for esn = 1:length(par_names)
        tab_start = strcat(tab_start,'p{', col_width,'}|');
        tab_titles = [tab_titles,'& ', par_names{esn}];
    end
    tab_start = strcat(tab_start, '}');
    tab_titles = [tab_titles, '\\'];
    combined = cat(1,combined, tab_start);
    combined = cat(1,combined, '\hline');
    combined = cat(1,combined, ['\multicolumn{', num2str(length(par_names) +1), '}{|c|}{\textbf{', regexprep(tab_t{ndw},'_', ' '), '}}\\']);
    combined = cat(1,combined, '\hline');
    combined = cat(1,combined, tab_titles);
    combined = cat(1,combined, '\hline');
    for enaw = 1:length(cutoff{ndw})
%         if alpha{ndw}(enaw) == 0
%             remnant = 0;
%         else
%             remnant = exp(-alpha{ndw}(enaw) * pipe_length(ndw)) * 100;
%         end
if cutoff{ndw}(enaw) < 1E-4
    cf = 0;
else
    cf = cutoff{ndw}(enaw).* 1E-9;
end
        temp_tab_vals = ['Mode ', num2str(enaw),' & $', standard_form_text(alpha{ndw}(enaw)), '$ & $',...
            standard_form_text(-beta{ndw}(enaw)), '$ & $',standard_form_text(cf),'$\\' ];
        combined = cat(1,combined, temp_tab_vals);
        combined = cat(1,combined, '\hline');
    end
    combined = cat(1,combined, '\end{tabular}');
          combined = cat(1,combined, '\caption{Port mode parameters}');
    combined = cat(1,combined, '\end{table}');
end
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.0}');
combined = cat(1,combined, '\clearpage');