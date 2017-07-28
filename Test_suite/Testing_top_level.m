%Testing_top_level

% Before this framework will work it needs to be provided with various
% paths in a file called load_local_paths.m
% Inside this file are the following variables:
% All are strings.
%
% For the simulation and postprocessing:
% input_file_loc => The path to the directory containing the model
%                   definition files.
% scratch_loc => The path to be used for storing temporary files generated
%                during the simulation.
% data_loc => The path to store the results of the simulation. A model and
%             run specific folder will be generated under this location
% results_loc => The path to store the results from the postprocessing.
%                Appropriate sub folders will be created.
%
% For the report generation:
% graphic_loc => the full path to an eps file contianing the logo you wish
%                to appear on the report.
% Author => Name(s) to appear on the report.
%
% Additionally if you want the report generation you will require latex to
% be installed on the machine.


load_local_paths

log = {'Log of problems'};
% base_model_names = {'cylindrical_pillbox_with_port'};  
base_model_names = {...
    'cylindrical_pillbox', ...
    'cylindrical_pillbox_with_port',...
    'cylindrical_pillbox_with_4ports',...
    'cylindrical_pillbox_with_racetrack',...
    'cylindrical_pillbox_with_racetrack_with_port',...
    'cylindrical_pillbox_with_racetrack_with_4ports'...
    };

%% Running the tests
for ha = 1:length(base_model_names)
    try
        Testing_function = str2func(['Testing_', base_model_names{ha}]);
        Testing_function(input_file_loc, scratch_loc,...
            data_loc)
    catch
        log{end+1} = ['Running model ',base_model_names{ha}, ' failed'];
        warning(['Running model ', base_model_names{ha}, ' failed'])
    end
end

%% Post processing
for ha = 1:length(base_model_names)
    try
        postprocessor_setup(base_model_names{ha}, ...
            scratch_loc, data_loc, results_loc)
    catch
        log{end+1} = ['Postprocessing ', base_model_names{ha}, 'failed'];
        warning(['Postprocessing ', base_model_names{ha}, ' failed'])
    end
end

disp('Generating the individual reports')
%% Generate all the new reports
for md = 1:length(base_model_names)
    generate_report_set(base_model_names{md}, Author, graphic_loc, results_loc)
end

%% Generate the overview reports
disp('Generating the combined reports')
% Generate all the blended reports using all available data.
for md = 1:length(base_model_names)
       Blend_reports(results_loc, base_model_names{md}, Author, graphic_loc)
end