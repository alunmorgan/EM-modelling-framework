function process_tex(output_path, file_name)
% Finds and processes the requested tex file in the output path.
%
% example: process_tex(output_path, file_name)
old_path = pwd;
cd(output_path)
fprintf(['Processing latex file. ', output_path, '/',file_name])
latex_cmd = 'latex -etex -interaction nonstopmode -halt-on-error ';
[status(1), log] = system([latex_cmd, file_name,'.tex']);
fprintf('.')
[status(2), log] = system([latex_cmd, file_name,'.tex']);
fprintf('.')
[status(3), log] = system([latex_cmd, file_name,'.tex']);
fprintf('.')
file_ID = fopen([file_name, '_latex_log'], 'w');
fwrite(file_ID,log);
fclose(file_ID);
if sum(status) >0
    warning(['Error in latex processing. See ', output_path, '/', file_name, '_latex_log for details'])
end
[conversion_status, ~] = system(['dvipdf ', file_name,'.dvi']);
fprintf('. ')
if conversion_status >0
    warning('Error in converting dvi to pdf')
end
disp('Cleaning up')
delete([file_name, '.dvi'])
fprintf('20%% ')
delete([file_name, '.aux'])
fprintf('40%% ')
delete([file_name, '.log'])
fprintf('60%% ')
delete([file_name, '.out'])
fprintf('80%% ')
delete([file_name, '.toc'])
fprintf('100%% \n')
cd(old_path)