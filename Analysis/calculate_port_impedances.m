function  output = calculate_port_impedances(port_data,...
    port_f_data, f_raw, bunch_spectra)
% Calculates the port impedances from the the bunch spectra and the
% frequency data.

%
% Example: port_impedances = calculate_port_impedances(port_data, timescale, f_raw, bunch_spectra)

% substructure = {'voltage_port_mode', 'power_port_mode'};
% for hs = 1:length(substructure)
%     results_of_interest = {'port_mode_signals', 'port_mode_energy_time'};
%     for kaw = 1:length(results_of_interest)
%         for nsf = size(port_data.(substructure{hs}).(results_of_interest{kaw}),1):-1:1% number of ports
%             % Calculating the fft of the port signals
%             for kse = 1:size(port_data.(substructure{hs}).frequency_cutoffs{nsf},2)% number of modes
%                 % doing it in two loops to avoid out of memory errors.
%                 port_mode_fft(nsf, kse, :) = fft(squeeze(port_data.(substructure{hs}).(results_of_interest{kaw})(nsf, kse, :))) ./length(timescale);
%                 tmp_ind_lower = find(f_raw < port_data.(substructure{hs}).frequency_cutoffs{nsf}(kse),1,'last');
%                 tmp_ind_upper = length(f_raw) - tmp_ind_lower;
%                 % setting all values below the cutoff frequency for each port and mode to
%                 % zero.
%                 if tmp_ind_lower < length(f_raw) /2
%                     port_mode_fft(nsf, kse, 1:tmp_ind_lower) = 0;
%                     port_mode_fft(nsf, kse, tmp_ind_upper:end) = 0;
%                 end %if
%             end %for
%         end %for
        % The transfer impedance at the ports is found using P = I^2 * Z. So the
        % impedance is the power seen at the ports divided by the bunch spectra squared.
        %     We take the real part as this corresponds to resistive losses.
        % take the abs because.....not quite sure if that is correct,however the
        % port impedance is oscillating around 0 otherwise.????
%         port_f_data = squeeze(sum(port_mode_fft, 2));% W
%         if strcmp(substructure{hs}, 'voltage_port_mode')
%             output.(substructure{hs}).(results_of_interest{kaw}).port_mode_impedances = real(abs(port_mode_fft).^2) ./...
%                 repmat(permute(abs(bunch_spectra).^2, [1,3,2]), [size(port_mode_fft,1),size(port_mode_fft,2), 1]);
%             
%             output.(substructure{hs}).(results_of_interest{kaw}).port_impedances = real(abs(port_f_data).^2) ./...
%                 repmat(abs(bunch_spectra).^2, [size(port_f_data,1), 1]);
%         else
%             output.(substructure{hs}).(results_of_interest{kaw}).port_mode_impedances = real(abs(port_mode_fft)) ./...
%                 repmat(permute(abs(bunch_spectra).^2, [1,3,2]), [size(port_mode_fft,1),size(port_mode_fft,2), 1]);
%             output.(substructure{hs}).(results_of_interest{kaw}).port_impedances = real(abs(port_f_data)) ./...
%                 repmat(abs(bunch_spectra).^2, [size(port_f_data,1), 1]);
                        port_impedances = port_f_data ./abs(bunch_spectra).^2;
%         end %if
%     end %for
% end %for