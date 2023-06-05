function postprocess_s_parameters(data_directory, output_directory)
% Runs the GdfidL postprocessor on the selected data.
% The model data has already been selected using soft links.
%
% s_parameter_data is
%
%Example: s_parameter_data = postprocess_s_parameters


%% S PARAMETER POSTPROCESSING
% creating_space_for_postprocessing(fullfile('pp_link', 'sparameter'), 'sparameter', model_name);
[s_names, ~] = dir_list_gen(data_directory, 'dirs', 1);
s_parameter_data_directory = cell(length(s_names),1);
s_parameter_output_directory = cell(length(s_names),1);
for osw = 1:length(s_names)
        s_parameter_data_directory{osw} = fullfile(data_directory, s_names{osw});
        s_parameter_output_directory{osw} = fullfile(output_directory, s_names{osw});
   if ~exist(s_parameter_output_directory{osw}, 'dir')
        mkdir(s_parameter_output_directory{osw});
   end %if
end %for

s_port = cell(length(s_names),1);
% finding the names of all the ports.
% [temp, ~]  = dir_list_gen(fullfile(data_directory, s_names{1}), 'dirs', 1);
% temp = temp( find_position_in_cell_lst((strfind(temp, 'Port='))));
% all_ports = regexprep(temp, 'Port=','');

for osw = 1:length(s_names)

    if exist(fullfile(s_parameter_data_directory{osw},'model_log'), 'file') ~= 2
        fprinf(['\nMissing log file in ' s_parameter_data_directory{osw}]);
        continue
    end %if
    copyfile(fullfile(s_parameter_data_directory{osw},'model.gdf'),...
        fullfile(s_parameter_output_directory{osw}, 'model.gdf'));
    copyfile(fullfile(s_parameter_data_directory{osw},'model_log'), ...
        fullfile(s_parameter_output_directory{osw}, 'model_log'));
    copyfile(fullfile(s_parameter_data_directory{osw}, 'run_inputs.mat'),...
        fullfile(s_parameter_output_directory{osw}, 'run_inputs.mat'));
    % Load up the original model input parameters.
    load(fullfile(s_parameter_output_directory{osw}, 'run_inputs.mat'), 'modelling_inputs')
    % find the port number of the excitation
    excite = regexp(s_parameter_data_directory{osw}, 'port_(.*)_excitation', 'tokens');
    excite = excite{1}{1};
    s_set = regexp(s_parameter_data_directory{osw}, 'set_(.*)_port_.*_excitation', 'tokens');
    s_set = s_set{1}{1};
    s_port{osw} = excite;
%     set{osw} = s_set;
    pp_s_input_file = GdfidL_write_pp_s_param_input_file(s_parameter_data_directory{osw});
    pp_output_name = fullfile(s_parameter_output_directory{osw} ,['model_s_param_set_',s_set, '_',excite,'_post_processing_input_file']);
    write_out_data(pp_s_input_file, pp_output_name )
    
    postprocess_core(s_parameter_output_directory{osw}, modelling_inputs.version, 'sparameter', s_set, excite, 'pp_input_file', pp_output_name);
end