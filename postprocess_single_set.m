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
try
    postprocess_model_sets(input_file_loc, model_set, 'skip', {'wake'})
    analyse_models_sets(model_set, 'skip');
    plot_models_sets(model_set, 'skip', {'wake'});
    get_wlf(model_set);
catch ME1
    disp(ME1)
end %try
try
    postprocess_model_sets(input_file_loc, model_set, 'no_skip', {'eigenmode'})
    plot_models_sets(model_set, 'no_skip', {'eigenmode'});
catch ME2
    disp(ME2)
end %try
try
    postprocess_model_sets(input_file_loc, model_set, 'no_skip', {'s_parameter'})
    plot_models_sets(model_set, 'no_skip', {'s_parameter'});
catch ME3
    disp(ME3)
end %try
try
    generate_report_sets(model_set)
catch ME4
    disp(ME4)
end %try
diary off