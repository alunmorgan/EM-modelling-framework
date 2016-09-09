function [port_data] = port_analysis(port_data)
% In order to get the total power we need to sum the modes together for
% each port to give the measured signal. Square this to get the power out
% of each port. Add up the powers.
% If you do this as a cum sum you get the time evolution of the power loss.
%
% Port data is organised like this:
% port_data{Parameter, Port Num, Mode Num, Time/signal}
%
% Example: [port_data] = port_analysis(port_data)

t_step = port_data.timebase(2) - port_data.timebase(1); % time step in s
% To convert from signal to power you need to square the signal
% The t_step scaling is to deal with the fact that the data
% is not a continous function, but rather a set of decrete
% points with a certain separation. In order to get a truthful
% value of the integral one needs to multiply each point by the
% separation (effectively turning the point into areas).
for es =1:length(port_data.data)
    port_mode_energy{es} = sum(port_data.data{es} .^2, 1)  .* t_step;
    port_mode_energy_cumsum{es} = cumsum(port_data.data{es} .^2) * t_step;
    port_energy_cumsum(:,es) = squeeze(sum(port_mode_energy_cumsum{es},2));
    port_energy(es) = sum(port_mode_energy{es});
end
% if it errors here check the port multiple settings are correct.
total_energy_cumsum = sum(port_energy_cumsum,2);% .* ...
total_energy = sum(port_energy);

port_data.port_mode_energy = port_mode_energy;
port_data.port_mode_energy_cumsum = port_mode_energy_cumsum;
port_data.port_energy_cumsum = port_energy_cumsum;
port_data.total_energy_cumsum = total_energy_cumsum;
port_data.port_energy = port_energy;
port_data.total_energy = total_energy;
