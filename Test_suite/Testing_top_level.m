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

%% Setting up which versions of GdfidL to use.
versions = {'150717g','150719g', '150923g', '151128g', '160410g','160429g','160517g'};
%versions = {'160517g'};

%% Running the tests
try
    start = now;
    for kse = 1:length(versions)
        Testing_cylindrical_pillbox(input_file_loc, scratch_loc, data_loc, versions{kse})
    end
    fin = now;
    output_loc = [results_loc,'cylindrical_pillbox'];
    postprocessor_setup('cylindrical_pillbox', start, fin, ...
        scratch_loc, data_loc, results_loc, versions)
    Report_setup(Author, 'TEST', graphic_loc, output_loc, start, fin, 'w')
    arc_names = GdfidL_find_selected_models(output_loc, {start, fin});
    Blend_reports( 'Test comparison report', [output_loc,'/'], ...
        arc_names , Author, 'TEST_blend', graphic_loc)
catch
    warning('Test cylindrical_pillbox failed')
end

try
    start = now;
    for kse = 1:length(versions)
        Testing_cylindrical_pillbox_with_port(input_file_loc, scratch_loc, data_loc, versions{kse})
    end
    fin = now;
    output_loc = [results_loc,'cylindrical_pillbox_with_port'];
    postprocessor_setup('cylindrical_pillbox_with_port', start, fin, ...
        scratch_loc, data_loc, results_loc, versions)
    Report_setup(Author, 'TEST', graphic_loc, output_loc, start, fin, 'w')
    arc_names = GdfidL_find_selected_models(output_loc, {start, fin});
    Blend_reports( 'Test comparison report', [output_loc,'/'], ...
        arc_names , Author, 'TEST_blend', graphic_loc)
catch
    warning('Test cylindrical_pillbox_with_port failed')
end

try
    start = now;
    for kse = 1:length(versions)
        Testing_cylindrical_pillbox_with_4ports(input_file_loc, scratch_loc, data_loc, versions{kse})
    end
    fin = now;
    output_loc = [results_loc,'cylindrical_pillbox_with_4ports'];
    postprocessor_setup('cylindrical_pillbox_with_4ports', start, fin, ...
        scratch_loc, data_loc, results_loc, versions)
    Report_setup(Author, 'TEST', graphic_loc, output_loc, start, fin, 'w')
    arc_names = GdfidL_find_selected_models(output_loc, {start, fin});
    Blend_reports( 'Test comparison report', [output_loc,'/'], ...
        arc_names , Author, 'TEST_blend', graphic_loc)
catch
    warning('Test cylindrical_pillbox_with_4ports failed')
end

try
    start = now;
    for kse = 1:length(versions)
        Testing_cylindrical_pillbox_with_racetrack(input_file_loc, scratch_loc, data_loc,versions{kse})
    end
    fin = now;
    output_loc = [results_loc,'cylindrical_pillbox_with_racetrack'];
    postprocessor_setup('cylindrical_pillbox_with_racetrack', start, fin, ...
        scratch_loc, data_loc, results_loc, versions)
    Report_setup(Author, 'TEST', graphic_loc, output_loc, start, fin, 'w')
    arc_names = GdfidL_find_selected_models(output_loc, {start, fin});
    Blend_reports( 'Test comparison report', [output_loc,'/'], ...
        arc_names , Author, 'TEST_blend', graphic_loc)
catch
    warning('Test cylindrical_pillbox_with_racetrack failed')
end

try
    start = now;
    for kse = 1:length(versions)
        Testing_cylindrical_pillbox_with_racetrack_with_port(input_file_loc, scratch_loc, data_loc, versions{kse})
    end
    fin = now;
    output_loc = [results_loc,'cylindrical_pillbox_with_racetrack_with_port'];
    postprocessor_setup('cylindrical_pillbox_with_racetrack_with_port', start, fin, ...
        scratch_loc, data_loc, results_loc, versions)
    Report_setup(Author, 'TEST', graphic_loc, output_loc, start, fin, 'w')
    arc_names = GdfidL_find_selected_models(output_loc, {start, fin});
    Blend_reports( 'Test comparison report', [output_loc,'/'], ...
        arc_names , Author, 'TEST_blend', graphic_loc)
catch
    warning('Test cylindrical_pillbox_with_racetrack_with_port failed')
end

try
    start = now;
    for kse = 1:length(versions)
        Testing_cylindrical_pillbox_with_racetrack_with_4ports(input_file_loc, scratch_loc, data_loc, versions{kse})
    end
    fin = now;
    output_loc = [results_loc,'cylindrical_pillbox_with_racetrack_with_4ports'];
    postprocessor_setup('cylindrical_pillbox_with_racetrack_with_4ports', start, fin, ...
        scratch_loc, data_loc, results_loc, versions)
    Report_setup(Author, 'TEST', graphic_loc, output_loc, start, fin, 'w')
    arc_names = GdfidL_find_selected_models(output_loc, {start, fin});
    Blend_reports( 'Test comparison report', [output_loc,'/'], ...
        arc_names , Author, 'TEST_blend', graphic_loc)
catch
    warning('Test cylindrical_pillbox_with_racetrack_with_4ports failed')
end