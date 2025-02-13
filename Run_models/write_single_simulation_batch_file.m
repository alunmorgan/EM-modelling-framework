function file_loc =write_single_simulation_batch_file(paths, restart_loc, out_loc, scratch_loc, tail,  precision, version)
% This code writes and a shell script so that the
% system environment is reliably used.

% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');



%% Construct file
shell_contents = {'#! /bin/bash'};
shell_contents = cat(1,shell_contents,'# setting the GdfidL version to test');
shell_contents = cat(1,shell_contents,['export GDFIDL_VERSION="', num2str(version),'"']);
shell_contents = cat(1,shell_contents,['DATA_DIR="', out_loc, '"']);
shell_contents = cat(1,shell_contents,['SCRATCH_DIR="', scratch_loc, '"']);
shell_contents = cat(1,shell_contents,['RESTART_DIR="', restart_loc, '"']);
shell_contents = cat(1,shell_contents,'# Making temporary folder names with shorter path length.');
shell_contents = cat(1,shell_contents,['TEMP_OUT="', paths.data_loc,'/temp_out',num2str(tail), '"']);
shell_contents = cat(1,shell_contents,['TEMP_SCRATCH="', paths.data_loc, '/temp_scratch',num2str(tail), '"']);
shell_contents = cat(1,shell_contents,['TEMP_RESTART="', paths.data_loc, '/temp_restart',num2str(tail), '"']);
shell_contents = cat(1,shell_contents,'#  Using soft links to truncate the file paths as this causes problems with the underlying FORTRAN.');
shell_contents = cat(1,shell_contents,'ln -s $DATA_DIR $TEMP_OUT');
shell_contents = cat(1,shell_contents,'ln -s $SCRATCH_DIR $TEMP_SCRATCH');
shell_contents = cat(1,shell_contents,'ln -s $RESTART_DIR $TEMP_RESTART');

if strcmp(precision, 'single')
    shell_contents = cat(1,shell_contents,'single.gd1 < $TEMP_OUT/model.gdf $TEMP_OUT/model_log');
elseif strcmp(precision, 'double')
    shell_contents = cat(1,shell_contents,'gd1 < $TEMP_OUT/model.gdf > $TEMP_OUT/model_log');
end %if
shell_contents = cat(1,shell_contents,'# restoring the original version.');
shell_contents = cat(1,shell_contents,['export GDFIDL_VERSION="', num2str(orig_ver),'"']);
shell_contents = cat(1,shell_contents,'#  removing the soft links.');
shell_contents = cat(1,shell_contents,'rm $TEMP_OUT');
shell_contents = cat(1,shell_contents,'rm $TEMP_SCRATCH');
shell_contents = cat(1,shell_contents,'rm $TEMP_RESTART');

%% Write file
file_loc = fullfile(out_loc, 'run_model.sh');
write_out_data( shell_contents, file_loc )
pause(5)
 make_file_executable(file_loc)