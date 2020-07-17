function fs = gdf_wake_port_excitation(excitation_structure, wakelength)
% Constructs the input file section for port excitation
% 
% defaultAmplitude = ones(length(port_names),1);
% defaultphase = zeros(length(port_names),1);
% defaultmode = ones(length(port_names),1);
% defaultdelay = '0';

% p = inputParser;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% addRequired(p,'port_names',@iscell);
% addRequired(p,'frequency',validScalarPosNum);
% addRequired(p,'wakelength');
% addParameter(p,'amplitude',defaultAmplitude);
% addParameter(p,'risetime',0,@isnumeric);
% addParameter(p,'bandwidth',frequency / 2, @isnumeric);
% addParameter(p,'phase',defaultphase);
% addParameter(p,'mode',defaultmode);
% addParameter(p,'beam_delay',defaultdelay);

% parse(p,port_names, frequency, wakelength, varargin{:});

fs = {'###################################################'};
if isempty(excitation_structure.port_names{1})
    fs =  cat(1, fs, '# NO port excitations requested #');
else
    fs = cat(1,fs,'-lcharge');
         fs = cat(1,fs,'charge=1e-18');% reduce the charge in the original bunch (still needed for timing.)
     fs = cat(1,fs,'nextcharge');
     fs = cat(1,fs,'charge=1e-9');%FIXME hardcoded value
     fs = cat(1,fs,'sigma=3E-3'); %FIXME hardcoded value
    fs = cat(1,fs,['soffset=', excitation_structure.beam_offset_z]); % overwrite the bunch delay.
    fs = cat(1,fs,['shigh=',wakelength , '+', excitation_structure.beam_offset_z]); % extend the wake length by the bunch delay.
     fs = cat(1,fs,'nextcharge');
    fs = cat(1,fs,'-fdtd');
    fs = cat(1,fs,'-pexcitation');
    for kds = 1:length(excitation_structure.port_names)
        fs = cat(1,fs,['port= ',excitation_structure.port_names{kds}]);
        fs = cat(1,fs,['mode = ', num2str(excitation_structure.mode(kds))]);
        fs = cat(1,fs,['amplitude = ', num2str(excitation_structure.amplitude(kds))]);
        fs = cat(1,fs,['phase = ', num2str(excitation_structure.phase(kds))]);
        if kds ==1
            fs = cat(1,fs,['frequency = ',num2str(excitation_structure.frequency)]);
            fs = cat(1,fs,['bandwidth = ', num2str(excitation_structure.bandwidth)]);
            fs = cat(1,fs,['risetime = ', num2str(excitation_structure.risetime)]);
        end %if
        fs = cat(1,fs,'    nextport');
    end %for
end %if