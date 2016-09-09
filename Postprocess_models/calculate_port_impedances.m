function  port_impedances = calculate_port_impedances(port_data, cut_off_freqs,...
    timescale, f_raw, bunch_spectra)
% Calculates the port impedances from the the bunch spectra and the
% frequency data.
%
%port_data is 
%cut_off_freqs is 
%timescale is 
%f_raw is 
%bunch_spectra is 
%
% Example: port_impedances = calculate_port_impedances(port_data, cut_off_freqs, timescale, f_raw, bunch_spectra)


for nsf = 1:length(port_data)% number of ports
    port_data{nsf} = cat(1,port_data{nsf},zeros(length(timescale) - ...
        size(port_data{nsf},1), size(port_data{nsf},2)));
    % Calculating the fft of the port signals
    port_mode_fft{nsf} = fft(port_data{nsf},[],1)./length(timescale);
    
    if isempty(cut_off_freqs) == 0
        % setting all values below the cutoff frequency for each port and mode to
        % zero.
        for esns = 1:length(cut_off_freqs{nsf}) % number of modes
            tmp_ind = find(f_raw < cut_off_freqs{nsf}(esns),1,'last');
            % TEST
            % move the index n samples above cutoff to reduce the effect of
            % phase runaway. (set to zero now as I think that the error
            % committed doing this is larger than the error I am trying to
            % remove. If it is a gibbs like phenomina then the integral will be
            % correct so the energy losses and power will be correct even if
            % the cumulative sum graphs show some drops.)
            n = 0;
            tmp_ind = tmp_ind +n;
            if tmp_ind < length(f_raw) +n;
                end_ind = length(f_raw);
                port_mode_fft{nsf}(1:tmp_ind,  esns) = 0;
                port_mode_fft{nsf}(end_ind - tmp_ind+2:end_ind,  esns) = 0;
            end
        end
        clear esns n
    end
    % The transfer impedance at the ports is found using P = I^2 * Z. So the
    % impedance is the power seen at the ports divided by the bunch spectra squared.
    %     We take the real part as this corresponds to resistive losses.
    % take the abs because.....not quite sure if that is correct,however the
    % port impedance is oscillating around 0 otherwise.????
    port_impedances(:,nsf) = real(sum(abs(port_mode_fft{nsf}).^2,2)) ./...
        abs(bunch_spectra).^2;
end
end