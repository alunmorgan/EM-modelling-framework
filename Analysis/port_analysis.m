function [port_analysed_data] = port_analysis(timebase, port_data, overrides, input_type)
% In order to get the total power we need to sum the modes together for
% each port to give the measured signal. Square this to get the power out
% of each port. Add up the powers.
% If you do this as a cum sum you get the time evolution of the power loss.
%
% Port data is organised like this:
% port_data{Parameter, Port Num, Mode Num, Time/signal}
%
% Example: [port_data] = port_analysis(port_data)

if nargin >2 % There are overrides to the number of port modes to be used.
    for dl = 1:length(port_data)
        if size(port_data{dl},2) > overrides(dl)
            port_data{dl} = port_data{dl}(:,1:overrides(dl));
        end %if
    end %for
end %if
t_step = abs(timebase(2) - timebase(1)); % time step in s
% Port signals are in units of power.
% The t_step scaling is to deal with the fact that the data
% is not a continous function, but rather a set of decrete
% points with a certain separation. In order to get a truthful
% value of the integral one needs to multiply each point by the
% separation (effectively turning the point into areas).
port_mode_energy_time = zeros(length(port_data), max(overrides), length(timebase));
port_mode_signals = zeros(length(port_data), max(overrides), length(timebase));
for es =length(port_data):-1:1
    %     convert port signal to port energy. (port, modes, time)
    if strcmp(input_type, 'voltage')
        port_mode_energy_time(es,1:size(port_data{es},2),:) = (port_data{es}.^2 .* t_step)'; % V^2 * s = J
    elseif strcmp(input_type, 'power')
        port_mode_energy_time(es,1:size(port_data{es},2),:) = (port_data{es} .* t_step)'; % W * s = J
    end %if
    port_mode_signals(es,1:size(port_data{es},2),:) = port_data{es}'; % W
end %for
port_analysed_data.port_mode_signals = port_mode_signals; % W
port_analysed_data.port_mode_energy_time = port_mode_energy_time; % J
port_analysed_data.port_mode_energy = sum(port_mode_energy_time, 3); % J
port_analysed_data.port_mode_energy_cumsum = cumsum(port_mode_energy_time, 3); % J
port_analysed_data.port_energy = sum(sum(port_mode_energy_time, 3), 2);% J
port_analysed_data.port_energy_cumsum = cumsum(squeeze(sum(port_mode_energy_time,2)),2);% J

% if it errors here check the port multiple settings are correct.
port_analysed_data.total_energy = sum(sum(sum(port_mode_energy_time, 3),2),1);% J
port_analysed_data.total_energy_cumsum = squeeze(cumsum(sum(sum(port_mode_energy_time, 2),1),3));% J



