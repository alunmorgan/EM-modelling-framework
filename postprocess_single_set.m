function postprocess_single_set(model_set, input_file_loc, logging_root, varargin)
% Runs the postprocessing, analysis, plotting and report generation for a single
% model set.

% sim_types = {'wake', 'sparameter', 'eigenmode', 'lossy_eigenmode', 'shunt'};
binary_string = {'yes', 'no'};
p = inputParser;
p.StructExpand = false;
p.CaseSensitive = false;
addRequired(p, 'model_set');
addRequired(p, 'input_file_loc');
addRequired(p, 'logging_root');
addParameter(p, 'skip_postprocessing', {});
addParameter(p, 'skip_analysis', {});
addParameter(p, 'postprocessing_override','no', @(x) any(validatestring(x,binary_string)));
addParameter(p, 'analysis_override', 'no', @(x) any(validatestring(x,binary_string)));
addParameter(p, 'plotting_override', 'no', @(x) any(validatestring(x,binary_string)));

parse(p, model_set, input_file_loc, logging_root, varargin{:});

if strcmp(p.Results.postprocessing_override, 'yes')
    postprocessing_override = 'no_skip';
else
    postprocessing_override = 'skip';
end %if

if strcmp(p.Results.analysis_override, 'yes')
    analysis_override = 'no_skip';
else
    analysis_override = 'skip';
end %if

if strcmp(p.Results.plotting_override, 'yes')
    plotting_override = 'no_skip';
else
    plotting_override = 'skip';
end %if

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
    if ~any(contains(p.Results.skip_postprocessing, 'wake'))
        postprocess_model_sets(input_file_loc, model_set, postprocessing_override, {'wake'})
    end %if
    if ~any(contains(p.Results.skip_analysis, 'wake'))
        analyse_models_sets(model_set, analysis_override);
        get_wlf(model_set, analysis_override);
    end %if
catch ME1
    display_error_message(ME1)
end %try
try
    if ~any(contains(p.Results.skip_postprocessing, 'eigenmode'))
        postprocess_model_sets(input_file_loc, model_set, postprocessing_override, {'eigenmode'})
    end %if
catch ME2
    display_error_message(ME2)
end %try
try
    if ~any(contains(p.Results.skip_postprocessing, 'lossy_eigenmode'))
        postprocess_model_sets(input_file_loc, model_set, postprocessing_override, {'lossy_eigenmode'})
    end %if
    if ~any(contains(p.Results.skip_analysis, 'lossy_eigenmode'))
        makeLossyEigenmodeSummaryTable(model_set{1}, results_loc)
    end %if
catch ME3
    display_error_message(ME3)
end %try
try
    if ~any(contains(p.Results.skip_postprocessing, 's_parameter'))
        postprocess_model_sets(input_file_loc, model_set, postprocessing_override, {'s_parameter'})
    end %if
catch ME4
    display_error_message(ME4)
end %try
try
    datasets = find_datasets(fullfile(results_loc, model_set{1}));
    plot_model(datasets, ppi, plotting_override, {'all'});
catch ME5
    display_error_message(ME5)
end %try
% try
%     generate_report_sets(model_set)
% catch ME6
%     display_error_message(ME6)
% end %try
diary off