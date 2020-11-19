function ind = find_data_end(timebase, wakelength)
% This removes the zero padding on the data. This is useful for the final
% plotting.

wls = wakelength / 3e8; % convert to seconds.;

% find the index of time zero (the data may start at negative time).
zero_ind = find(diff(sign(timebase))~=0);
timestep = abs(timebase(2) - timebase(1));
if isempty(zero_ind)
    ind = floor(wls / timestep);
else
    ind = floor(wls / timestep) + zero_ind;
end %if