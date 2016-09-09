function ov = latex_side_by_side_images(im1, im2, cap1, cap2)
% Writes latex code for placing two images side by side.
% Can also be used with a single images by passing [] to the other input.

ov = cell(1,1);
ov = cat(1,ov,'\begin{figure}[htb]');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,'\begin{minipage}{0.46\textwidth}');
ov = cat(1,ov,'\centering');
if ~isempty(im1)
    ov = cat(1,ov,['\includegraphics [width=\textwidth]{',im1,'}']);
    ov = cat(1,ov,['\caption{',cap1,'}']);
end
ov = cat(1,ov,'\end{minipage}%');
ov = cat(1,ov,'\hspace{0.04\textwidth}');
ov = cat(1,ov,'\begin{minipage}{0.46\textwidth}');
if ~isempty(im2)
    ov = cat(1,ov,['\includegraphics [width=\textwidth]{',im2,'}']);
    ov = cat(1,ov,['\caption{',cap2,'}']);
end
ov = cat(1,ov,'\end{minipage}');
ov = cat(1,ov,'\end{figure}');