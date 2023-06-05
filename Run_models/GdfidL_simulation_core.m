function GdfidL_simulation_core(loc, version, precision, restart)
% This runs the core simulation code.

% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',version);

shell_contents = {'#! /bin/bash'};
% This code used to call GdfidL directly using the system command. However some
% problems were found with differences in the shell vs matlab environment.
% As a result this code now writes and executes a shell script so that the
% system environment is reliably used.
if strcmp(precision, 'single')
    shell_contents = cat(1,shell_contents,['single.gd1 ',restart,'< ', fullfile(loc, 'model.gdf'),' > ', fullfile(loc, 'model_log')]);
elseif strcmp(precision, 'double')
    shell_contents = cat(1,shell_contents,['gd1 ',restart,'< ', fullfile(loc, 'model.gdf'),' > ',fullfile(loc, 'model_log')]);
end %if
write_out_data( shell_contents, fullfile(loc, 'run_model.sh') )
pause(5)
[status, cmd_out] = fileattrib(fullfile(loc, 'run_model.sh'), '+x', 'a');
if status == 0
    fprintf(['\nERROR setting permissions on run file', cmd_out])
    % probably a slow file system update
    fprintf('\nWaiting for filesystem')
    pause(5)
    [status, cmd_out] = fileattrib(fullfile(loc, 'run_model.sh'), '+x', 'a');
    if status == 1
        pause(20) % problem with slow filesystem update
        [run_script_status, run_script_command] = system(['sh ', fullfile(loc, 'run_model.sh')]);
        if run_script_status ~= 0
            fprintf(run_script_command)
        end %if
    else
        fprintf(['\nERROR setting permissions on run file', cmd_out])
    end %if
else
    pause(20) % problem with slow filesystem update
    [run_script_status, run_script_command] = system(['sh "', fullfile(loc, 'run_model.sh"')]);
    if run_script_status ~= 0
        fprintf(run_script_command) % a 127 error probably means the simulation is complaining about something. Check the model log.
    end %if
end %if
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);