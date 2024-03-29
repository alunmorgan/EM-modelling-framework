function [wake_loss_factor, ...
    Bunch_loss_energy_spectrum, Total_bunch_energy_loss] = ...
    find_wlf_and_power_loss(model_charge, timescale, bunch_spec, ...
    wakeimpedance)
% Calculates the power loss and wake loss factor 
%
% Example: [wake_loss_factor, ...
%     Bunch_loss_energy_spectrum, Total_bunch_energy_loss] = ...
%     find_wlf_and_power_loss(model_charge, timescale, bunch_spec, ...
%     wakeimpedance)


%%%%This is all for a 1C bunch %%%%%%%%%
% power of a repeated bunch. (The FFT implies that the bunch is
% repeated after each simulation time)
pwr_f = abs(bunch_spec).^2 .* wakeimpedance;
% % In order to combat numerical noise we set the value of pwr to exactly
% % zero for all frequencies where bunch_spectra < 1E-4 of the max
inds = (abs(bunch_spec).^2)/(max(abs(bunch_spec).^2)) <1E-4;
pwr_f(inds) = 0;
% This is the power for a repeated bunch pattern with the spacing
% set by the wake length. To get the power of one bunch you need to
% divide by the number of bunches in 1 sec (as it is power).
% Alternativly multiply by the simulation time.
simulation_time = timescale(end) - timescale(1);
Bunch_loss_energy_spectrum = pwr_f  .* simulation_time;
pwr = sum(pwr_f);
% multiply the power for an infinite train by the simulation time in
% order to get the energy in one simulation run, i.e.1 bunch.
Total_bunch_energy_loss = pwr ./ 2 .* simulation_time;

% Wake loss factor is V/C or J/C^2
wake_loss_factor =   Total_bunch_energy_loss;

%%%%% Scale the output to the model charge
Bunch_loss_energy_spectrum = Bunch_loss_energy_spectrum .* model_charge.^2;
Total_bunch_energy_loss = wake_loss_factor .* model_charge.^2;

