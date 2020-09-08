function [alpha, beta, port_data_out, cutoff] = port_data_conditioning(port_data, log, ...
    port_fill_factor)
% scales ports data usong the provided fill factor.
%
% Example: [alpha, beta, port_data, cutoff] = port_data_conditioning(port_data, log, ...
%    port_fill_factor)


for hes = 1:length(port_data) % simulated ports
    ck = 1;
    for wha = 1:size(port_data{hes},2) % modes
        if log.alpha{hes}(wha) == 0 % only interested in transmitting modes.
            %                 If alpha =0 there is no imaginary component
            alpha{hes}(ck) = log.alpha{hes}(wha);
            beta{hes}(ck) = log.beta{hes}(wha);
            % divided by the sqrt of the fill factor as it is the
            % energy which is reduced by the fill factor. So the
            % signal is reduced by sqrt of the fill factor.
            %(as energy = signal^2)
            port_data_out{hes}(:,ck) = port_data{hes}(:,wha) ./ sqrt(port_fill_factor(hes));
            cutoff{hes}(ck) = log.cutoff{hes}(wha);
            ck = ck +1;
        end %if
    end %for
end %for


