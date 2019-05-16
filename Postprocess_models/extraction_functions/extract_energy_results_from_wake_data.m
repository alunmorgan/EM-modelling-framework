function energy = extract_energy_results_from_wake_data(pp_data)
% wake data (structure): contains all the data from the wake postprocessing
%
energy = pp_data.Energy .* 1E9;