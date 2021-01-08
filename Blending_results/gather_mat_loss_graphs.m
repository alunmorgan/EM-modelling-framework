function ov = gather_mat_loss_graphs(res_path, source_reps, report_input, mgnme)

ov = {''};
for hse = length(source_reps):-1:1
    source = fullfile(res_path, source_reps{hse}, 'wake',  [mgnme,'.eps']);
    dest = fullfile(report_input.output_loc, [mgnme,'_',num2str(hse), '.eps']);
    try
    copyfile(source, dest)
    catch
        disp(['Thermal loss graph is not available for ', num2str(source_reps{hse})])
        nme{hse} = [];
        continue
    end
    nme{hse} = [ mgnme,'_',num2str(hse), '.eps'];
end
source_reps = source_reps(report_input.good_data == 1);
for nes = 1:2:length(source_reps)
    if nes == length(source_reps)
        % this is to cover the case where there are an odd number of
        % graphs.
        ov = cat(1,ov,'\begin{figure}[htb]');
        ov = cat(1,ov,'\begin{center}');
        if ~isempty(nme{nes})
        ov = cat(1,ov,['\includegraphics [width=0.46\textwidth]{',nme{nes},'}']);
        end %if
%         % this is to cope with the fact that MATLAB tries to be clever and
%         % truncates the cell array if the last row is empty.
%         if length(report_input.swept_vals) == length(source_reps) && nes == length(source_reps)
            swept_vals_tmp = report_input.swept_vals{nes};
            if isempty(swept_vals_tmp)
                swept_vals_tmp = '';
            end %if
            swept_vals_tmp = regexprep(swept_vals_tmp, '\\mu{}', '$\\mu{}$');
%         else
%             swept_vals_tmp =[];
%         end
        ov = cat(1,ov,['\caption{',report_input.swept_name{1}, ' = ', swept_vals_tmp,'}']);
        ov = cat(1,ov,'\end{center}');
        ov = cat(1,ov,'\end{figure}');
    else
        ov1 = latex_side_by_side_images(nme{nes},nme{nes+1},...
            [report_input.swept_name{1}, ' = ', regexprep(report_input.swept_vals{nes}, '\\mu{}', '$\\mu{}$')],...
            [report_input.swept_name{1}, ' = ', regexprep(report_input.swept_vals{nes + 1}, '\\mu{}', '$\\mu{}$')]);
        ov = cat(1,ov,ov1);
    end
end
ov = cat(1,ov,'\clearpage');