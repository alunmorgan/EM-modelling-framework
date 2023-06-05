function data_rate = GdfidL_find_data_rate(wn, input_file_path, model_name, run_inputs, dp, defs)
% Runs the model with a very short wake on the given number of cores.
% returns the data rate /calculation speed.
%
% data_rate is
% wn is
% input_file_path is
% model_name is
% run_inputs is
% dp is a flag to say if you want single precision (0) or double precision (1).
% defs is
%
% Example: data_rate = GdfidL_find_data_rate(wn, input_file_path, model_name, run_inputs, dp, defs)
r = num2str(round(rand*1e4));
if ~exist(['/tmp/',r,'/temp_data'],'dir')
    mkdir(['/tmp/',r,'/temp_data'])
end
if ~exist(['/tmp/',r,'/temp_scratch'],'dir')
    mkdir(['/tmp/',r,'/temp_scratch'])
end
if ~exist(['/tmp/',r,'/temp_restart'],'dir')
    mkdir(['/tmp/',r,'/temp_restart'])
end
tmp_inputs = run_inputs;
tmp_inputs{11} = '0.1';
contruct_gdf_file(input_file_path, model_name, ['/tmp/',r,'/'], 'temp', num2str(wn), tmp_inputs, defs)
if dp == 1
stat = system(['gd1 < ', '/tmp/',r,'/temp.gdf > ', '/tmp/',r,'/gdfidl_log']);
elseif dp == 0
stat = system(['single.gd1 < ', '/tmp/',r,'/temp.gdf > ', '/tmp/',r,'/gdfidl_log']);
end
if stat ~= 0
    % if the system command has not run properly.
    data_rate = NaN;
else
    try
        % if the log is corrupted then it probably seg faulted. Used
        % the previous settings as the best available.
        % OR just still in the PML so no rate will be output. in which
        % case rerun with a slightly longer wake.
        [log, ~] = GdfidL_read_log(['/tmp/',r,'/gdfidl_log']);
        data_rate = log.wall_rate;
    catch
        fprintf('\nTrying a slightly longer wake')
        for sswe = 2:10
            tmp_inputs = run_inputs;
            tmp_inputs{11} = num2str(sswe/10);
            contruct_gdf_file(input_file_path, model_name, ['/tmp/',r,'/'], 'temp', num2str(wn), tmp_inputs)
            if dp == 1
                stat = system(['gd1 < ', '/tmp/',r,'/temp.gdf > ', '/tmp/',r,'/gdfidl_log']);
            elseif dp == 0
                stat = system(['single.gd1 < ', '/tmp/',r,'/temp.gdf > ', '/tmp/',r,'/gdfidl_log']);
            end
            [log,~] = GdfidL_read_log('/tmp/',r,'/gdfidl_log');
            if log.wall_rate ~= 0
                data_rate = log.wall_rate;
                break
            end
        end
    end
end
% using the try catch as the network is sometimes slow at updating the file
% list and so this code errors out as it thinks there is nothing to
% remove.
try
    rmdir(['/tmp/',r], 's')
catch
    try
        rmdir(['/tmp/',r], 's')
    catch
        fprintf(['\nCould not remove the ', r,' folder in the /tmp directory'])
    end
end