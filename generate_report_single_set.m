function generate_report_single_set(model_set)
% Runs the report generation for a single model set.
%   Args:
%       model_set(str): Name of model set to run.

diary off
paths = load_local_paths;
diary on

try
    generate_report_sets({model_set})
catch ME6
    display_error_message(ME6)
end %try
diary off