function ov = gather_mat_loss_graphs(doc_root, output_path, source_reps, report_input, mgnme)

if ispc == 0
    slh = '/';
else
     slh = '\';
end

ov = {''};
for hse = length(source_reps):-1:1
    source = [doc_root, slh, source_reps{hse},slh, 'wake', slh,  mgnme,'.eps'];
    dest = [output_path, slh, mgnme,'_',num2str(hse), '.eps'];
    try
    copyfile(source, dest)
    catch
        warning(['Thermal loss graph is not available for ', num2str(source_reps{hse})])
        nme{hse} = [];
        continue
    end
    nme{hse} = [ mgnme,'_',num2str(hse), '.eps'];
end
for nes = 1:2:length(source_reps)
    if nes == length(source_reps)
        % this is to cover the case where there are an odd number of
        % graphs.
        ov = cat(1,ov,'\begin{figure}[htb]');
        ov = cat(1,ov,'\begin{center}');
        ov = cat(1,ov,['\includegraphics [width=0.46\textwidth]{',nme{nes},'}']);
        ov = cat(1,ov,['\caption{',report_input.swept_name, ' = ', report_input.swept_vals{nes},'}']);
        ov = cat(1,ov,'\end{center}');
        ov = cat(1,ov,'\end{figure}');
    else
        ov1 = latex_side_by_side_images(nme{nes},nme{nes+1},...
            [report_input.swept_name, ' = ', report_input.swept_vals{nes}],...
            [report_input.swept_name, ' = ', report_input.swept_vals{nes + 1}]);
        ov = cat(1,ov,ov1);
    end
end
ov = cat(1,ov,'\clearpage');