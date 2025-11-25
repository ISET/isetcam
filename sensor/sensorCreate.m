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
%      {'MT9V024'}   - Omnivision
%                      sensorCreate('MT9V024',[],{'rgb','mono','rccc'})
%      {'ar0132at'}  - An ON sensor used in automotive applications
%                      sensorCreate('ar0132at',[],{'rgb','rgbw','rccc'})
%
%      {'imx363'}    - A widely used Sony digital camera sensor (used
%                      in the Google Pixel 4a)
%      {'ovt-large'}  - The Omnivision large pixel (Solhusvik,
%                       Johannes, et al. "1280× 960 2.8 µm HDR CIS
%                       with DCG)
%      {'ovt-small'}  - The Omnivision small pixel (See more notes below).
%      {'imx490-large'} - The Sony imx490 sensor large
%      {'imx490-small'} - The Sony imx490 sensor large
%
%      {'nikond100'} - An older model Nikon (D100)
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
%      {'imec44'} - IMEC 16 channel sensor, 5.5 um
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
%  IMEC 16 channel sensor
   sensor = sensorCreate('imec44',[],[400 400]);
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
  sensor = sensorCreate('Nikon D100');
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
  sensor = sensorCreate('ar0132at'); % To be implemented.  See notes.
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
    case {'bayer-ycmy','ycmy','bayer(ycmy)'}
        filterFile = 'cym';
        filterOrder = [2,1; 3,2];
        sensor = sensorBayer(sensor,filterOrder,filterFile);
    case {'bayer-cyym','bayer(cyym)','cyym'}
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
        if isempty(varargin), colorType = 'rgb';
        else,                 colorType = varargin{1};
        end
        sensor = sensorMT9V024(sensor,colorType);

    case {'ar0132at'}
        % ON RGB automotive sensor.
        %
        % See ar0132atCreate for how these were built.
        %
        % We should make this into a sensorCreateAR0132AT function.
        %
        if isempty(varargin), colorType = 'rgb';
        else,                 colorType = varargin{1};
        end

        switch ieParamFormat(colorType)
            case 'rgb'
                load('ar0132atSensorRGB.mat','sensor');
            case 'rccc'
                load('ar0132atSensorRCCC','sensor');
            case 'rgbw'
                load('ar0132atSensorRGBW.mat','sensor');
            otherwise
                error('Unknown AR0132at color type:  %s', colorType)
        end

        % We should rename sensorIMX363 to something like
        % sensorCreateBase. 
        %
    case {'imx363','googlepixel4a'}
        % A Sony sensor used in many systems
        %
        % To over-ride the row/col default use the varargin slots.
        %
        % sensorCreate('imx363',[],'row col',[300 400]);
        sensor = sensorIMX363('row col',[600 800], varargin{:});

        % Split pixel parameters for OVT
    case {'ovt-large'}
        % sensors = sensorCreate('ovt-large');
        %
        % Solhusvik, Johannes, et al. "1280× 960 2.8 µm HDR CIS with DCG and
        % Split-Pixel Combined." Proceedings of the International Image Sensor
        % Workshop (IISW), Snowbird, UT, USA. 2019.
        %
        % https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.
        %
        % They describe the large pixel in two configurations, with a
        % high and low conversion gain.  So the OVT model has three
        % effective sensors, LPD/HCG, LPD/LCG, SPD/LCG.
        %
        % The biggest difference between the large and small
        % photodiodes is the spectral QE. Because the small pixel is
        % both small and covered by a filter, it is less than 1
        % percent of the spectral qe of the large pixel. Their paper
        % (according to Fowler) incorporates both the size and the
        % filter in the spectral QE, so we do the same. So we set the
        % fill factor to 1 in all cases.
        %
        % They published the spectral QE curves, and these differ
        % slightly between the two pixels.  We scanned them with
        % grabit and read them in here.
        %
        % This architecture differs from the IMX490, which has 4
        % effective sensors. 

        % Low conversion gain is 49uV/e and high is 200 uV/e. I don't
        % believe the voltages change.  So, we implement the different
        % gains using the analog gain setting (200/49 ~ 4:1).
        %
        % The other numbers are all from Table 1, without the shift in
        % conversion gain, but substituting the analog gain factor.
        
        % Large Photodiode, High conversion gain
        params = struct('size',[968 1288], ...
            'pixel_sizesamefillfactor',2.8e-06, ...
            'pixel_voltageswing',22000*49e-6, ...
            'pixel_conversiongain', 49e-6, ...
            'pixel_fillfactor',1, ...
            'pixel_readnoiseelectrons',3.05,...
            'pixel_darkvoltage',25.6*49e-6,...
            'analoggain',1, ...
            'quantization','12 bit',...
            'name','ovt-LPDLCG');

        sensor = sensorCreate;
        pnames = fieldnames(params);
        for ii=1:numel(pnames)
            sensor = sensorSet(sensor,pnames{ii},params.(pnames{ii}));
        end

        qeFile = fullfile(isetRootPath,'data','sensor','colorfilters','OVT','ovt-large.mat');

        wave = sensorGet(sensor, 'wave');

        if isOctave()
            % Hardcoded filter names (since Octave can't read the cell array from .mat)
            [data, ~] = ieReadColorFilter(wave, qeFile);
            filterNames = {'r', 'g', 'b'};
        else    
            [data,filterNames] = ieReadColorFilter(wave,qeFile);
        end

        sensor = sensorSet(sensor, 'filter spectra', data);
        sensor = sensorSet(sensor, 'filter names', filterNames);

        % LPD-HCG - Higher voltage output
        sensor(2) = sensor(1);
        % Remember: analog gain is a divisor in ISETCam, not a multiplier
        params = struct('pixel_readnoiseelectrons',0.83,...
            'analoggain',49/200, ...
            'name','ovt-LPDHCG');

        pnames = fieldnames(params);
        for ii=1:numel(pnames)
            sensor(2) = sensorSet(sensor(2),pnames{ii},params.(pnames{ii}));
        end
        return;

    case {'ovt-small'}
        % See above.  Parameters from Table 1.
        % sensor = sensorCreate('ovt-small');

        % We make the pixel fill factor 1/100.  This reduces the
        % sensitivity, without changing the color filters or pixel
        % size.
        params = struct('size',[968 1288], ...
            'pixel_sizesamefillfactor',2.8e-06, ...
            'pixel_voltageswing',7900*49e-6, ...
            'pixel_conversiongain', 49e-6, ...
            'pixel_fillfactor',1e-2, ...
            'pixel_readnoiseelectrons',0.83,...
            'pixel_darkvoltage',4.2*49e-6,...
            'quantization','12 bit',...
            'name','ovt-SPDLCG');

        sensor = sensorCreate;
        pnames = fieldnames(params);
        for ii=1:numel(pnames)
            sensor = sensorSet(sensor,pnames{ii},params.(pnames{ii}));
        end

        % We have the small, but correcting for the differences is a
        % challenge.  So, we use the large twice.
        % qeFile = fullfile(isetRootPath,'data','sensor','colorfilters','OVT','ovt-small.mat');
        qeFile = fullfile(isetRootPath, 'data', 'sensor', 'colorfilters', 'OVT', 'ovt-large.mat');

        wave = sensorGet(sensor, 'wave');

        if isOctave()
            % Hardcoded filter names (since Octave can't read the cell array from .mat)
            [data, ~] = ieReadColorFilter(wave, qeFile);
            filterNames = {'r', 'g', 'b'};
        else    
            [data,filterNames] = ieReadColorFilter(wave,qeFile);
        end

        sensor = sensorSet(sensor, 'filter spectra', data);
        sensor = sensorSet(sensor, 'filter names', filterNames);


        return;

        % Split pixel parameters for IMX490
    case {'imx490-large'}
        % Variant of the IMX363 that contains a big pixel and a small
        % pixel. These pixel parameters were determined by Zhenyi as
        % part of ISETAuto. Each one of these pixels, the large and
        % small
        %
        % From the Lucid site.
        % Integration times
        %    min of 86.128 μs to max of 5 s
        %
        % Original value from ZL: 5.5845e-06.  But Lucid site says 3
        % um. I adjusted to 3um per the site, but shrunk the fill
        % factor.  The small pixel fits into the space and 0.85/.15
        params = struct('rowcol',[600 800], ...
            'pixelsize',3e-06, ...
            'dn2volts',0.25e-3, ...
            'digitalblacklevel', 0, ...
            'digitalwhitelevel', 4096, ...
            'wellcapacity', 120000, ...
            'fillfactor',0.9, ...
            'isospeed',55, ...
            'readnoise',1,...
            'quantization','12 bit',...
            'name','imx490-large');

        sensor = sensorIMX363(params);

    case {'imx490-small'}
        % Variant of the IMX363 that contains a big pixel and a small
        % pixel. These pixel parameters were determined by Zhenyi as
        % part of ISETAuto. Each one of these pixels, the large and
        % small

        params = struct('rowcol',[600 800], ...
            'pixelsize',3e-06, ...
            'dn2volts',0.25e-3, ...
            'digitalblacklevel', 0, ...
            'digitalwhitelevel', 4096, ...
            'wellcapacity', 60000, ...
            'fillfactor',0.1, ...
            'isospeed',55, ...
            'readnoise',1,...
            'quantization','12 bit',...
            'name','imx490-small');

        sensor = sensorIMX363(params);

    case 'nikond100'
        % Old model.  I increased the spatial samples before
        % returning the sensor.
        load('NikonD100Sensor','isa');
        isa.type = 'sensor';

        sensor = isa;
        sensor = sensorSet(sensor,'size',[72 88]*4);
        sensor = sensorSet(sensor,'name','Nikon-D100');

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
    case {'imec44'}
        % Returns a 400x400 version of the sensor.
        rowcol = [400 400];
        if length(varargin) >= 1
            rowcol = varargin{1};
        end
        sensor = sensorCreateIMECSSM4x4vis('row col',rowcol);
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
        else,                          wave = 400:10:700;
        end

        % Add the default human pixel with StockmanQuanta filters.
        sensor = sensorSet(sensor,'wave',wave);
        sensor = sensorSet(sensor,'pixel',pixelCreate('human',wave));

        % Build up a human cone mosaic.
        [sensor, xy, coneType, rSeed, rgbDensities] = ...
            sensorCreateConeMosaic(sensor, sz, rgbDensities, coneAperture, rSeed, 'human');
        %  figure(1); ieConePlot(xy,coneType);

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

if ~(isequal(sensorType, 'imx363') || isequal(sensorType,'imx490'))
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


