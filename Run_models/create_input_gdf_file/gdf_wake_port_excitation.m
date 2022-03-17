function fs = gdf_wake_port_excitation(excitation_structure)
% Constructs the input file section for port excitation

fs = {'###################################################'};
if isempty(excitation_structure.port_names{1})
    fs =  cat(1, fs, '# NO port excitations requested #');
else
    fs = cat(1,fs,'-lcharge');
    fs = cat(1,fs,'charge=1e-21');% reduce the charge in the original bunch (still needed for timing.)
    fs = cat(1,fs,'nextcharge');
    fs = cat(1,fs,['charge=', num2str(excitation_structure.bunch_charge)]);
    fs = cat(1,fs,['sigma=', num2str(excitation_structure.bunch_sigma)]);
    fs = cat(1,fs,['soffset=', excitation_structure.beam_offset_z]); % overwrite the bunch delay.
    fs = cat(1,fs,['shigh=',excitation_structure.wakelength]); % overwrite the wakelength.
%     fs = cat(1,fs,'nextcharge');
    fs = cat(1,fs,'-fdtd');
    fs = cat(1,fs,'-pexcitation');
    for kds = 1:length(excitation_structure.port_names)
        fs = cat(1,fs,['port= ',excitation_structure.port_names{kds}]);
        fs = cat(1,fs,['frequency = ', num2str(excitation_structure.frequency(kds))]);
        fs = cat(1,fs,['risetime = ', num2str(excitation_structure.user_signal_risetime(kds))]);
        if isfield(excitation_structure, 'user_signal_holdtime')
            fs = cat(1,fs,['holdtime = ', num2str(excitation_structure.user_signal_holdtime(kds))]);
            fs = cat(1,fs,['decaytime = ', num2str(excitation_structure.user_signal_decaytime(kds))]);
            fs = cat(1,fs,['amplitude = ', num2str(excitation_structure.user_signal_amplitude(kds))]);
        else
            fs = cat(1,fs,['bandwidth = ', num2str(excitation_structure.bandwidth(kds))]);
            fs = cat(1,fs,['mode = ', num2str(excitation_structure.mode(kds))]);
            fs = cat(1,fs,['amplitude = ', num2str(excitation_structure.user_signal_amplitude(kds))]);
            fs = cat(1,fs,['phase = ', num2str(excitation_structure.phase(kds))]);
        end %if
        fs = cat(1,fs,'    nextport');
    end %for
    fs = cat(1,fs,['    define(XMAX, 17e-3)']);
    fs = cat(1,fs,[' define(ZZ, 70e-3)']);
    fs = cat(1,fs,['     -voltages']);
    fs = cat(1,fs,['         name= VSignal3_2']);
    fs = cat(1,fs,['            startpoint= ( 0, 0.2, ZZ )']);
    fs = cat(1,fs,['            endpoint= ( XMAX, 0.2, ZZ )']);
    fs = cat(1,fs,['            logcurrent= yes']);
    fs = cat(1,fs,['            resistance= 1e10, ']);
    fs = cat(1,fs,['            amplitude= 1e-10,']);
    fs = cat(1,fs,['            risetime= 1e-10,']);
    fs = cat(1,fs,['            frequency= 0']);
    fs = cat(1,fs,['         doit']);
    fs = cat(1,fs,['         name= VSignal3_1']);
    fs = cat(1,fs,['            startpoint= ( 0, 0.1, ZZ )']);
    fs = cat(1,fs,['            endpoint= ( XMAX, 0.1, ZZ )']);
    fs = cat(1,fs,['         doit']);
    fs = cat(1,fs,['         name= VSignal3_05']);
    fs = cat(1,fs,['            startpoint= ( 0, 0.05, ZZ )']);
    fs = cat(1,fs,['            endpoint= ( XMAX, 0.05, ZZ )']);
    fs = cat(1,fs,['         doit']);
end %if