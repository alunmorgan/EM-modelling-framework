function plot_single_set(model_set, types, override)
% Runs the plotting  for a single model set.
%   Args:
%       model_set(str): Name of model set to run.
%       types(cell of strings/char): Types of plotting to run.
%       override(cell of strings/char): Override status of each entry in types.

diary off
load_local_paths

diary on
ppi = analysis_settings;

try
    datasets = find_datasets(fullfile(results_loc, model_set));
    plot_model(datasets, ppi, override, types);
catch ME5
    display_error_message(ME5)
end %try

diary off