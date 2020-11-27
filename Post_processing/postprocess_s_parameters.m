function s_parameter_data = postprocess_s_parameters(model_name)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% s_parameter_data is
%
%Example: s_parameter_data = postprocess_s_parameters


%% S PARAMETER POSTPROCESSING
% run the s parameter postprocessor
% [freq_folders] = dir_list_gen(fullfile('data_link', 's_parameter'),'dirs', 1);
creating_space_for_postprocessing(fullfile('pp_link', 's_parameter'), 's_parameter', model_name);
[s_names, pth] = dir_list_gen(fullfile('data_link', 's_parameter'), 'dirs', 1);
% ind_tmp = find_position_in_cell_lst(strfind(s_names,'.'));
% s_names(ind_tmp) = [];
s_port = cell(length(s_names),1);
% finding the names of all the ports.
[temp, ~]  = dir_list_gen([pth, s_names{1}], '', 1);
temp = temp( find_position_in_cell_lst((strfind(temp, 'Port='))));
all_ports = regexprep(temp, 'Port=','');

for osw = 1:length(s_names)
    data_directory = fullfile(pth, s_names{osw});
    s_parameter_output_directory = fullfile('pp_link', 's_parameter', s_names{osw});
    if exist(fullfile(data_directory,'model_log'), 'file') ~= 2
        warning(['Missing log file in ' data_directory]);
        continue
    end %if
    [~] = system(['mkdir ', s_parameter_output_directory]);
    copyfile(fullfile(data_directory,'model.gdf'),...
        fullfile(s_parameter_output_directory, 'model.gdf'));
    copyfile(fullfile(data_directory,'model_log'), ...
        fullfile(s_parameter_output_directory, 'model_log'));
    copyfile(fullfile(data_directory, 'run_inputs.mat'),...
        fullfile(s_parameter_output_directory, 'run_inputs.mat'));
    % Load up the original model input parameters.
    load(fullfile(s_parameter_output_directory, 'run_inputs.mat'), 'modelling_inputs')
    % find the port number of the excitation
    excite = regexp([pth, s_names{osw}], 'port_(.*)_excitation', 'tokens');
    excite = excite{1}{1};
    s_set = regexp([pth, s_names{osw}], 'set_(.*)_port_.*_excitation', 'tokens');
    s_set = s_set{1}{1};
    s_port{osw} = excite;
    set{osw} = s_set;
    pp_s_input_file = GdfidL_write_pp_s_param_input_file(s_set, excite);
    write_out_data(pp_s_input_file, fullfile(s_parameter_output_directory ,['model_s_param_set_',s_set, '_',excite,'_post_processing_input_file']) )
    
    postprocess_core(s_parameter_output_directory, modelling_inputs.version, 's_parameter', s_set, excite);
    s_mat = GdfidL_find_s_parameter_ouput(s_parameter_output_directory);
    [s_scale(osw,:),  s_data(osw,:)] = read_s_param_datafiles(s_mat);
end

s_parameter_data.all_ports = all_ports;
s_parameter_data.port_list = s_port;
s_parameter_data.scale = s_scale;
s_parameter_data.data = s_data;
s_parameter_data.set = set;