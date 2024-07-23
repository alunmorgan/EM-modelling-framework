function GdfidL_simulation_core(loc, version, precision, restart)
% This runs the core simulation code.

% This code used to call GdfidL directly using the system command. However some
% problems were found with differences in the shell vs matlab environment.
% As a result this code now writes and executes a shell script so that the
% system environment is reliably used.
write_single_simulation_batch_file(precision, restart, loc, version)

pause(20) % problem with slow filesystem update
[run_script_status, run_script_command] = system(['sh "', fullfile(loc, 'run_model.sh"')]);
if run_script_status ~= 0
    fprintf(run_script_command) % a 127 error probably means the simulation is complaining about something. Check the model log.
end %if

