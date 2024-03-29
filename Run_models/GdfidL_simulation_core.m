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
if strcmp(precision, 'single')
    shell_contents = cat(1,shell_contents,['single.gd1 ',restart,'< model.gdf > model_log']);
elseif strcmp(precision, 'double')
    shell_contents = cat(1,shell_contents,['gd1 ',restart,'< model.gdf > model_log']);
end %if
cd temp_data
write_out_data( shell_contents, 'run_model.sh' )
[~] = system('chmod +x run_model.sh');
!./run_model.sh
cd ..
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
