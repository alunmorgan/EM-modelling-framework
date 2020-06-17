function fs = gdf_wake_port_excitation(port_names, frequency, varargin)
% Constructs the input file section for port excitation

defaultAmplitude = ones(length(port_names),1);
defaultphase = zeros(length(port_names),1);
defaultmode = ones(length(port_names),1);

p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addRequired(p,'port_names',@iscell);
addRequired(p,'frequency',validScalarPosNum);
addParameter(p,'amplitude',defaultAmplitude);
addParameter(p,'risetime',0,@isnumeric);
addParameter(p,'bandwidth',frequency / 2, @isnumeric);
addParameter(p,'phase',defaultphase);
addParameter(p,'mode',defaultmode);

parse(p,port_names, frequency, varargin{:});

fs = {'###################################################'};
if isempty(port_names{1})
    fs =  cat(1, fs, '# NO port excitations requested #');
else
    fs = cat(1,fs,'-fdtd');
    fs = cat(1,fs,'-pexcitation');
    for kds = 1:length(p.Results.port_names)
        fs = cat(1,fs,['port= ',p.Results.port_names{kds}]);
        fs = cat(1,fs,['mode = ', num2str(p.Results.mode(kds))]);
        fs = cat(1,fs,['amplitude = ', num2str(p.Results.amplitude(kds))]);
        fs = cat(1,fs,['phase = ', num2str(p.Results.phase(kds))]);
        if kds ==1
            fs = cat(1,fs,['frequency = ',num2str(p.Results.frequency)]);
            fs = cat(1,fs,['bandwidth = ', num2str(p.Results.bandwidth)]);
            fs = cat(1,fs,['risetime = ', num2str(p.Results.risetime)]);
        end %if
        fs = cat(1,fs,'    nextport');
    end %for
end %if