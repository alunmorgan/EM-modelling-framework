function pme = extract_port_energy_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
pme = wake_data.port_time_data.port_mode_energy;
