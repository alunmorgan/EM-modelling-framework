function s_parameter_data = postprocess_s_parameters
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% s_parameter_data is 
%
%Example: s_parameter_data = postprocess_s_parameters

%% S PARAMETER POSTPROCESSING
% run the s parameter postprocessor
[s_names, pth] = dir_list_gen('data_link/s_parameters/', 'dirs', 1);
% ind_tmp = find_position_in_cell_lst(strfind(s_names,'.'));
% s_names(ind_tmp) = [];
s_port = cell(length(s_names),1);
% finding the names of all the ports.
[temp, ~]  = dir_list_gen([pth, s_names{1}], '', 1);
temp = temp( find_position_in_cell_lst((strfind(temp, 'Port='))));
all_ports = regexprep(temp, 'Port=','');

for osw = 1:length(s_names)
    % find the port number of the excitation
    excite = regexp([pth, s_names{osw}], 'port_(.*)_excitation', 'tokens');
    excite = excite{1}{1};
        [~] = system(['mkdir ', fullfile('pp_link', 's_parameters',['model_s_param_',excite,'_post_processing'])]);
    s_port{osw} = excite;
    GdfidL_write_pp_s_param_input_file(excite)
    temp_files('make')
    [~]=system(['gd1.pp < ', ...
        fullfile('pp_link', 's_parameters', ['model_s_param_',excite,'_post_processing'], ['model_s_param_',excite,'_post_processing_input_file']), ' > ',...
        fullfile('pp_link', 's_parameters', ['model_s_param_',excite,'_post_processing'], ['model_s_param_',excite,'_post_processing_log'])]);
    %% find the location of all the required output files
    s_mat = GdfidL_find_s_parameter_ouput('temp_scratch');
    [s_scale(osw,:),  s_data(osw,:)] = read_s_param_datafiles(s_mat);
    temp_files('remove')
    delete('POSTP-LOGFILE');
    delete('WHAT-PP-DID-SPIT-OUT');
end

s_parameter_data.all_ports = all_ports;
s_parameter_data.port_list = s_port;
s_parameter_data.scale = s_scale{1,1}(1,:);
s_parameter_data.data = s_data;