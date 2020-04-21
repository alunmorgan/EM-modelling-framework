function [frequency_scale, spectra] = extract_machine_conditions_results_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
frequency_scale = wake_data.frequency_domain_data.f_raw * 1E-9; %ns
spectra = wake_data.frequency_domain_data.extrap_data.diff_machine_conds.bunch_spec;