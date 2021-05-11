function postprocess_single_set(model_set, input_file_loc, logging_root)
% Runs the postprocessing, analysis, plotting and report generation for a single
% model set.

diary off
stamp = regexprep(datestr(now),':', '-');
load_local_paths
if ~exist(fullfile(logging_root, model_set{1}), 'dir')
    mkdir(fullfile(logging_root, model_set{1}))
end %if
diary(fullfile(logging_root, model_set{1}, stamp));
diary on
ppi = analysis_settings;
input_settings = analysis_model_settings_library(model_set{1});

try
    postprocess_model_sets(input_file_loc, model_set, 'skip', {'wake'})
    analyse_models_sets(model_set, 'skip');
    get_wlf(model_set);
catch ME1
    display_error_message(ME1)
end %try
try
    postprocess_model_sets(input_file_loc, model_set, 'skip', {'eigenmode'})
catch ME2
    display_error_message(ME2)
end %try
try
    postprocess_model_sets(input_file_loc, model_set, 'skip', {'lossy_eigenmode'})
    makeLossyEigenmodeSummaryTable(model_set{1}, results_loc)
catch ME3
    display_error_message(ME3)
end %try
try
    postprocess_model_sets(input_file_loc, model_set, 'skip', {'s_parameter'})
catch ME4
    display_error_message(ME4)
end %try
try
    datasets = find_datasets(fullfile(results_loc, model_set{1}));
    plot_model(datasets, ppi, input_settings, 'no_skip', {'all'});
catch ME5
    display_error_message(ME5)
end %try
try
    generate_report_sets(model_set)
catch ME6
    display_error_message(ME6)
end %try
diary off