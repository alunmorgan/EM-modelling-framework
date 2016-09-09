function process_tex(output_path, file_name)
% Finds and processes the requested tex file in the output path.
%
% example: process_tex(output_path, file_name)
old_path = pwd;
cd(output_path)
system(['latex -etex ', file_name,'.tex'])
system(['latex -etex ', file_name,'.tex'])
system(['latex -etex ', file_name,'.tex'])
system(['dvipdf ', file_name,'.dvi'])
delete([file_name, '.dvi'])
delete([file_name, '.aux'])
delete([file_name, '.log'])
delete([file_name, '.out'])
delete([file_name, '.toc'])
cd(old_path)