function ov = latex_single_image(image, cap, wdth)
% Writes latex code for placing two images side by side.
% Can also be used with a single images by passing [] to the other input.

ov = cell(1,1);
ov = cat(1,ov,'\begin{figure}[htb]');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,['\begin{minipage}{',num2str(wdth),'\textwidth}']);
ov = cat(1,ov,'\centering');
if ~isempty(image)
    ov = cat(1,ov,['\includegraphics [width=\textwidth]{',image,'}']);
    ov = cat(1,ov,['\caption{',cap,'}']);
end
ov = cat(1,ov,'\end{minipage}%');
ov = cat(1,ov,'\end{figure}');