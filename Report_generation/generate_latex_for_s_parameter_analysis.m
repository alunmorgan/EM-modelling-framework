function ov = generate_latex_for_s_parameter_analysis
% Generates latex code based on the wake simulation results.
% Wraps latex code around the pre generated S parameter results images.
%
% ov is the output latex code.
%
% Example: ov = generate_latex_for_s_parameter_analysis
ov = cell(1,1);
ov = cat(1,ov,'\chapter{S parameters}');
    ov = cat(1,ov,'\begin{figure}[htb]');
    ov = cat(1,ov,'\begin{center}');
    ov = cat(1,ov,'\includegraphics [width=0.96\textwidth]{all_sparameters.eps}');
    ov = cat(1,ov,'\caption{Most dominant s parameters.}');
    ov = cat(1,ov,'\end{center}');
    ov = cat(1,ov,'\end{figure}');
    ov = cat(1,ov,'\clearpage');
   [s_list,dirs] =  dir_list_gen('pp_link/s_parameter','eps',1);
   s_ind = find_position_in_cell_lst(strfind(s_list, 's_parameters_'));
   s_list = s_list(s_ind);
   len_s = length(s_list);
   for newq = 1:4:len_s
       if newq+3 > len_s
           s_list{newq+3} = [];
       end
       ov1 = latex_side_by_side_images([dirs{newq},s_list{newq}],...
           [dirs{newq+1}, s_list{newq+1}],'','');
       ov = cat(1,ov,ov1);
       ov1 = latex_side_by_side_images([dirs{newq+2},s_list{newq+2}],...
           [dirs{newq+3}, s_list{newq+3}],'','');
       ov = cat(1,ov,ov1);
       ov = cat(1,ov,'\clearpage');
   end