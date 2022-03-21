function postprocess_single_set(model_set, input_file_loc, types, ...
                                versions, n_cores, precision)
% Runs the postprocessing for a single model set.
%   Args:
%       model_set(str): Name of model set to run.
%       input_file_loc(str): Path to input file.
%       types(cell of strings/char): Types of postprocessing to run.

diary off
load_local_paths

diary on

for herf = 1:length(types)
    try
        if any(contains(types, types{herf}))
            postprocess_model_sets(input_file_loc, {model_set}, ...
                {types{herf}}, versions, n_cores, precision)
        end %if
    catch ME1
        display_error_message(ME1)
    end %try
end %for

diary off