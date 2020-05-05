function process_tex(output_path, file_name)
% Finds and processes the requested tex file in the output path.
%
% example: process_tex(output_path, file_name)
old_path = pwd;
cd(output_path)
disp(['Processing latex file. ', output_path, '/',file_name])
if ispc == 1
    latex_cmd = '"C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe" -etex -interaction nonstopmode -halt-on-error ';
else
    latex_cmd = 'pdflatex -interaction nonstopmode -halt-on-error ';
end %if
[status(1), ~] = system([latex_cmd, file_name,'.tex']);
fprintf('.')
[status(2), ~] = system([latex_cmd, file_name,'.tex']);
fprintf('.')
[status(3), log] = system([latex_cmd, file_name,'.tex']);
fprintf('.')
file_ID = fopen([file_name, '_latex_log'], 'w');
fwrite(file_ID,log);
fclose(file_ID);
if sum(status) >0
    warning(['Error in latex processing. See ', output_path, '/', file_name, '_latex_log for details'])
end
if exist([file_name, '.dvi'],'file') ~= 0
    [conversion_status, ~] = system(['dvipdf ', file_name,'.dvi']);
    fprintf('. ')
    if conversion_status >0
        warning('Error in converting dvi to pdf')
    end
end %if
disp('Cleaning up')
if exist([file_name, '.dvi'],'file') ~= 0
    delete([file_name, '.dvi'])
end %if
if exist([file_name, '.aux'],'file') ~= 0
    delete([file_name, '.aux'])
end %if
if exist([file_name, '.log'],'file') ~= 0
    delete([file_name, '.log'])
end %if
if exist([file_name, '.out'],'file') ~= 0
    delete([file_name, '.out'])
end %if
if exist([file_name, '.toc'],'file') ~= 0
    delete([file_name, '.toc'])
end %if
cd(old_path)