function analyse_single_set(model_set, types, override)
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
        if strcmp(override{contains(types, 'wake')}, 'yes')
            wake_override = 'no_skip';
        else
            wake_override = 'skip';
        end %if
        analyse_models_sets({model_set}, wake_override);
        get_wlf({model_set}, override{contains(types, 'wake')});
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