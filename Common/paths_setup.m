function run_inputs = paths_setup(model_name)
%
run_inputs.base_model_name = model_name;
path_to_code = which(model_name);
[path_to_input_files, ~, ~] = fileparts(path_to_code);

% input_file_loc is the location of the model input files.
% scratch_loc is the location of the temporary file space. Nothing is kept here.
% data_loc is the location to store the data generated from the modelling run.
% results_loc is the location to put all the post processed data and reports.

% Load the paths associated with the input file set. This is placed one
% level above the py and m files for each model.
addpath(fileparts(path_to_input_files))
paths = load_local_paths;
rmpath(fileparts(path_to_input_files))

store = fullfile(paths.data_loc, model_name);
results_path = fullfile(paths.results_loc, model_name);

%% Creating folders
if exist(results_path, 'dir') ~= 7
    mkdir(results_path)
end %if
if exist(store, 'dir') ~= 7
    mkdir(store)
end %if

%% Adding locations to the data structure.
% Location of the temporary file space. Nothing is kept here.
run_inputs.paths.scratch_path = paths.scratch_loc;
% Location of the framework input files.
run_inputs.paths.input_file_path = paths.inputfile_location;
% Location of the models.
run_inputs.paths.path_to_models = paths.path_to_models;
% Location to store the data generated from the modelling run.
run_inputs.paths.storage_path = store;
% Location to put the post processed output and reports.
run_inputs.paths.results_path = results_path;
% Location of static graphics used in the reports.
run_inputs.paths.graphics_path = paths.graphic_loc;
% Location of restart files. Useful safety next for long running simulations.
run_inputs.paths.restart_files_path = paths.restart_files_path;

%% Adding list of model names to run.
[run_inputs.model_names, ~] = dir_list_gen(fullfile(run_inputs.paths.path_to_models, model_name), 'dirs',1);
run_inputs.base_model_ind = find_position_in_cell_lst(strfind(run_inputs.model_names, '_Base'));
run_inputs.base_model_name = regexprep(run_inputs.model_names{run_inputs.base_model_ind}, '_Base', '');

