function write_single_simulation_batch_file(paths, restart_loc, out_loc, scratch_loc, tail,  precision, version)
% This code writes and a shell script so that the
% system environment is reliably used.

% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');



%% Construct file
shell_contents = {'#! /bin/bash'};
% setting the GdfidL version to test
shell_contents = cat(1,shell_contents,['export GDFIDL_VERSION="', num2str(version),'"']);
%Making temporary folder names with shorter path length.
shell_contents = cat(1,shell_contents,['TEMP_OUT=', paths.data_loc,'/temp_out',num2str(tail)]);
shell_contents = cat(1,shell_contents,['TEMP_SCRATCH=', paths.data_loc, '/temp_scratch',num2str(tail)]);
shell_contents = cat(1,shell_contents,['TEMP_RESTART=', paths.data_loc, '/temp_restart',num2str(tail)]);
% Making temporaray files
shell_contents = cat(1,shell_contents,['mkdir ', TEMP_OUT]);
shell_contents = cat(1,shell_contents,['mkdir ', TEMP_SCRATCH]);
shell_contents = cat(1,shell_contents,['mkdir ', TEMP_RESTART]);
% Using soft links to truncate the file paths as this causes problems
% with the underlying FORTRAN.
shell_contents = cat(1,shell_contents,['ln -s ', out_loc, ' ' , TEMP_OUT]);
shell_contents = cat(1,shell_contents,['ln -s ', scratch_loc, ' ', TEMP_SCRATCH]);
shell_contents = cat(1,shell_contents,['ln -s ', restart_loc, ' ', TEMP_RESTART]);

if strcmp(precision, 'single')
    shell_contents = cat(1,shell_contents,['single.gd1 ',restart,'< ', fullfile(TEMP_OUT, 'model.gdf'),' > ', fullfile(TEMP_OUT, 'model_log')]);
elseif strcmp(precision, 'double')
    shell_contents = cat(1,shell_contents,['gd1 ',restart,'< ', fullfile(TEMP_OUT, 'model.gdf'),' > ',fullfile(TEMP_OUT, 'model_log')]);
end %if
shell_contents = cat(1,shell_contents,['unlink ', TEMP_OUT]);
shell_contents = cat(1,shell_contents,['unlink ', TEMP_SCRATCH]);
shell_contents = cat(1,shell_contents,['unlink ', TEMP_RESTART]);
% restoring the original version.
shell_contents = cat(1,shell_contents,['export GDFIDL_VERSION="', num2str(orig_ver),'"']);
%% Write file
write_out_data( shell_contents, fullfile(out_loc, 'run_model.sh') )
pause(5)
[status, cmd_out] = fileattrib(fullfile(out_loc, 'run_model.sh'), '+x', 'a');
if status == 0
    fprintf(['\nERROR setting permissions on run file', cmd_out])
    % probably a slow file system update
    fprintf('\nWaiting for filesystem')
    pause(5)
    [status, cmd_out] = fileattrib(fullfile(out_loc, 'run_model.sh'), '+x', 'a');
    if status ==0
        fprintf(['\nERROR setting permissions on run file', cmd_out])
    end %if
end %if