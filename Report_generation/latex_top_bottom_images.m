function ov = latex_top_bottom_images(im1, im2, cap1, cap2, lab1, lab2, w1, w2)
ov = cell(1,1);
ov = cat(1,ov,'\begin{figure}[htb]');
ov = cat(1,ov,'\begin{minipage}{',num2str((1-w1)/2),'\textwidth}');
ov = cat(1,ov,'\end{minipage}%');
ov = cat(1,ov,'\begin{minipage}{',num2str(w1),'\textwidth}');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,['\includegraphics [width=\textwidth]{',im1,'}']);
ov = cat(1,ov,['\caption{',cap1,'}']);
ov = cat(1,ov,['\label{',lab1,'}']);
ov = cat(1,ov,'\end{minipage}\\');
ov = cat(1,ov,'\begin{minipage}{',num2str((1-w1)/2),'\textwidth}');
ov = cat(1,ov,'\end{minipage}');
ov = cat(1,ov,'\begin{minipage}{',num2str((1-w2)/2),'\textwidth}');
ov = cat(1,ov,'\end{minipage}%');
ov = cat(1,ov,'\begin{minipage}{',num2str(w2),'\textwidth}');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,['\includegraphics [width=\textwidth]{',im2,'}']);
ov = cat(1,ov,['\caption{',cap2,'}']);
ov = cat(1,ov,['\label{',lab2,'}']);
ov = cat(1,ov,'\end{minipage}');
ov = cat(1,ov,'\end{figure}');