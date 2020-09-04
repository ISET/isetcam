function sensor = sensorCreate(sensorName,pixel,varargin)
%Create an image sensor array structure
%
%      sensor = sensorCreate(sensorName,[pixel],varargin)
%
% The sensor array uses a pixel definition that can be specified in the
% parameter PIXEL. If this is not passed in, a default PIXEL is created and
% returned.
%
% Several type of image sensors can be created, including multispectral and
% a model of the human cone mosaic.
%
% Bayer RGB combinations
%      {'bayer-grbg'}
%      {'bayer-rggb'}
%      {'bayer-bggr'}
%      {'bayer-gbrg'}
%
% Bayer CMY combinations
%      {'bayer (ycmy)'}
%      {'bayer (cyym)'}
%
% Vendor parts
%      {'MT9V024'}  - sensorCreate('MT9V024',[],{'rgb','mono','rccc'})
%      {'ar0132at'} - An ON sensor
%
% Other types
%      {'monochrome'}       - single monochrome sensor
%      {'monochrome array'} - cell array of monochrome sensors
%      {'lightfield'}       - RGB to match the resolution of a lightfield oi
%
% Multiple channel sensors can be created
%      {'grbc'}   - green, red, blue, cyan
%      {'rgbw'}   - One transparent channel and 3 RGB.  Same as RGBC
%                        or RGBW
%      {'fourcolor'}
%      {'custom'}
%
% Human cone mosaic
%      {'human'} - Uses Stockman Quanta LMS cones, see
%                  pixelCreate('human'), which returns a 2um aperture; you
%                  should probably use ISETBIO if you are here.  This is
%                  likely to be deprecated some day.
%
% See also: sensorReadColorFilters, sensorCreateIdeal
%
% Examples:
%  Default Bayer RGGB
%   sensor = sensorCreate;
%   sensor = sensorCreate('default');
%  
%  Other types of Bayer arrays
%   sensor = sensorCreate('bayer (ycmy)');
%   sensor = sensorCreate('bayer (rggb)');
%
%  A monochrome sensor
%   sensor = sensorCreate('Monochrome');
%
%  A light field sensor matched to an OI rendered from PBRT.  Note that oi
%  is passed instead of pixel
%   sensor = sensorCreate('light field',oi);
%
%  Human style sensors (but see ISETBIO for more complete control)
%   cone   = pixelCreate('human cone'); 
%   sensor = sensorCreate('Monochrome',cone);
%   sensor = sensorCreate('human');
%
%   params.sz = [128,192];
%   params.rgbDensities = [0.1 .6 .2 .1]; % Empty, L,M,S
%   params.coneAperture = [3 3]*1e-6;     % In meters
%   pixel = [];
%   sensor = sensorCreate('human',pixel,params);
%   sensorConePlot(sensor)
%
%  More details specified
%   filterOrder = [1 2 3; 4 5 2; 3 1 4];
%   wave = 400:2:700;
%   filterFile = fullfile(isetRootPath,'data','sensor','colorfilters','sixChannel.mat');
%   pixel = pixelCreate('default',wave);
%   sensorSize = [256 256];
%   sensor = sensorCreate('custom',pixel,filterOrder,filterFile,sensorSize,wave)
%
% See also:  sensorCreateIdeal
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('sensorName'), sensorName = 'default'; end

sensor.name = [];
sensor.type = 'sensor';

% Make sure a pixel is defined.
if ieNotDefined('pixel')
    pixel  = pixelCreate('default');
    sensor = sensorSet(sensor,'pixel',pixel);
    sensor = sensorSet(sensor,'size',sensorFormats('qqcif'));
else
    sensor = sensorSet(sensor,'pixel',pixel);
end

% The sensor should always inherit the spectrum of the pixel.  Probably
% there should only be one spectrum here, not one for pixel and sensor.
sensor = sensorSet(sensor,'spectrum',pixelGet(pixel,'spectrum'));

sensor = sensorSet(sensor,'data',[]);

sensor = sensorSet(sensor,'sigmagainfpn',0);    % [V/A]  This is the slope of the transduction function
sensor = sensorSet(sensor,'sigmaoffsetfpn',0);  % V      This is the offset from 0 volts after reset

% I wonder if the default spectrum should be hyperspectral, or perhaps it
% should be inherited from the currently selected optical image?
% sensor = initDefaultSpectrum(sensor,'hyperspectral');

sensor = sensorSet(sensor,'analogGain',1);
sensor = sensorSet(sensor,'analogOffset',0);
sensor = sensorSet(sensor,'offsetFPNimage',[]);
sensor = sensorSet(sensor,'gainFPNimage',[]);
sensor = sensorSet(sensor,'gainFPNimage',[]);
sensor = sensorSet(sensor,'quantization','analog');

sensorName = ieParamFormat(sensorName);
switch sensorName
    case {'default','color','bayer','rgb','bayer(grbg)','bayer-grbg','bayergrbg'}
        filterOrder = [2,1;3,2];
        filterFile = 'RGB';
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'bayer(rggb)','bayer-rggb'}
        filterOrder = [1 2 ; 2 3];
        filterFile = 'RGB';
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'bayer(bggr)','bayer-bggr'}
        filterOrder = [3 2 ; 2 1];
        filterFile = 'RGB';
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'bayer(gbrg)','bayer-gbrg'}
        filterOrder = [2 3 ; 1 2];
        filterFile = 'RGB';
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'cmy','bayer(ycmy)','bayer-ycmy'}
        filterFile = 'cym';
        filterOrder = [2,1; 3,2];
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'bayer(cyym)','bayer-cyym'}
        filterFile = 'cym';
        filterOrder = [1 2 ; 2 3];
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'ideal'}
        % sensorCreate('ideal',[],pSize,sensorType,cPattern);
        %
        % sensorType = 'human'  % 'rgb','monochrome'
        % cPattern = 'bayer'    % any sensorCreate option
        % sensorCreate('ideal',[],'human','bayer');
        error('sensorCreate(''ideal'') is deprecated.  Use sensorCreateIdeal');
        
    case {'lightfield'}
        % Light field sensor matched to an oi.  Note the overload on the
        % pixel argument.  Both forms work.
        %
        %   sensorCreate('light field',oi)
        %   sensorCreate('light field',pixel,oi)
        %
        if isempty(varargin)
            % 
            if checkfields(pixel,'type') && strcmp(pixel.type,'opticalimage')
                oi = pixel;
            else
                error('oi required for lightfield camera');
            end
        else
            % We should allow more parameters to be used to create the
            % light field sensor, such as color filter arrangement.  The
            % pixel size is fixed, however, to match the spatial structure
            % of the oi.
            oi = varargin{1};
        end  
        sensor = sensorLightField(oi);
        sensor = sensorSet(sensor,'name',oiGet(oi,'name'));
        
    case {'mt9v024'}
        % ON 6um sensor.  It can be mono, rgb, or rccc
        % sensor = sensorCreate('MT9V024',[],'rccc');
        if isempty(varargin)
            colorType = 'rgb';
        else 
            colorType = varargin{1};
        end
        sensor = sensorMT9V024(sensor,colorType);
        
    case {'ar0132at'}
        % ON RGB automotive sensor
        sensor = sensorAR0132AT(sensor);

    case {'custom'}      % Often used for multiple channel
        % sensorCreate('custom',pixel,filterPattern,filterFile,wave);
        if length(varargin) >= 1, filterPattern = varargin{1};
        else  % Must read it here
        end
        if length(varargin) >= 2, filterFile = varargin{2};
        else % Should read it here, NYI
            error('No filter file specified')
        end
        if length(varargin) <= 3 || isempty(varargin{3})
             sensorSize = size(filterPattern);
        else, sensorSize = varargin{3};
        end
        if length(varargin) == 4, wave = varargin{4}; 
        else, wave = 400:10:700;
        end
        sensor = sensorSet(sensor,'wave',wave);
        sensor = sensorCustom(sensor,filterPattern,filterFile);
        sensor = sensorSet(sensor,'size',sensorSize);
    case {'fourcolor'}  % Often used for multiple channel
        % sensorCreate('custom',pixel,filterPattern,filterFile);
        if length(varargin) >= 1, filterPattern = varargin{1};
        else  % Must read it here
        end
        if length(varargin) >= 2, filterFile = varargin{2};
        else % Should read it here, NYI
            error('No filter file specified')
        end
        sensor = sensorCustom(sensor,filterPattern,filterFile);

    case 'monochrome'
        filterFile = 'Monochrome';
        sensor = sensorMonochrome(sensor,filterFile);
    case 'monochromearray'
        % sensorA = sensorCreate('monochrome array',[],5);
        %
        % Builds an array of monochrome sensors, each corresponding to the
        % default monochrome.  The array of sensors is used for
        % calculations that avoid demosaicking.
        if isempty(varargin), N = 3;
        else, N = varargin{1};
        end
        
        sensorA(N) = sensorCreate('monochrome');
        for ii=1:(N-1), sensorA(ii) = sensorA(N); end
        sensor = sensorA;
        
        return;
        
    case {'rgbw','interleaved'}
        % Create an RGBW (interleaved) sensor with one transparent and 3
        % color filters.  Inteleaved comes about because MP and BW treated
        % RGB W as rod/cone and we called them interleaved mosaics.
        filterFile = 'interleavedRGBW.mat';
        filterPattern = [1 2; 3 4];
        sensor = sensorInterleaved(sensor,filterPattern,filterFile);
    case 'human'
        % sensor = sensorCreate('human',pixel,params);
        % Uses StockmanQuanta
        % See example in header.
        %
        if length(varargin) >= 1, params = varargin{1};
        else params = [];
        end

        % Assign key fields
        if checkfields(params,'sz'), sz = params.sz;
        else, sz = []; end
        if checkfields(params,'rgbDensities'), rgbDensities = params.rgbDensities;
        else, rgbDensities = []; end
        if checkfields(params,'coneAperture'), coneAperture = params.coneAperture;
        else, coneAperture = []; end
        if checkfields(params,'rSeed'), rSeed = params.rSeed;
        else, rSeed = [];
        end
        if checkfields(params,'wave'), wave = params.wave;
        else                           wave = 400:10:700;
        end
        
        % Add the default human pixel with StockmanQuanta filters.
        sensor = sensorSet(sensor,'wave',wave);
        sensor = sensorSet(sensor,'pixel',pixelCreate('human',wave));
             
        % Build up a human cone mosaic.
        [sensor, xy, coneType, rSeed, rgbDensities] = ...
            sensorCreateConeMosaic(sensor, sz, rgbDensities, coneAperture, rSeed, 'human');
        %  figure(1); conePlot(xy,coneType);
        
        % We don't want the pixel to saturate
        pixel  = sensorGet(sensor,'pixel');
        pixel  = pixelSet(pixel,'voltage swing',1);  % 1 volt
        sensor = sensorSet(sensor,'pixel',pixel);
        sensor = sensorSet(sensor,'exposure time',1); % 1 sec
        
        % Parameters are stored in case you want the exact same mosaic
        % again. Should we have sets and gets for this?
        sensor = sensorSet(sensor,'cone locs',xy);
        sensor = sensorSet(sensor,'cone type',coneType);
        sensor = sensorSet(sensor,'densities',rgbDensities);
        sensor = sensorSet(sensor,'rSeed',rSeed);

    otherwise
        error('Unknown sensor type');
end

% Set the exposure time - this needs a CFA to be established to account for
% CFA exposure mode.
sensor = sensorSet(sensor,'integrationTime',0);
sensor = sensorSet(sensor,'autoexposure',1);    
sensor = sensorSet(sensor,'CDS',0);

% Put in a default infrared filter.  All ones.
sensor = sensorSet(sensor,'irfilter',ones(sensorGet(sensor,'nwave'),1));

% Place holder for Macbeth color checker positions
sensor = sensorSet(sensor,'mccRectHandles',[]);

% Compute with all noise turned on by default
sensor = sensorSet(sensor,'noise flag',2);

end

%-----------------------------
function sensor = sensorBayer(sensor,filterPattern,filterFile)
%
%   Create a default image sensor array structure.

sensor = sensorSet(sensor,'name',sprintf('bayer-%.0f',vcCountObjects('sensor')));
sensor = sensorSet(sensor,'cfa pattern',filterPattern);

% Read in a default set of filter spectra
[filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
sensor = sensorSet(sensor,'filterspectra',filterSpectra);
sensor = sensorSet(sensor,'filternames',filterNames);

end

%-----------------------------

%{
%----------------------
function sensor = sensorMouse(sensor, filterFile)
%
% This isn't right.  The content below should be moved into
% sensorCreateConeMosaic and edited to be made right there.

error('Not yet implemented');
%
%    sensor = sensorSet(sensor,'name',sprintf('mouse-%.0f',vcCountObjects('sensor')));
%    sensor = sensorSet(sensor,'cfaPattern','mousePattern');
%
%    % try to get the current wavelengths from the scene or the oi.
%    % the mouse sees at different wavelengths than the human : we use
%    % 325-635 usually.
%    scene = vcGetObject('scene');
%    if isempty(scene)
%        getOi = 1;
%    else
%        spect = scene.spectrum.wave;
%        if isempty(spect),  getOi = 1;
%        else
%            mouseWave = spect;
%            getOi = 0;
%        end
%    end
%    if getOi
%       oi = vcGetObject('oi');
%       if isempty(oi), mouseWave = 325:5:635;
%       else spect = oi.optics.spectrum.wave;
%          if isempty(spect),  mouseWave = 325:5:635;
%          else                mouseWave = spect;
%          end
%       end
%    end
%    sensor = sensorSet(sensor,'wave',mouseWave);
%
%    [filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
%    sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
%    sensor = sensorSet(sensor,'filterNames',filterNames);

end
%}

%-----------------------------
function sensor = sensorInterleaved(sensor,filterPattern,filterFile)
%
%   Create a default interleaved image sensor array structure.

sensor = sensorSet(sensor,'name',sprintf('interleaved-%.0f',vcCountObjects('sensor')));
sensor = sensorSet(sensor,'cfaPattern',filterPattern);

% Read in a default set of filter spectra
[filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

end

%-----------------------------
function sensor = sensorCustom(sensor,filterPattern,filterFile)
%
%  Set up a sensor with multiple color filters.
%

sensor = sensorSet(sensor,'name',sprintf('custom-%.0f',vcCountObjects('sensor')));

sensor = sensorSet(sensor,'cfaPattern',filterPattern);

[filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);

% Force the first character of the filter names to be lower case
% This may not be necessary.  But we had a bug once and it is safer to
% force this. - BW
for ii=1:length(filterNames)
    filterNames{ii}(1) = lower(filterNames{ii}(1));
end

sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

end

function sensor = sensorMT9V024(sensor,colorType)
%% Create the ON MT9V024 model, based on the data sheet
%
% Called from sensorCreate.  Loads the relevant sensors that were
% saved out by another function
%
% Copyright Imageval, LLC 2017
%
% See also
%   isetcam/data/sensor/auto for the MT9V024Create.m

% 480 x 752 pixels
% 6 um pixels
% 60 FPS
% 10 bit
% Responsivity 4.8 V/lux-sec at 550 nm
% 3.3 V (voltage swing, only accurate to 0.3 V)
% 55 dB linear dynamic range
% 100 dB HDR mode
% 2x2 and 4x4 binning are available.

%{
pixelSize  = 6*1e-6; % Big pixels.  And they can be binned!
fillFactor = 0.9;  % Assuming back side illuminated
sensorSize = [480 752];    % Not important, really, but OK
voltageSwing = 3.3;
%}

% Let's check this.  From the spec sheet
% responsivity = 4.8;  % volts/lux-sec

%% Create and set parameters

switch colorType
    case 'mono'
        name = 'MT9V024SensorMono';
        
    case 'rgb'
        % GB/RG
        name = 'MT9V024SensorRGB';        
        
    case 'rccc'
        % Three white and one red
        name = 'MT9V024SensorRCCC';
        
    case 'rgbw'
        % Three white and one red
        name = 'MT9V024SensorRGBW';

    otherwise
        error('Unknown type %s\n',colorType);
end

sensorFile = fullfile(isetRootPath,'data','sensor','auto',name);
load(sensorFile,'sensor');

end

