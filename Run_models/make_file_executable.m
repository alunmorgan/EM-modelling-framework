function make_file_executable(file_loc)

[status, cmd_out] = fileattrib(file_loc, '+x', 'a');
if status == 0
    fprintf(['\nERROR setting permissions on run file', cmd_out])
    % probably a slow file system update
    fprintf('\nWaiting for filesystem')
    pause(5)
    [status, cmd_out] = fileattrib(file_loc, '+x', 'a');
    if status ==0
        fprintf(['\nERROR setting permissions on run file', cmd_out])
    end %if
end %if