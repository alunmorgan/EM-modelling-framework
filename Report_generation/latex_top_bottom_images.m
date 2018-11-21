function ov = latex_top_bottom_images(im1, im2, cap1, cap2, lab1, lab2, w1, w2)
% Generates the latex code to place two images one above the other.
%
% im1 and im2 are the full paths to the images.
% cap1 and cap1 are the respective captions.
% lab1 and lab2 are the respective labels
% w1 and w2 are the figure widths in fraction of textwidth.
% 
% Example: ov = latex_top_bottom_images(im1, im2, cap1, cap2, lab1, lab2, w1, w2)

ov = cell(1,1);
ov = cat(1,ov,'\begin{figure}[htb]');
if ~isempty(im1)
ov = cat(1,ov,'\begin{minipage}{',num2str(w1),'\textwidth}');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,['\includegraphics [width=\textwidth]{',im1,'}']);
ov = cat(1,ov,['\caption{',cap1,'}']);
ov = cat(1,ov,['\label{',lab1,'}']);
ov = cat(1,ov,'\end{minipage}\\');
end %if
if ~isempty(im2)
ov = cat(1,ov,'\begin{minipage}{',num2str(w2),'\textwidth}');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,['\includegraphics [width=\textwidth]{',im2,'}']);
ov = cat(1,ov,['\caption{',cap2,'}']);
ov = cat(1,ov,['\label{',lab2,'}']);
ov = cat(1,ov,'\end{minipage}');
end %if
ov = cat(1,ov,'\end{figure}');