function fs = gdf_wake_port_excitation(excitation_structure)
% Constructs the input file section for port excitation

fs = {'###################################################'};
if isempty(excitation_structure.port_names{1})
    fs =  cat(1, fs, '# NO port excitations requested #');
else
    fs = cat(1,fs,'-lcharge');
    fs = cat(1,fs,'charge=1e-21');% reduce the charge in the original bunch (still needed for timing.)
    fs = cat(1,fs,'nextcharge');
    fs = cat(1,fs,'charge=1e-9');%FIXME hardcoded value
    fs = cat(1,fs,'sigma=3E-3'); %FIXME hardcoded value
    fs = cat(1,fs,['soffset=', excitation_structure.beam_offset_z]); % overwrite the bunch delay.
    fs = cat(1,fs,['shigh=',excitation_structure.wakelength]); % overwrite the wakelength.
    fs = cat(1,fs,'nextcharge');
    fs = cat(1,fs,'-fdtd');
    fs = cat(1,fs,'-pexcitation');
    fs = cat(1,fs,['frequency = ',num2str(excitation_structure.frequency)]);
    fs = cat(1,fs,['bandwidth = ', num2str(excitation_structure.bandwidth)]);
    fs = cat(1,fs,['risetime = ', num2str(excitation_structure.risetime)]);
    for kds = 1:length(excitation_structure.port_names)
        fs = cat(1,fs,['port= ',excitation_structure.port_names{kds}]);
        if isfield(excitation_structure, 'user_signal_file_names') && ~isempty(excitation_structure.user_signal_file_names{kds})
            fs = cat(1,fs,['signalcommand= ./', excitation_structure.user_signal_file_names{kds}]);
            write_flat_top_input_pulse_input_file_fortran(excitation_structure.user_signal_risetime(kds),...
                excitation_structure.user_signal_decaytime(kds),...
                excitation_structure.user_signal_holdtime(kds),...
                excitation_structure.user_signal_amplitude(kds),...
                ['temp_data/', excitation_structure.user_signal_file_names{kds}])
        else
            fs = cat(1,fs,['mode = ', num2str(excitation_structure.mode(kds))]);
            fs = cat(1,fs,['amplitude = ', num2str(excitation_structure.amplitude(kds))]);
            fs = cat(1,fs,['phase = ', num2str(excitation_structure.phase(kds))]);
        end %if
        fs = cat(1,fs,'    nextport');
    end %for
end %if