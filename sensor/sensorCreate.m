function sensor = sensorCreate(sensorType,pixel,varargin)
%Create an image sensor array structure
%
% Synopsis
%   sensor = sensorCreate(sensorType,[pixel],varargin)
%
% Description
%  The sensor array uses a pixel definition that can be specified in the
%  parameter PIXEL. If this is not passed in, a default PIXEL is created and
%  returned.
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
% Vendor parts calibrated over the years or from the web
%      {'MT9V024'}  - sensorCreate('MT9V024',[],{'rgb','mono','rccc'})
%      {'ar0132at'} - An ON sensor used in automotive applications
%      {'imx363'}   - A widely used Sony digital camera sensor
%
% Other types
%      {'monochrome'}       - single monochrome sensor
%      {'monochrome array'} - cell array of monochrome sensors
%      {'lightfield'}       - RGB to match the resolution of a lightfield oi
%      {'dualpixel'}        - RGB dual pixel for autofocus (Bayer)
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
% Copyright ImagEval Consultants, LLC, 2005
%
% See also:
%   sensorReadColorFilters, sensorCreateIdeal
%

% Examples:
%{
%  Default Bayer RGGB
   sensor = sensorCreate;
   sensor = sensorCreate('default');
%}
%{
%  Other types of Bayer arrays
   sensor = sensorCreate('bayer (ycmy)');
   sensor = sensorCreate('bayer (rggb)');
%}
%{
%  A monochrome sensor
   sensor = sensorCreate('Monochrome');
%}
%{
%  A light field sensor matched to an OI rendered from PBRT.  Note that oi
%  is passed instead of pixel
%
%  Improve this example!  We have scripts that use this.
%
%   sensor = sensorCreate('light field',oi);
%
%}
%{
%  Human style sensors (but see ISETBIO for more complete control)
   cone   = pixelCreate('human cone');
   sensor = sensorCreate('Monochrome',cone);
   sensor = sensorCreate('human');
   params.sz = [128,192];
   params.rgbDensities = [0.1 .6 .2 .1]; % Empty, L,M,S
   params.coneAperture = [3 3]*1e-6;     % In meters
   pixel = [];
   sensor = sensorCreate('human',pixel,params);
   sensorConePlot(sensor)
%}
%{
%  More details specified
   filterOrder = [1 2 3; 4 5 2; 3 1 4];
   wave = 400:2:700;
   filterFile = fullfile(isetRootPath,'data','sensor','colorfilters','sixChannel.mat');
   pixel = pixelCreate('default',wave);
   sensorSize = [256 256];
   sensor = sensorCreate('custom',pixel,filterOrder,filterFile,sensorSize,wave)
%}
%{
  sensor = sensorCreate('imx363');
  sensor = sensorCreate('mt9v024');
  % sensor = sensorCreate('ar0132at'); % To be implemented.  See notes.
%}

%%
if ieNotDefined('sensorType'), sensorType = 'default'; end

sensor.name = [];
sensor.type = 'sensor';

% Make sure a pixel is defined.
if ieNotDefined('pixel')
    pixel  = pixelCreate('default');
    sensor = sensorSet(sensor,'pixel',pixel);
    sensor = sensorSet(sensor,'size',sensorFormats('qqcif'));
elseif isfield(pixel,'type') && isequal(pixel.type,'pixel')
    sensor = sensorSet(sensor,'pixel',pixel);
elseif (isequal('lightfield',ieParamFormat(sensorType)) || ...
        isequal('dualpixel',ieParamFormat(sensorType))) && ...
        isequal(pixel.type,'opticalimage')
    % Special case of a light field camera
    varargin{1} = pixel;
    pixel  = pixelCreate('default');
    sensor = sensorSet(sensor,'pixel',pixel);
    sensor = sensorSet(sensor,'size',sensorFormats('qqcif'));
else
    disp(pixel)
    error('Bad pixel definition');
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

sensorType = ieParamFormat(sensorType);
switch sensorType
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
            % Sometimes we seem to let people put in an oi rather than
            % pixel into this slight.
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
    case {'dualpixel'}
        % sensor = sensorCreate('dual pixel',[], oi, nMicrolens);
        %   
        %   nMicrolens is the row and col number of the microlens
        %   array 
        %
        % We set the pixel size to match the spatial sampling of the
        % optical image in the light field case.  In the dual pixel
        % case we make a pixel whose height (or width?) is double the
        % size of the sampling.
        %
        % In the future: We should be able to specify the orientation
        % (h or v) of the dual pixels.
        %
        
        oi = varargin{1};
        ss_meters = oiGet(oi,'sample spacing','m');
        
        % Default original sensor
        sensor = sensorCreate;
        
        % We make the height bigger than the width
        sensor = sensorSet(sensor,'pixel height',2*ss_meters(1));
        sensor = sensorSet(sensor,'pixel width',ss_meters(1));
        
        % Double the number of columns
        nMicrolens = varargin{2};
        sensor = sensorSet(sensor,'size',[nMicrolens(1), 2*nMicrolens(2)]);

        % Set the CFA pattern accounting for the new dual pixel
        % architecture 
        sensor = sensorSet(sensor,'pattern',[2 2 1 1; 3 3 2 2]);

        
    case {'mt9v024'}
        % ON 6um sensor.  It can be mono, rgb, or rccc
        % sensor = sensorCreate('MT9V024',[],'rccc');
        if isempty(varargin)
            colorType = 'rgb';
        else
            colorType = varargin{1};
        end
        sensor = sensorMT9V024(sensor,colorType);
        
        %{
    case {'ar0132at'}
        % ON RGB automotive sensor.
        %
        % See ar0132atCreate
        % sensor = sensorAR0132AT(sensor);
        %}
        
    case {'imx363'}
        % A Sony sensor used in many systems
        % To over-ride the row/col default use
        %
        % sensorCreate('imx363',[],'row col',[300 400]);
        sensor = sensorIMX363('row col',[600 800], varargin{:});
        
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
        else, params = [];
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
        
    case {'custom'}      % Often used for multiple channel
        % sensorCreate('custom',filterColorLetters,filterPattern,filterFile,wave);
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

    otherwise
        error('Unknown sensor type');
end

% Set the exposure time - this needs a CFA to be established to account for
% CFA exposure mode.
sensor = sensorSet(sensor,'integrationTime',0);
sensor = sensorSet(sensor,'autoexposure',1);
sensor = sensorSet(sensor,'CDS',0);

if ~isequal(sensorType, 'imx363')
    % Put in a default infrared filter.  All ones.
    sensor = sensorSet(sensor,'irfilter',ones(sensorGet(sensor,'nwave'),1));
end

% Place holder for charts, such as the MCC
sensor = sensorSet(sensor,'chart parameters',[]);

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
function sensor = sensorInterleaved(sensor,filterPattern,filterFile)
%
%   Create a default interleaved image sensor array structure.

sensor = sensorSet(sensor,'name',sprintf('interleaved-%.0f',vcCountObjects('sensor')));
sensor = sensorSet(sensor,'cfaPattern',filterPattern);

% Read in a default set of filter spectra
% [filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
if ischar(filterFile) && exist(filterFile,'file')
    [filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
elseif isstruct(filterFile)
    filterSpectra = filterFile.data;
    filterNames   = filterFile.filterNames;
    filterWave    = filterFile.wavelength;
    extrapVal = 0;
    filterSpectra = interp1(filterWave, filterSpectra, sensorGet(sensor,'wave'),...
        'linear',extrapVal);
else
    error('Bad format for filterFile variable.');
end

sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

end

%-----------------------------
function sensor = sensorCustom(sensor,filterPattern,filterFile)
%
%  Set up a sensor with multiple color filters.
%

% Add the count
sensor = sensorSet(sensor,'name',sprintf('custom-%.0f',vcCountObjects('sensor')));

% Spatial pattern
sensor = sensorSet(sensor,'cfaPattern',filterPattern);

if ischar(filterFile) && exist(filterFile,'file')
    [filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
elseif isstruct(filterFile)
    filterSpectra = filterFile.data;
    filterNames   = filterFile.filterNames;
    filterWave    = filterFile.wavelength;
    extrapVal = 0;
    filterSpectra = interp1(filterWave, filterSpectra, sensorGet(sensor,'wave'),...
        'linear',extrapVal);
else
    error('Bad format for filterFile variable.');
end

% Force the first character of the filter names to be lower case
% This may not be necessary.  But we had a bug once and it is safer to
% force this. - BW
for ii=1:length(filterNames)
    filterNames{ii}(1) = lower(filterNames{ii}(1));
end

sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

end

function sensor = sensorMT9V024(~,colorType)
%% Create the ON MT9V024 model, based on the data sheet
%
% Internal to sensorCreate.  Loads the relevant sensors that were saved out
% by another function
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

function sensor = sensorIMX363(varargin)
% Create the sensor structure for the IMX363
%
% Synopsis
%    sensor = sensorIMX363(varargin);
%
% Brief description
%    Creates the default IMX363 sensor model
%
% Inputs
%   N/A
%
% Optional Key/val pairs
%
% Return
%   sensor - struct with the IMX363 model parameters
%
% Examples:  ieExamplesPrint('sensorIMX363');
%
% See also
%  sensorCreate

% Examples:
%{
 % The defaults and some plots
 sensor = sensorCreate('IMX363');
 sensorPlot(sensor,'spectral qe');
 sensorPlot(sensor,'cfa block');
 sensorPlot(sensor,'pixel snr');
%}
%{
 % Adjust a parameter
 sensor = sensorCreate('IMX363',[],'row col',[256 384]);
 sensorPlot(sensor,'cfa full');
%}

%% Parse parameters

% Building up the input parser will let you do more experiments with the
% sensor.

% This removes spaces and lowers all the letters so you don't have to
% remember the syntax when you call the argument
varargin = ieParamFormat(varargin);

% Start parsing
p = inputParser;

% Set the default values here
p.addParameter('rowcol',[3024 4032],@isvector);
p.addParameter('pixelsize',1.4 *1e-6,@isnumeric);
p.addParameter('analoggain',1.4 *1e-6,@isnumeric);
p.addParameter('isospeed',270,@isnumeric);
p.addParameter('isounitygain', 55, @isnumeric);
p.addParameter('quantization','10 bit',@(x)(ismember(x,{'12 bit','10 bit','8 bit','analog'})));
p.addParameter('dsnu',0,@isnumeric); % 0.0726
p.addParameter('prnu',0.7,@isnumeric);
p.addParameter('fillfactor',1,@isnumeric);
p.addParameter('darkvoltage',0,@isnumeric);
p.addParameter('dn2volts',0.44875 * 1e-3,@isnumeric);
p.addParameter('digitalblacklevel', 64, @isnumeric);
p.addParameter('digitalwhitelevel', 1023, @isnumeric);
p.addParameter('wellcapacity',6000,@isnumeric);
p.addParameter('exposuretime',1/60,@isnumeric);
p.addParameter('wave',390:10:710,@isnumeric);
p.addParameter('readnoise',5,@isnumeric);
p.addParameter('qefilename', fullfile(isetRootPath,'data','sensor','qe_IMX363_public.mat'), @isfile);
p.addParameter('irfilename', fullfile(isetRootPath,'data','sensor','ircf_public.mat'), @isfile);

% Parse the varargin to get the parameters
p.parse(varargin{:});

rows = p.Results.rowcol(1);             % Number of row samples
cols = p.Results.rowcol(2);             % Number of col samples
pixelsize    = p.Results.pixelsize;     % Meters
isoSpeed     = p.Results.isospeed;      % ISOSpeed, whatever that is
isoUnityGain = p.Results.isounitygain;  % ISO speed equivalent to analog gain of 1x, for Pixel 4: ISO55
quantization = p.Results.quantization;  % quantization method - could be 'analog' or '10 bit' or others
wavelengths  = p.Results.wave;          % Wavelength samples (nm)
dsnu         = p.Results.dsnu;          % Dark signal nonuniformity
fillfactor   = p.Results.fillfactor;    % A fraction of the pixel area
darkvoltage  = p.Results.darkvoltage;   % Volts/sec
dn2volts     = p.Results.dn2volts;        % volt per DN
blacklevel   = p.Results.digitalblacklevel; % black level offset in DN
whitelevel   = p.Results.digitalwhitelevel; % white level in DN
wellcapacity = p.Results.wellcapacity;  % Electrons
exposuretime = p.Results.exposuretime;  % in seconds
prnu         = p.Results.prnu;          % Photoresponse nonuniformity
readnoise    = p.Results.readnoise;     % Read noise in electrons
qefilename   = p.Results.qefilename;    % QE curve file name
irfilename   = p.Results.irfilename;    % IR cut filter file name
%% Initialize the sensor object

sensor = sensorCreate('bayer-rggb');

%% Pixel properties
voltageSwing   = whitelevel * dn2volts;
conversiongain = voltageSwing/wellcapacity; % V/e-

% set the pixel properties
sensor = sensorSet(sensor,'pixel size same fill factor',[pixelsize pixelsize]);
sensor = sensorSet(sensor,'pixel conversion gain', conversiongain);
sensor = sensorSet(sensor,'pixel voltage swing', voltageSwing);
sensor = sensorSet(sensor,'pixel dark voltage', darkvoltage) ;
sensor = sensorSet(sensor,'pixel read noise electrons', readnoise);

% Gain and offset - Principles
%
% In ISETCam we use this formula to incorporate channel gain and offset
%
%         (volts + offset)/gain
%
% Higher ISOspeed requires a bigger multiplier, so we use a formulat like
% this to convert speed to gain.  We should probably make 55 a parameter of
% the system in the inputs, defaulting to 55.
analogGain     = isoUnityGain/isoSpeed; % For Pixel 4, ISO55 = gain of 1

% A second goal is that the offset in digital counts is intended to be a
% fixed level, no matter what the gain might be.  To achieve that we need
% to multiply the 64*one_lsb by the analogGain
%
analogOffset   = (blacklevel * dn2volts) * analogGain; % sensor black level, in volts

% The result is that the output volts are
%
%    outputV = (inputV + analogOffset)/analogGain
%    outputV = inputV*ISOSpeed/55 + analogOffset/analogGain
%    outputV = inputV*ISOSpeed/55 + 64*dn2volts
%
% Since the ADC always operates linearly on the voltage, and the step size
% is one_lsb, the black level for the outputV is always 64.  The gain on
% the input signal is (ISOSpeed/55)
%
%
%% Set sensor properties
%sensor = sensorSet(sensor,'auto exposure',true);
sensor = sensorSet(sensor,'rows',rows);
sensor = sensorSet(sensor,'cols',cols);
sensor = sensorSet(sensor,'dsnu level',dsnu);
sensor = sensorSet(sensor,'prnu level',prnu);
sensor = sensorSet(sensor,'analog Gain',analogGain);
sensor = sensorSet(sensor,'analog Offset',analogOffset);
sensor = sensorSet(sensor,'exp time',exposuretime);
sensor = sensorSet(sensor,'quantization method', quantization);
sensor = sensorSet(sensor,'wave', wavelengths);

% Adjust the pixel fill factor
sensor = pixelCenterFillPD(sensor,fillfactor);

% import QE curve
[data,filterNames] = ieReadColorFilter(wavelengths,qefilename);
sensor = sensorSet(sensor,'filter spectra',data);
sensor = sensorSet(sensor,'filter names',filterNames);
sensor = sensorSet(sensor,'Name','IMX363');

% import IR cut filter
sensor = sensorReadFilter('infrared', sensor, irfilename);

end
