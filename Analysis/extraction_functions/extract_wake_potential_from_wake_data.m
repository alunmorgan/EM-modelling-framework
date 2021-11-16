function [wp, wpdx, wpdy, wpqx, wpqy] = extract_wake_potential_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
wp = wake_data.time_domain_data.wakepotential * 1E-12; % mV/pC

wpdx = wake_data.time_domain_data.wakepotential_trans_dipole_x * 1E-12; % mV/pC
wpdy = wake_data.time_domain_data.wakepotential_trans_dipole_y * 1E-12; % mV/pC
wpqx = wake_data.time_domain_data.wakepotential_trans_quad_x * 1E-12; % mV/pC
wpqy = wake_data.time_domain_data.wakepotential_trans_quad_y * 1E-12; % mV/pC
