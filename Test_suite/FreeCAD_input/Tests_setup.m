function run_inputs = Tests_setup(model_name)
%

path_to_code = which(['Testing_', model_name]);
[pathstr, ~, ~] = fileparts(path_to_code);

% input_file_loc is the location of the model input files.
% scratch_loc is the location of the temporary file space. Nothing is kept here.
% data_loc is the location to store the data generated from the modelling run.
load_local_paths_testing
 store = fullfile(data_loc, model_name);
 input = fullfile(input_folder_loc, model_name);
 
 %% Creating folders
 if exist(input, 'dir') ~= 7
 mkdir(input)
 end %if
 if exist(store, 'dir') ~= 7
 mkdir(store)
 end %if
%% Copying the EM setup files.
%geometry-material-map.txt is used for mapping materials to geometric parts.
% mesh_definition.txt is used for defining the extent and the density of the mesh.
%Also boundary conditions.
% port_definition.txt is used for defining port locations and parameters.
copyfile(fullfile(pathstr, '*.txt'),...
    store);

%% Adding locations to the data structure.
% Location of the temporary file space. Nothing is kept here.
run_inputs.paths.scratch_path = scratch_loc;
% Location of the model input files.
run_inputs.paths.input_file_path = input;
% Location to store the data generated from the modelling run.
run_inputs.paths.storage_path = store;

%% Adding list of model names to run.
[run_inputs.model_names, ~] = dir_list_gen(run_inputs.paths.input_file_path, 'dirs',1);
run_inputs.base_model_ind = find_position_in_cell_lst(strfind(run_inputs.model_names, '_Base'));
run_inputs.base_model_name = regexprep(run_inputs.model_names{run_inputs.base_model_ind}, '_Base', '');


%% Extracting data for each model
% for nd = 1:length(run_inputs.model_names)
%      temp_model = fullfile(run_inputs.paths.input_file_path, run_inputs.model_names{nd});
%     % The model set (parameter sweep) to associate each model to.
% %     if nd ~= run_inputs.base_model_ind
% %         run_inputs.model_set{nd} = regexprep(run_inputs.model_names{nd}, ...
% %             [run_inputs.base_model_name, '_(.*)?_value_.*'], '$1' );
% %     else
% %         run_inputs.model_set{nd} ='Base';
% %     end %if
%     
% %     % Create model_data file from STL file.
% %     create_model_data_file_for_STL(temp_model)
%     
%     % Getting geometric parameters for later.
% %     run_inputs.geometry_defs{nd} = get_parameters_from_sidecar_file(...
% %         fullfile(temp_model, [run_inputs.model_names{nd}, '_parameters.txt']));
% end %for

% %% Find the geometric sets (parameter sweeps)
% parameter_set_names = run_inputs.model_set;
% parameter_set_names(run_inputs.base_model_ind) = [];
% run_inputs.parameter_set_names = unique(parameter_set_names);
% 
% for wkf = 1:length(run_inputs.parameter_set_names)
%     temp_sets = find_position_in_cell_lst(strfind(run_inputs.model_names, run_inputs.parameter_set_names{wkf}));
%     run_inputs.parameter_sets{wkf} = sort(cat(2, run_inputs.base_model_ind, temp_sets));
%     clear temp_sets
% end %for



