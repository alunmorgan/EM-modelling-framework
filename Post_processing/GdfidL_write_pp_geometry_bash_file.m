function file_loc = GdfidL_write_pp_geometry_bash_file(data_directory, pp_directory)
% Writes the postprocessing input file for an eigenmode simulation.
%
% log is a structure containing the information extracted from the log
% files.
% n_modes_range(list): the modes numbers to consider.
% log (struct): data extracted from postprocessing log file.
%
% example: GdfidL_write_pp_eigenmode_input_file(data_directory, pp_directory, log, pp_type, pp_settings)
% This code writes and a shell script so that the
% system environment is reliably used.


%% Construct file
shell_contents = {'#! /bin/bash'};
shell_contents = cat(1,shell_contents,['DATADIR=', data_directory]);
shell_contents = cat(1,shell_contents,['PPDIR=', pp_directory]);
shell_contents = cat(1,shell_contents,'# copy everything in the data folder to the postprocessing folder.');
shell_contents = cat(1,shell_contents, 'mv $DATADIR/* $PPDIR'); 
shell_contents = cat(1,shell_contents,'# ');
shell_contents = cat(1,shell_contents,'# convert the gld files for the field output images to ps and fix the naming then remove the ps files.');
shell_contents = cat(1,shell_contents,'cd $PPDIR');
shell_contents = cat(1,shell_contents,'ls | grep ''\.ps$'' |sed ''s/ps/ps/p'' |sed -e ''/ps/{:i'' -e ''n;s//png/;t'' -e ''b i'' -e ''}'' | ionice nice xargs -P$(nproc) -n 3 bash -c ''convert $0 -rotate -90 $1 && rm $0''');
shell_contents = cat(1,shell_contents,'wait');

%% Write file
file_loc = fullfile(pp_directory, 'pp_model.sh');
write_out_data( shell_contents, file_loc )
pause(5)
 make_file_executable(file_loc)