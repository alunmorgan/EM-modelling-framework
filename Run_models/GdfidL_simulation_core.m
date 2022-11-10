function GdfidL_simulation_core(version, precision, restart)
% This runs the core simulation code.

% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',version);

shell_contents = {'#! /bin/bash'};
% This code used to call GdfidL directly using the system command. However some
% problems were found with differences in the shell vs matlab environment.
% As a result this code now writes and executes a shell script so that the
% system environment is reliably used.
% shell_contents = cat(1, shell_contents, 'ls -ah');
if strcmp(precision, 'single')
    shell_contents = cat(1,shell_contents,['single.gd1 ',restart,'< model.gdf > model_log']);
elseif strcmp(precision, 'double')
    shell_contents = cat(1,shell_contents,['gd1 ',restart,'< model.gdf > model_log']);
end %if
write_out_data( shell_contents, 'run_model.sh' )
pause(5)
[status, cmd_out] = fileattrib('run_model.sh', '+x', 'a');
if status == 0
    disp(['ERROR setting permissions on run file', cmd_out])
    % probably a slow file system update
    disp('Waiting for filesystem')
    pause(5)
    [status, cmd_out] = fileattrib('run_model.sh', '+x', 'a');
    if status == 1
        pause(20) % problem with slow filesystem update
        dir
        !./run_model.sh
    else
        disp(['ERROR setting permissions on run file', cmd_out])
    end %if
else
    pause(20) % problem with slow filesystem update
    dir
    !./run_model.sh
    
end %if
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);