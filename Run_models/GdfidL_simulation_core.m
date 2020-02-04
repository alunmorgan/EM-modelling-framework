function GdfidL_simulation_core(version, precision)
% This runs the core simulation code.

% setting the GdfidL version to test
orig_ver = getenv('GDFIDL_VERSION');
setenv('GDFIDL_VERSION',version);
if strcmp(precision, 'single')
    [status, ~] = system('nice single.gd1 < temp_data/model.gdf > temp_data/model_log');
elseif strcmp(precision, 'double')
    [status, cmd_output] = system('nice gd1 < temp_data/model.gdf > temp_data/model_log');
end %if
% restoring the original version.
setenv('GDFIDL_VERSION',orig_ver);
if status ~= 0
    disp(['Look at model log', cmd_output])
end %if