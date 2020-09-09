function  [port_impedances, port_fft] = calculate_port_impedances(port_data, cut_off_freqs,...
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


for nsf = length(port_data):-1:1% number of ports
    %     port_data{nsf} = cat(1,port_data{nsf},zeros(length(timescale) - ...
    %         size(port_data{nsf},1), size(port_data{nsf},2)));
    % Calculating the fft of the port signals
    for kse = 1:size(port_data{nsf},2)
        % doing it in two loops to avoid out of memory errors.
        port_mode_fft{nsf}(:,kse) = fft(port_data{nsf}(:,kse))./length(timescale);
    end %for
    
    if isempty(cut_off_freqs) == 0
        % setting all values below the cutoff frequency for each port and mode to
        % zero.
        for esns = 1:length(cut_off_freqs{nsf}) % number of modes
            tmp_ind_lower = find(f_raw < cut_off_freqs{nsf}(esns),1,'last');
            tmp_ind_upper = length(f_raw) - tmp_ind_lower;
            if tmp_ind_lower < length(f_raw) /2
                port_mode_fft{nsf}(1:tmp_ind_lower,  esns) = 0;
                port_mode_fft{nsf}(tmp_ind_upper:end,  esns) = 0;
            end %if          
        end %for
        clear esns n
    end %if
    % The transfer impedance at the ports is found using P = I^2 * Z. So the
    % impedance is the power seen at the ports divided by the bunch spectra squared.
    %     We take the real part as this corresponds to resistive losses.
    % take the abs because.....not quite sure if that is correct,however the
    % port impedance is oscillating around 0 otherwise.????
    port_fft(:,nsf) = sum(port_mode_fft{nsf}, 2);
    port_impedances(:,nsf) = real(sum(abs(port_mode_fft{nsf}).^2,2)) ./...
        abs(bunch_spectra)'.^2;
end
end