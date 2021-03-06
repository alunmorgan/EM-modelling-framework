function [varargout ] = put_on_reference_timebase(ref_timebase, port_data)
% Puts the time domain and port domain data on a common timebase.
%
% Example: [ varargout ] = put_on_reference_timebase(ref_timebase, port_data)

raw_port_data = NaN;

% Interpolate the port signals onto the reference timebase.
if isfield(port_data, 'data')
    if length(port_data.data) ~=0
        % if length is 0 then there are no transmitting modes in the
        % spectral range requested.
    clear raw_port_data
    end %if
    for jsff = 1:length(port_data.data) % number of ports
        for jsfs = 1:size(port_data.data{jsff},2) % number of transmitting modes
            tmp  = interp1(port_data.timebase,...
                squeeze(port_data.data{jsff}(:,jsfs)),  ref_timebase);
            % Replace the NaNs at the begining with zeros. 
            %This is because the wakepotential starts at a -ve time.
            % there is still no signal there.
            tmp(isnan(tmp)==1) = 0;
            raw_port_data{jsff}(1:length(tmp), jsfs) = tmp;
        end
    end
end

varargout{1} = raw_port_data;
