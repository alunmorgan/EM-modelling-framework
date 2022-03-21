function analyse_single_set(model_set, types)
% Runs the analysis for a single model set.
%   Args:
%       model_set(str): Name of model set to run.
%       types(cell of strings/char): Types of postprocessing to run.
%       override(cell of strings/char): Override status of each entry in types.

diary off
load_local_paths
diary on

try
    if any(contains(types, 'wake'))
        analyse_models_sets({model_set});
        get_wlf({model_set});
    end %if
catch ME1
    display_error_message(ME1)
end %try

try
    if any(contains(types, 'lossy_eigenmode'))
        makeLossyEigenmodeSummaryTable(model_set, results_loc)
    end %if
catch ME3
    display_error_message(ME3)
end %try

diary off