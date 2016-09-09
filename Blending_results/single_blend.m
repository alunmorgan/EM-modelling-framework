function single_blend(input_folder, report_title, sources)

% old_loc = pwd;
% cd('/scratch/afdm76')
% make soft links to the data folder and output folder into /scratch.
% this is because the post processor does not handle long paths well.
% this makes things more controlled.
% if exist('blend_link','dir') ~= 0 
%     delete('blend_link')
% end
% [~]=system(['ln -s -T ',input_folder, ' blend_link']);

% delete prior existing folder.
% if exist([input_folder, report_title, slh],'dir') ~= 0 
% %     rmdir([input_folder, report_title, slh])
% end


% [~]=system(['ln -s -T ''',input_folder, report_title, '/''', ' out_link']);
Blend_reports(report_title, input_folder, sources, 'Alun Morgan' , 'TDI-DIA-TS-????')

% if exist('out_link','dir')
%     delete('out_link')
% end
% if exist('blend_link','dir')
%     delete('blend_link')
% end
%  cd(old_loc)   