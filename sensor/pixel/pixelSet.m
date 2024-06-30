function pixel = pixelSet(pixel,param,val,varargin)
% Set pixel and photodetector parameters
%
%   pixel = pixelSet(pixel,param,val,varargin)
%
% The list of parameters is below. Electrical values are specified in
% volts. Spatial units are meters, except for wavelength which is
% nanometers.
%
% Pixel properties
%      {'name'}                - Identifier
%      {'type'}                - Always 'pixel'
%      {'pixelwidth'}          - width in meters
%      {'pixelheight'}
%      {'widthandheight'}      - [width,height] in meters.  Fill factor changes
%      {'sizesamefillfactor'}  - [width,height] in meters, alters photodetector size to preserve fill factor
%      {'widthgap'}            - gap between pixels (usually 0)
%      {'heightgap'}
%      {'fillfactor'}          - fill factor (area of pd to area of pixel)
%
% Photodetector properties
%      {'pdwidth'}              - photodetector width
%      {'pdheight'}             - photodetector height
%      {'pdwidthandheight'}     - photodetector width and height
%      {'layerthicknesses'}     -
%      {'refractiveindices'}    -
%      {'pdxpos'}               - generally assumed in the center
%      {'pdypos'}               -
%      {'conversiongain'}       - Volts per electron                                       % Volts/e-
%      {'voltageswing'}         - Assuming 0 volts min, this is max volt response          % Volts
%      {'dark voltage'}         - How the voltage grows in the dark from leakage           %V/sec/pixel
%      {'read noise volts'}     - Gaussian noise (s.d.) due to reading                     %standard deviation in V
%
%  Spectral properties
%      {'spectrum'}             - Structure
%        {'wave'}               - Sample wavelengths in nanometers
%        {'pixelspectralqe'}    - Percent of incident photons absorbed as a function of wavelength
%
% Examples:
%  pixel = sensorGet(sensor,'pixel');
%
%  pixel = pixelSet(pixel,'voltageSwing',1.5);
%  pixel = pixelSet(pixel,'widthHeight',[5,5]*1e-6);
%  pixel = pixelSet(pixel,'name','Monochrome');
%  pixel = pixelSet(pixel,'readNoiseVolts',0.010);
%
% Copyright ImagEval Consultants, LLC, 2005

if ~exist('pixel','var') || isempty(pixel), error('Must define pixel.'); end
if ~exist('param','var') || isempty(param), error('Must define parameter.'); end

% Empty is allowed, so we don't use ieNotDefined.
if ~exist('val','var'),   error('Value required.');end

param = ieParamFormat(param);

switch param
    case 'name'
        pixel.name = val;
    case 'type'
        pixel.type = val;
        
    case {'pixelwidth','width'}     %M
        pixel.width = val;
    case {'height','pixelheight'}   %M
        pixel.height = val;
    case {'size','widthheight','widthandheight'} %M
        % pixelSet(pixe,'size')
        % The fill factor changes, because pd is not change.
        if isscalar(val), val(2) = val(1); end
        pixel = pixelSet(pixel,'width',val(1));
        pixel = pixelSet(pixel,'height',val(2));
        disp('Fill factor may have changed. You can use: size same fill factor');
    case {'sizeconstantfillfactor','sizekeepfillfactor','sizesamefillfactor'}
        % pixelSet(pixel,'size ConstantFillFactor',newSize);
        %
        % This changes the pixel size and keeps the fill factor constant by
        % also changing the size of the photodetector area.
        %
        % If newSize is a single number, we assume the user meant the
        % height and width were both this size.
        if length(val) < 2, val(2) = val(1); end
        
        curSize = pixelGet(pixel,'size');
        sFactor = val ./ curSize;
        pdSize = pixelGet(pixel,'pdSize').*sFactor;
        
        pixel = pixelSet(pixel,'width',val(1));
        pixel = pixelSet(pixel,'height',val(2));
        pixel = pixelSet(pixel,'pdWidth',pdSize(1));
        pixel = pixelSet(pixel,'pdHeight',pdSize(2));
        
    case {'widthgap','widthbetweenpixels'} %M
        pixel.widthGap  = val;
    case {'heightgap','heightbetweenpixels'}    %M
        pixel.heightGap = val;
        
        % Photodetector sizes and positions
    case {'pdwidth','photodetectorwidth'}      % M
        pixel.pdWidth = val;
    case {'pdheight','photodetectorheight'}    % M
        pixel.pdHeight = val;
    case {'pdwidthandheight','pdsize'}         %(M,M)
        pixel = pixelSet(pixel,'pdwidth',val(1));
        pixel = pixelSet(pixel,'pdheight',val(2));
    case {'fillfactor'}
        % pixel = pixelSet(pixel,'fill factor',0.5);
        %
        % This changes the size of the photodetector area but keeps the
        % size of the pixel constant.
        pixel = pixelSet(pixel,'pd width',sqrt(val)*pixelGet(pixel,'deltax'));
        pixel = pixelSet(pixel,'pd height',sqrt(val)*pixelGet(pixel,'deltay'));
        
    case {'layerthickness','layerthicknesses'} % M
        pixel.layerThickness = val;
        
    case {'refractiveindex','refractiveindices','n'} %dimensionless
        pixel.n = val;
        
    case {'pdxpos','photodetectorxposition'}       %M
        pixel.pdXpos = val;
    case {'pdypos','photodetectoryposition'}
        pixel.pdYpos = val;
        
    case {'conversiongain','voltsperelectron'}                  % Volts/e-
        pixel.conversionGain = val;
    case {'voltageswing','saturationvoltage','maxvoltage'}      % Volts
        pixel.voltageSwing= val;
        
    case {'darkvoltage','darkvoltageperpixel','voltspersecond'}  %V/sec/pixel
        pixel.darkVoltage = val;
        
    case {'readnoise','readnoiseelectrons','readstandarddeviationelectrons'}         %standard deviation in e-
        pixel.readNoise = val*pixelGet(pixel,'conversiongain');
        
    case {'readnoisevolts','readstandarddeviationvolts','readnoisestdvolts'}         %standard deviation in V
        pixel.readNoise = val;
        
    case {'readnoisemillivolts'}                    %standard deviation in V
        pixel.readNoise = val*10^-3;
        
    case 'spectrum'
        pixel.spectrum = val;
    case {'wave','wavelengthsamples'}         %nm
        pixel.spectrum.wave = val(:);
        
    case {'pixelspectralqe','pixelqe','spectralqe','pixelquantumefficiency','pdspectralqe','qe','photodetectorquantumefficiency','photodetectorspectralquantumefficiency'}
        if isscalar(val)
            pixel.spectralQE = pixel.spectralQE *val;
        else
            % Probably check that it matches wave
            assert(numel(val)==numel(pixel.spectrum.wave));
            pixel.spectralQE = val;
        end

    otherwise
        error('Unknown param: %s',param);
end

end