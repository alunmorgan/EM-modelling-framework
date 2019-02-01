function energy = extract_energy_results_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
energy = wake_data.raw_data.Energy .* 1E9;