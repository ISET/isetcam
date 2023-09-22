function [scene,parms] = sceneCreate(sceneName,varargin)
% Create a scene structure.
%
% Syntax:
%  [scene,parms] = sceneCreate(sceneName,varargin)
%
% Brief Description:
% A scene describes the photons emitted from each visible point in the
% scene. Generally, we model planar objects, such as a screen display (but
% see below).
%
% The scene is located at some distance from the center of the optics, hasG
% a field of view, and a spectral radiance distribution.  There are
% routines to handle depth as well that are partly implemented and under
% development.  We plan to integrate this aspect of the modeling with PBRT.
%
% A variety of scene types can be created automatically.  The routines that
% create these scenes, including this one, serve as a template for creating
% others you may wish to design.
%
% Scene radiance data are represented as photons single precision. The
% spectral representation is 400:10:700 by default.  Both of these can be
% changed.
%
% See also: sceneInterpolateW, sceneAdjustLuminance, sceneAdjustIlluminant
%
% MACBETH COLOR AND LUMINANCE CHART
%
%   The default, scene = sceneCreate, is a Macbeth color checker illuminated
%   by a D65 light source with a mean luminance of 100 cd/m2.  The scene is
%   described only a small number of spatial 64x96 (row,col).  This can be
%   changed using the patchSize argument (default - 16 pixels).  The
%   wavelength  400:10:700 samples, making it efficient to use for experiments.
%
%   Example:
%    scene = sceneCreate('macbeth',32);
%
%    patchSize = 8;
%    wave = (380:4:1068)';
%    scene = sceneCreate('macbethEE_IR',patchSize,wave);
%
%      {'macbeth d65'}         - Macbeth D65 image.
%      {'macbeth d50'}         - D50 illuminant
%      {'macbeth illc'}        - Illuminant C
%      {'macbeth fluorescent'} - Fluorescent illuminant
%      {'macbeth tungsten'}    - Tungsten illuminant
%      {'macbeth EE_IR'}       - Equal energy extends out to the IR
%      {L star}                - Vertical bars spaced in equal L* steps
%
%   The size of the individual patches, or bars, and wavelength sampling
%   are parameters. They can be set a additional parameters
%
%         patchSizePixels = 16;
%         wave = [380:5:720];
%         scene = sceneCreate('macbeth Tungsten',patchSizePixels,wave);
%
%   If you would like the color checker to have black borders around the
%   patches, then use
%
%        patchSizePixels = 16; wave = [380:5:720]; blackBorder = true;
%        scene = sceneCreate('macbeth d65',patchSizePixels,wave,...
%                  'macbethChart.mat',blackBorder);
%
%   For a bar width of 50 pixels, 5 bars, at L* levels (1:nBars)-1 * 10, use
%         scene = sceneCreate('lstar',50,5,10);
%
%   Use sceneAdjustIlluminant() to change the scene SPD.
%
% REFLECTANCE CHART
%
%   {'reflectance chart'} - Natural-100 reflectance chart.
%
%   You can also create your own specific chart this way:
%
%    sFiles{1} = 'MunsellSamples_Vhrel.mat';
%    sFiles{2} = 'Food_Vhrel.mat';
%    pSize = 24; sSamples = [18 18];
%    wave = 400:10:700; grayFlag = 0; sampling = 'r';
%    scene = sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
%
% NARROWBAND COLOR PATCHES
%    wave = [600, 610];  sz = 64;
%    scene = sceneCreate('uniform monochromatic',wave,sz);
%
% SPATIAL TEST PATTERNS:
%
%      {'rings rays'}            - Resolution pattern
%      {'harmonic'}              - Harmonics (can be sums of harmonics)
%      {'sweep frequency'}       - Increasing frequency to the right,
%               increasing contrast upward
%      {'line d65'}              - Line with D65 energy spectrum
%      {'line ee'}               - Line with equal energy spectrum
%      {'bar ee'}                - Vertical bar, equal energy
%      {'point array'}           - Point array
%      {'gridlines'}             - Grid lines
%      {'checkerboard'}          - Checkerboard with equal photon spectrum
%      {'frequency orientation'} - Demosaicking test pattern, equal photon spectrum
%      {'slanted edge'} - Used for ISO spatial resolution, equal photon spectrum
%      {'moire orient'} - Circular Moire pattern
%      {'zone plate'}   - Circular zone plot, equal photon spectrum
%      {'star pattern'} - Thin radial lines used to test printers and displays
%      {'letter'}       - Create an image of a letter.
%
%  Additional parameters are available for several of the patterns.  For
%  example, the harmonic call can set the frequency, contrast, phase,
%  angle, row and col size of the harmonic.  The frequency unit in this
%  case is cycles/image.  To obtain cycles per degree, divide by the field
%  of view.
%
%        parms.freq = 1; parms.contrast = 1; parms.ph = 0;
%        parms.ang= 0; parms.row = 128; parms.col = 128;
%        parms.GaborFlag=0;
%        [scene,parms] = sceneCreate('harmonic',parms);
%
%  See the script s_sceneHarmonics for more examples.  In this example, the
%  illuminant is set so that the mean of the harmonic has a 20%
%  reflectance, like a typical gray card.
%
%  Many of the patterns can have an arbitrary image (row,col) size.  This
%  is possible for whitenoise, impulse1dee,lined65
%
%         imSize = 128; lineOffset = 25;           % Plus is to the right
%         scene = sceneCreate('lined65',imSize);
%         scene = sceneCreate('line ee',imSize,lineOffset);
%         sceneCreate('bar',imageSize,width);
%
%  Other patterns have different parameters:
%         sceneCreate('slanted edge',imageSize,edgeSlope,fov,wave,darklevel);
%         sceneCreate('checkerboard',pixelsPerCheck,numberOfChecks)
%         sceneCreate('grid lines',imageSize,pixelsBetweenLines);
%         sceneCreate('point array',imageSize,pixelsBetweenPoints);
%         sceneCreate('moire orient',imageSize,edgeSlope);
%         sceneCreate('vernier',imageSize,lineWidth,pixelOffset);
%         sceneCreate('star pattern',imageSize,spectralType,nLines);
%         sceneCreate('rings rays',radialFreq,imageSize);
%         sceneCreate('sweep frequency',imageSize,maxFrequency);
%         scene = sceneCreate('letter', font, display);
%
% NOISE ANALYSIS TEST PATTERNS
%
%      {'linear intensity ramp'}  - Equal photon
%      {'exponential intensity ramp'} - Equal photon
%      {'uniformEqualEnergy'}   - Equal energy
%      {'uniformEqualPhoton'}   - Equal photon density
%      {'uniformd65'}           - D65 SPD
%      {'whitenoise'}           - Noise pattern for testing
%
%    The uniform patterns are small by default (32,32).  If you would like
%    them at a higher density (not much point), you can use
%
%        scene = sceneCreate('uniformD65',256);
%
%    Notice that the dynamic range is not in log unit, but rather a
%    linear dynamic range.  sz is the row/col size of the image
%
%        sz = 256; dynamicRange = 1024;
%        scene = sceneCreate('linear intensity ramp',sz,dynamicRange);
%
%        scene = sceneCreate('exponential intensity ramp',sz,dynamicRange);
%
% SCENES FROM IMAGE DATA
%   We create scenes using RGB data in image files and a model display.  In
%   this approach, we simply read a tiff or jpeg file and create a scene
%   structure assuming the radiance is from a calibrated display.  These
%   image-based scenes created by sceneFromFile.  See the comments there
%   for more information.
%
% EMPTY
%   For certain programming reasons, it is sometimes useful to have a scene
%   with no data (no photons). In that case, you can call
%
%     scene = sceneCreate('empty')
%
%   which is precisely the same as
%
%     scene = sceneClearData(sceneCreate);
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:
%  sceneFromFile, displayCreate, s_sceneReflectanceCharts.m

%% Initial definition
if ~exist('sceneName','var')||isempty(sceneName), sceneName = 'default'; end
parms = [];  % Returned in some cases, not many.

% Identify the object type
scene.type = 'scene';

sceneName = ieParamFormat(sceneName);
scene.metadata = [];   % Metadata for machine learning apps

%% Handle all the Macbeth cases here
if strncmp(sceneName,'macbeth',5) || ...
        strcmp(sceneName,'default') || ...
        strcmp(sceneName,'empty')
    patchSize = 16; wave = 400:10:700; surfaceFile = 'macbethChart.mat';
    blackBorder = false;
    if ~isempty(varargin), patchSize = varargin{1}; end  % pixels per patch
    if length(varargin) > 1, wave = varargin{2}; end     % wave
    if length(varargin) > 2, surfaceFile = varargin{3}; end % Reflectances
    if length(varargin) > 3, blackBorder = varargin{4}; end %
end

%% Create the scene options
switch sceneName
    case 'default'
        % scene = sceneCreate('default',patchSize,wave);
        % Default is a Macbeth, D65.
        % User can set patch sizes and wavelength.
        scene = sceneDefault(scene,'d65',patchSize,wave);
    case {'list','scenelist'}
        doc('sceneList');
        return;
    case 'empty'
        % scene = sceneCreate('empty',[],wave)
        %
        % Sometimes you just want an empty scene structure with some
        % wavelength sampling.
        scene = sceneDefault(scene,'d65',[],wave);
        scene = sceneClearData(scene);
    case {'macbeth','macbethd65'}
        % sceneCreate('macbethD65',patchSize,wave);
        scene = sceneDefault(scene,'d65',patchSize,wave,surfaceFile,blackBorder);
    case {'macbethd50'}
        scene = sceneDefault(scene,'d50',patchSize,wave,surfaceFile,blackBorder);
    case {'macbethc','macbethillc'}
        scene = sceneDefault(scene,'c',patchSize,wave,surfaceFile,blackBorder);
    case {'macbethfluorescent','macbethfluor'}
        scene = sceneDefault(scene,'fluorescent',patchSize,wave,surfaceFile,blackBorder);
    case {'macbethtungsten','macbethtung'}
        scene = sceneDefault(scene,'tungsten',patchSize,wave,surfaceFile,blackBorder);
    case {'macbethee_ir','macbethequalenergyinfrared'}
        % Equal energy illumination into the IR
        scene = sceneDefault(scene,'ir',patchSize,wave,surfaceFile,blackBorder);
    case {'macbethcustomreflectance'}
        % s = sceneCreate('macbeth custom reflectance',patchSize,wave,surfaceFile)
        % s = sceneCreate('macbeth custom reflectance',32,400:10:700,'macbethChart2.mat');
        scene = sceneDefault(scene,'d65',patchSize,wave,surfaceFile,blackBorder);
        
    case {'reflectancechart'}
        % sceneCreate('reflectance chart',pSize,sSamples,sFiles,wave,grayFlag,sampling);
        % sceneCreate('reflectance chart',chartP);
        % There is always a gray strip at the right.
        
        if ~isempty(varargin) && isstruct(varargin{1})
            chartP   = varargin{1};
            sFiles   = chartP.sFiles;     % Surface reflectance files
            sSamples = chartP.sSamples;   % 100 samples, should be 10x10
            pSize    = chartP.pSize;      % Patch size in pixels
            wave     = chartP.wave;       % Wavelength samples
            grayFlag = chartP.grayFlag;   % Add a gray strip column on right
            sampling = chartP.sampling;   % Sample with replacement
        else
            
            % Default surface files
            sFiles{1} = which('MunsellSamples_Vhrel.mat');
            sFiles{2} = which('Food_Vhrel.mat');
            sFiles{3} = which('HyspexSkinReflectance.mat');
            %{
              sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','MunsellSamples_Vhrel.mat');
              sFiles{2} = fullfile(isetRootPath,'data','surfaces','reflectances','Food_Vhrel.mat');
              sFiles{3} = fullfile(isetRootPath,'data','surfaces','reflectances','skin','HyspexSkinReflectance.mat');
            %}
            
            % Surface samples from the files
            sSamples = [50 40 10];   % 100 samples, should be 10x10
            pSize = 24;     % Patch size in pixels
            wave = [];      % Wavelength samples
            grayFlag = 1;   % Add a gray strip column on right
            sampling = 'r'; % Sample with replacement
            
            if isempty(varargin)
            else
                pSize = varargin{1};
                if length(varargin) > 1, sSamples = varargin{2}; end
                if length(varargin) > 2, sFiles   = varargin{3}; end
                if length(varargin) > 3, wave     = varargin{4}; end
                if length(varargin) > 4, grayFlag = varargin{5}; end
                if length(varargin) > 5, sampling = varargin{6}; end
            end
        end
        
        scene = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayFlag,sampling);
        
    case {'lstar'}
        % For a bar width of 50 pixels, 5 bars, at L* levels (1:nBars)-1 * 10, use
        %   scene = sceneCreate('lstar',50,5,10);
        %   ieAddObject(scene); sceneWindow;
        bSize = [128 20]; nBars = 10; deltaE = 10;
        if ~isempty(varargin)
            bSize = varargin{1};
            if length(varargin)>1, nBars  = varargin{2}; end
            if length(varargin)>2, deltaE = varargin{3}; end
        end
        scene = sceneLstarSteps(scene,bSize,nBars,deltaE);
        scene = sceneSet(scene,'name',sprintf('L-star (%d)',deltaE));
        
        % Monochrome,RGB and multispectral add only a little.  Mostly created in sceneFromFile
    case {'monochrome','unispectral'}
        % sceneMonochrome is used for images with only one spectral band.
        scene = sceneMonochrome(scene);
    case {'multispectral','hyperspectral'}
        scene = sceneMultispectral(scene);
    case 'rgb'
        if isempty(varargin), scene = sceneRGB(scene);
        else, scene = sceneRGB(varargin{1});end
        
    case {'mackay','rayimage','ringsrays'}
        % Also called the Siemens star pattern
        % radF = 24; imSize = 512;
        % ieAddObject(sceneCreate('mackay',radF,imSize));
        % sceneWindow();
        radFreq = 8; sz = 256;
        if length(varargin) >= 1, radFreq = varargin{1}; end
        if length(varargin) >= 2, sz = varargin{2}; end
        if length(varargin) >= 3
            wave  = varargin{3};
            scene = sceneSet(scene,'wave',wave);
        end
        scene = sceneMackay(scene,radFreq,sz);
    case {'harmonic','sinusoid'}
        %
        % scene = sceneCreate(scene,'harmonic',imageHparams);
        %
        % The scene spectral radiance is set to an equal photon radiance
        % (not equal energy).
        %
        if isempty(varargin)
            [scene,parms] = sceneHarmonic(scene);
        elseif length(varargin) == 1
            parms = varargin{1};
            [scene,parms] = sceneHarmonic(scene,parms);
        elseif length(varargin) == 2
            parms = varargin{1};
            wave = varargin{2};
            [scene,parms] = sceneHarmonic(scene,parms, wave);
        else
            error('Wrong number of parameters! Input params structure and optional wavelengths.')
        end
    case {'sweep','sweepfrequency'}
        % sceneCreate('sweepFrequency',sz,maxF);
        % sz = 512; maxF = sz/16;
        %
        % These are always equal photon type.  Could add a third argument
        % for spectral type.  Also, we should make this work with
        % varargin{1} being a struct with the parameters.
        sz = 128; maxFreq = sz/16;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, maxFreq = varargin{2}; end
        scene = sceneSweep(scene,sz,maxFreq);
        parms.sz = sz; 
        parms.maxFreq = maxFreq;
    case {'ramp','linearintensityramp','rampequalphoton'}
        % scene = sceneCreate('ramp',sz,dynamicRange);
        % The linear ramp has reduced contrast from top to bottom.
        % The exp ramp is the same across the rows.
        
        sz = 256; dynamicRange = 256;
        if length(varargin) >= 1,  sz = varargin{1}; end
        if length(varargin) >= 2,  dynamicRange = varargin{2}; end
        
        scene = sceneRamp(scene,sz,dynamicRange);
        
    case {'expramp','exponentialintensityramp'}
        % scene = sceneCreate('exponential intensity ramp',sz,dynamicRange);
        % The exp ramp is the same for all rows.
        % The linear ramp has reduced contrast from top to bottom.
        sz = 256; dynamicRange = 256;
        if length(varargin) >= 1,  sz = varargin{1}; end
        if length(varargin) >= 2,  dynamicRange = varargin{2}; end
        
        scene = sceneExpRamp(scene,sz,dynamicRange);
        
    case {'uniform','uniformee','uniformequalenergy'}
        % scene = sceneCreate('uniform',size,wave);
        % Equal energy
        % By default a 32 x 32 with standard wave sampling
        %
        sz = 32;
        if ~isempty(varargin) && ~isempty(varargin{1})
            sz = varargin{1};
        end
        if length(varargin) > 1 && ~isempty(varargin{2})
            wave = varargin{2};
            scene = sceneSet(scene,'wave',wave);
        end
        scene = sceneUniform(scene,'equal energy',sz);
        
    case {'uniformeespecify'}   % Equal energy, specify waveband
        % scene = sceneCreate('uniformEESpecify',sz,wavelength);
        sz = 32; wavelength = 400:10:700;
        if ~isempty(varargin), sz = varargin{1}; end
        if length(varargin) > 1, wavelength = varargin{2}; end
        scene = sceneSet(scene,'wave',wavelength(:));
        scene = sceneUniform(scene,'equalenergy',sz);
    case {'uniformequalphoton','uniformephoton'}        %Equal photon density
        % sceneCreate('uniformEqualPhoton',128);
        if isempty(varargin)
            sz = 32;
            scene = sceneUniform(scene,'equal photons',sz);
        elseif length(varargin) == 1
            sz = varargin{1};
            scene = sceneUniform(scene,'equal photons',sz);
        elseif length(varargin) == 2
            sz = varargin{1};
            wave = varargin{2};
            scene = sceneUniform(scene,'equal photons',sz, wave);
        else
            error('Wrong number of arguments : looking for size (optional), wavelengths (optional)');
        end
    case 'uniformd65'
        % sceneCreate('uniformEqualPhoton',64);
        % We should include an option for wavelength so that we extend into
        % the IR
        if isempty(varargin),  sz = 32;
        else,                  sz = varargin{1};
        end
        scene = sceneUniform(scene,'D65',sz);
    case {'uniformbb'}
        % scene = sceneCreate('uniformBB',64,5000,400:700);
        if ~isempty(varargin)
            if length(varargin) >= 1, sz = varargin{1}; end
            if length(varargin) >= 2, cTemp = varargin{2}; end
            if length(varargin) >= 3, scene = sceneSet(scene,'wave',varargin{3}); end
        else
            sz = 32; cTemp = 5000;
        end
        scene = sceneUniform(scene,'blackbody',sz,cTemp);
    case {'uniformmonochromatic'}
        % scene = sceneCreate('uniform monochromatic',sz,wavelength);
        
        % Create a uniform, monochromatic image.  Used for color-matching
        % analyses.  Set the peak radiance in photons.
        sz = 128; wavelength = 500;
        if length(varargin) >= 1, wavelength = varargin{1}; end
        if length(varargin) >= 2, sz = varargin{2}; end
        
        scene = sceneSet(scene,'wave',wavelength);
        scene = sceneUniform(scene,'equalenergy',sz);
        scene = sceneSet(scene,'name','narrow band');
        
    case {'line','lined65','impulse1dd65'}
        if isempty(varargin), sz = 64;
        else, sz = varargin{1};
        end
        scene = sceneLine(scene,'D65',sz);
    case {'lineee','impulse1dee'}
        % scene = sceneCreate('line ee',size,offset,wave);
        % size:   Image row/col
        % offset: Pixel offset from center (c + offset)
        % wave:   Wavelength samples
        % scene = sceneCreate('lineee',128,2);
        % scene = sceneCreate('lineee',128,2,380:4:1068);
        sz = 64; offset = 0;
        if length(varargin) >= 1, sz = varargin{1};     end
        if length(varargin) >= 2, offset = varargin{2}; end
        if length(varargin) == 3
            scene = sceneSet(scene,'wave',varargin{3});
        end
        scene = sceneLine(scene,'equalEnergy',sz,offset);
    case {'lineequalphoton','lineep'}
        % sceneCreate('line ep',sz,offset);
        sz = 64; offset = 0;
        if length(varargin) >= 1, sz = varargin{1};     end
        if length(varargin) >= 2, offset = varargin{2}; end
        scene = sceneLine(scene,'equalPhoton',sz,offset);
    case {'bar'}
        % sceneCreate('bar',sz,width)
        sz = 64; width = 3;
        if length(varargin) >=1, sz    = varargin{1};   end
        if length(varargin) >=2, width = varargin{2};   end
        scene = sceneBar(scene,sz,width);
    case {'vernier'}
        % sceneCreate('vernier',size,width,offset)
        sz = 65; width = 3; offset = 3;
        lineReflectance = 0.6;
        backReflectance = 0.3;
        if length(varargin) >=1, sz     = varargin{1};   end
        if length(varargin) >=2, width  = varargin{2};   end
        if length(varargin) >=3, offset = varargin{3};   end
        if length(varargin) >=4, lineReflectance = varargin{4};   end
        if length(varargin) ==5, backReflectance = varargin{5};   end
        
        scene = sceneVernier(scene,sz,width,offset,lineReflectance,backReflectance);
    case {'whitenoise','noise'}
        % sceneCreate('noise',[128 128])
        sz = 128; contrast = 20;
        if length(varargin) >= 1, sz = varargin{1}; end
        if length(varargin) >= 2, contrast = varargin{2}; end
        
        scene = sceneNoise(scene,sz,contrast);
        scene = sceneSet(scene,'name','white noise');
        
    case {'pointarray','manypoints'}
        % sceneCreate('pointArray',sz,spacing,spectralType);
        sz = 128; spacing = 16; spectralType = 'ep';
        if length(varargin) >= 1, sz           = varargin{1}; end
        if length(varargin) >= 2, spacing      = varargin{2}; end
        if length(varargin) >= 3, spectralType = varargin{3}; end
        scene = scenePointArray(scene,sz,spacing,spectralType);
        
    case {'gridlines','distortiongrid'}
        % sceneCreate('gridlines',imageSize,spacing,spectralType);
        sz = 128; spacing = 16; spectralType = 'ep'; lineThickness = 1;
        if length(varargin) >= 1, sz            = varargin{1}; end
        if length(varargin) >= 2, spacing       = varargin{2}; end
        if length(varargin) >= 3, spectralType  = varargin{3}; end
        if length(varargin) >= 4, lineThickness = varargin{4}; end
        scene = sceneGridLines(scene,sz,spacing,spectralType,lineThickness);
        
    case {'checkerboard'}
        period = 16; spacing = 8; spectralType = 'ep';
        if length(varargin) >= 1, period       = varargin{1}; end
        if length(varargin) >= 2, spacing      = varargin{2}; end
        if length(varargin) >= 3, spectralType = varargin{3}; end
        scene = sceneCheckerboard(scene,period,spacing,spectralType);
        
    case {'frequencyorientation','demosaictarget','freqorientpattern','freqorient'}
        %   parms.angles = linspace(0,pi/2,5);
        %   parms.freqs =  [1,2,4,8,16];
        %   parms.blockSize = 64;
        %   parms.contrast = .8;
        % scene = sceneCreate('freqorient',parms);

        if isempty(varargin), params = FOTParams; 
        else,                 params = varargin{1};
        end
        % First argument is parms structure
        scene = sceneFOTarget(scene,params);
        
    case {'moireorient'}
        %% Moire pattern test
        %   parms.angles = linspace(0,pi/2,5);
        %   parms.freqs =  [1,2,4,8,16];
        %   parms.blockSize = 64;
        %   parms.contrast = .8;
        % scene = sceneCreate('moire orient',parms);
        if isempty(varargin), scene = sceneMOTarget(scene);
        else
            % First argument is parms structure
            scene = sceneMOTarget(scene,varargin{1});
        end
    case {'slantedbar','iso12233','slantededge'}
        % scene = sceneCreate('slantedEdge',sz, slope, fieldOfView, wave);
        % scene = sceneCreate('slantedEdge',128,1.33);  % size, slope
        % scene = sceneCreate('slantedEdge',128,1.33,[], (380:4:1064));       % size, slope, wave
        % scene = sceneCreate('slantedEdge',128,1.33,[], (380:4:1064), 0.3);  % size, slope, wave, darklevel
        
        barSlope = []; fov = []; wave = []; imSize = []; darklevel = 0;
        if length(varargin) >= 1, imSize = varargin{1}; end
        if length(varargin) >= 2, barSlope = varargin{2};  end
        if length(varargin) >= 3, fov = varargin{3}; end
        if length(varargin) >= 4, wave = varargin{4}; end
        if length(varargin) >= 5, darklevel = varargin{5}; end
        scene = sceneSlantedBar(scene,imSize,barSlope,fov,wave,darklevel);
        
    case {'zoneplate'}
        imSize = 384;
        if length(varargin)>=1, imSize = varargin{1}; end
        scene = sceneZonePlate(scene,imSize);
        
    case {'starpattern','radiallines'}
        % Thin radial lines - Useful for testing oriented blur
        %
        % scene = sceneCreate('starPattern');
        % scene = sceneCreate('starPattern',384);
        imSize = 256; spectralType = 'ep'; nLines = 8;
        if length(varargin) >=1, imSize = varargin{1}; end
        if length(varargin) >=2, spectralType = varargin{2}; end
        if length(varargin) >=3, nLines = varargin{3}; end
        scene = sceneRadialLines(scene,imSize,spectralType,nLines);
        
    case {'deadleaves'}
        % Dead leaves chart used by Mumford and many others for image
        % quality assessment
        %
        % scene = sceneCreate('dead leaves',512,3);
        imSize = 256;
        nFactor = 2;
        if length(varargin) >= 1, imSize = varargin{1}; end
        if length(varargin) >= 2, nFactor = varargin{2}; end
        scene = sceneDeadleaves(imSize,nFactor);
        
    case {'letter', 'font'}
        % Create scene of single letter
        %
        % scene = sceneCreate('letter', font, display);
        % 
        % font = fontCreate;
        % font = fontSet(font,'character','ABC');
        % scene = sceneCreate('letter',font); sceneWindow(scene);
        
        % Defaults, both have 96 dpi.  The default fontCreate is a 'g'
        % in Georgia font.
        font = fontCreate;
        display = 'LCD-Apple'; 
        
        % Assign arguments
        if ~isempty(varargin), font = varargin{1}; end
        if length(varargin) > 1, display = varargin{2}; end      
        if ischar(display), display = displayCreate(display); end
        
        scene = sceneFromFont(font, display);
        return; % Do not adjust luminance or other properties

    case {'hdrchart'}
        p = inputParser;
        varargin = ieParamFormat(varargin);
        p.addParameter('rowsperlevel',12);
        p.addParameter('nlevels',16);
        p.addParameter('drange',10^3.5);
        p.parse(varargin{:});
        r = p.Results;
        scene = sceneHDRChart(r.drange,r.nlevels,r.rowsperlevel);
    case {'hdr','highdynamicrange'}
        % scene = sceneCreate('hdr',varargin);
        p = inputParser;
        varargin = ieParamFormat(varargin);
        p.addParameter('size',256);
        p.parse(varargin{:});
        scene = sceneHDRLights();
    otherwise
        error('Unknown scene format: %s.',sceneName);
end

% Initialize scene geometry, spatial sampling
scene = sceneInitGeometry(scene);
scene = sceneInitSpatial(scene);

useSingle = getpref('ISET', 'useSingle', true);
if useSingle
    if isfield(scene,'spectrum') && isfield (scene.spectrum,'wave')
        scene.spectrum.wave = single(scene.spectrum.wave);
    end
    if isfield(scene,'illuminant') && isfield(scene.illuminant,'spectrum')
        scene.illuminant.spectrum.wave = single(scene.illuminant.spectrum.wave);
    end
end

% Scenes are initialized to a mean luminance of 100 cd/m2.  The illuminant
% is adjusted so that dividing the peak reflectance - calculated by
% dividing radiance (in photons) by the illuminant (in photons) is 0.9.
%
% Also, a best guess is made about one known reflectance.  This is a very little
% used feature, and might be deprecated.
if checkfields(scene,'data','photons') && ~isempty(scene.data.photons)
    
    if isempty(sceneGet(scene,'known reflectance')) && checkfields(scene,'data','photons')
        % We set up a known reflectance index here.  If there is one, then
        % value must have been set up elsewhere.  And I am surprised.  
        
        % If there is no illuminant yet, create one with the same
        % wavelength samples as the scene radiance. We make the illuminant
        % with a 100 cd/m2 mean luminance
        if isempty(sceneGet(scene,'illuminant'))
            il = illuminantCreate('equal photons',sceneGet(scene,'wave'),100);
            scene = sceneSet(scene,'illuminant',il);
        end
        
        % Find the location and across all wavelengths in the scene with
        % the peak radiance.
        v = sceneGet(scene,'peak radiance and wave');
        wave = sceneGet(scene,'wave');
        idxWave = find(wave == v(2));

        p = sceneGet(scene,'photons',v(2));
        [~,ij] = max2(p);
        v = [0.9 ij(1) ij(2) idxWave];
        % Store the known reflectance and its row,col,wave value.
        scene = sceneSet(scene,'known reflectance',v);
    end
    
    % Calculate and store the scene luminance
    luminance = sceneCalculateLuminance(scene);
    scene = sceneSet(scene,'luminance',luminance);
    
    % Adjust the mean illumination level to 100 cd/m2.
    scene = sceneAdjustLuminance(scene,100);
end

end

%---------------------------------------------------
function scene = sceneNoise(scene,sz,contrast)
%% Make a spatial white noise stimulus
% contrast is the standard deviation of the N(0,contrast) noise.
% The noise is shifted to a mean of 0.5, and the level is clipped to a
% minimum of 0.

if ieNotDefined('sz'), sz = [128,128]; end
if ieNotDefined('contrast'), contrast = 0.20;
elseif contrast > 1, contrast = contrast/100;
end

if numel(sz) == 1, sz(2) = sz(1); end

scene = initDefaultSpectrum(scene,'hyperspectral');
wave  = sceneGet(scene,'wave');
nWave = sceneGet(scene,'nwave');

% This is an image with reasonable dynamic range (10x).
d   = randn(sz)*contrast + 1; d = max(0,d);

% This is a D65 illuminant
il = illuminantCreate('d65',wave,100);
p  = illuminantGet(il,'photons');
scene = sceneSet(scene,'illuminant',il);

%
photons = zeros(sz(1),sz(2),nWave);
for ii=1:nWave, photons(:,:,ii) = d*p(ii); end

% Allocate space for the (compressed) photons
scene = sceneSet(scene,'photons',photons);

% By setting the fov here, we will not override the value in
% sceneInitSpatial() when this returns
scene = sceneSet(scene,'fov',1);

end

%----------------------------------
function scene = sceneDefault(scene,illuminantType,patchSize,wave,surfaceFile,blackBorder)
%% Default scene is a Macbeth chart with D65 illuminant, patchSize 16
%
% sceneDefault(scene,'d65',patchSize,wave,surfaceFile,blackBorder)
%

% These are the default surface reflectance values
if ieNotDefined('surfaceFile')
    surfaceFile = which('macbethChart.mat');
end
if ieNotDefined('blackBorder'), blackBorder = false; end

% Create the scene variable and possibly set wavelength
scene = initDefaultSpectrum(scene,'hyperspectral');
scene = sceneSet(scene,'wave',wave);

% Choose the illuminant type
switch lower(illuminantType)
    case 'd65'
        scene = sceneSet(scene,'name','Macbeth (D65)');
        lightSource = illuminantCreate('D65',wave,100);
    case 'd50'
        scene = sceneSet(scene,'name','Macbeth (D50)');
        lightSource = illuminantCreate('D50',wave,100);
    case 'fluorescent'
        scene = sceneSet(scene,'name','Macbeth (Fluorescent)');
        lightSource = illuminantCreate('Fluorescent',wave,100);
    case 'c'
        scene = sceneSet(scene,'name','Macbeth (Ill C)');
        lightSource = illuminantCreate('illuminantC',wave,100);
    case 'tungsten'
        scene = sceneSet(scene,'name','Macbeth (Tungsten)');
        lightSource = illuminantCreate('tungsten',wave,100);
    case 'ir'
        scene = sceneSet(scene,'name','Macbeth (IR)');
        lightSource = illuminantCreate('equalEnergy',wave,100);
    otherwise
        error('Unknown illuminant type.');
end

% Default distance in meters.
scene = sceneSet(scene,'distance',1.2);

% Scene magnification is always 1.
% Optical images have other magnifications that depend on the optics.
scene = sceneSet(scene,'magnification',1.0);

% The default patch size is 16x16.
spectrum = sceneGet(scene,'spectrum');
macbethChartObject = macbethChartCreate(patchSize,(1:24),spectrum,surfaceFile,blackBorder);

scene = sceneCreateMacbeth(macbethChartObject,lightSource,scene);

end

%--------------------------------------------------
function scene = sceneMultispectral(scene)
%% Default multispectral structure

scene = sceneSet(scene,'name','multispectral');
scene = initDefaultSpectrum(scene,'multispectral');

end
%--------------------------------------------------
function scene = sceneRGB(scene)
%% Prepare a scene for RGB data.

if ~exist('scene','var')||isempty(scene), scene.type = 'scene'; end

scene = sceneSet(scene,'name','rgb');
scene = sceneSet(scene,'type','scene');
scene = initDefaultSpectrum(scene,'hyperspectral');

% Set up an illuminant - but it is not nicely scaled.  And we don't have a
% known reflectance.
wave = sceneGet(scene,'wave');
il = illuminantCreate('d65',wave,100);
scene = sceneSet(scene,'illuminant',il);

end

%--------------------------------------------------
function scene = sceneMackay(scene,radFreq,sz)
%% Someone (I think Chris Tyler) told me the ring/ray pattern is also called
% the Mackay chart.
%
% Some people call it the Siemens Star pattern.
% https://en.wikipedia.org/wiki/Siemens_star
%
% We fill the central circle with a masking pattern.  The size of the
% central region is at the point when the rays would start to alias.  The
% the circumference of the central circle is 2*pi*r (with r in units of
% pixels).  When the radial frequency is f, we need a minimum of 2f pixels
% on the circumference.  So the circumference is 2*pi*r, so that we want
% the radius to be at least r = f/pi.  In practice that is too exact for
% the digital domain.  So we double the radius.
%

if ieNotDefined('radFreq'), radFreq = 8; end
if ieNotDefined('sz'),      sz = 256; end

scene = sceneSet(scene,'name','mackay');

if ~isfield(scene,'spectrum')
    scene = initDefaultSpectrum(scene,'hyperspectral');
end
nWave = sceneGet(scene,'nwave');

img = imgMackay(radFreq,sz);

% Insert central circle mask
r = round(2*radFreq/pi);  % Find the radius for the central circle

% Find the distance from the center of the image
[X,Y] = meshgrid(1:sz,1:sz); X = X - mean(X(:)); Y = Y - mean(Y(:));
d = sqrt(X.^2 + Y.^2);

% Everything with a distance less than 2r set to mean gray (128) for now.
l = (d < r);
img(l) = 128;  % figure; imagesc(img)

scene = sceneSet(scene,'photons',repmat(img,[1,1,nWave]));

% Set up an illuminant
wave = sceneGet(scene,'wave');
il = illuminantCreate('equal photons',wave,100);
scene = sceneSet(scene,'illuminant',il);

end

%--------------------------------------------------
function scene = sceneSweep(scene,sz,maxFreq)
%%  These are always equal photon

if ieNotDefined('sz'), sz = 128; end
if ieNotDefined('maxFreq'), maxFreq = sz/16; end

scene = sceneSet(scene,'name','sweep');
scene = initDefaultSpectrum(scene,'hyperspectral');
nWave = sceneGet(scene,'nwave');

img = imgSweep(sz,maxFreq);
img = img/max(img(:));

wave  = sceneGet(scene,'wave');
il    = illuminantCreate('equal photons',wave,100);
scene = sceneSet(scene,'illuminant',il);

img       = repmat(img,[1,1,nWave]);
[img,r,c] = RGB2XWFormat(img);
illP      = illuminantGet(il,'photons');
img       = img*diag(illP);
img       = XW2RGBFormat(img,r,c);
scene     = sceneSet(scene,'photons',img);

end
%--------------------------------------------------
function [scene,p] = sceneHarmonic(scene,parms, wave)
%% Create a scene of a (windowed) harmonic function.
%
% The default parameters are returned in a struct by calling
%
%  hp = harmonicP;
%
% Harmonic parameters are: 
%   parms.freq, parms.row, parms.col, parms.ang, parms.ph, parms.contrast
%
% The frequency units are with respect to the image (cyces/image).  To
% determine cycles/deg (cpd) use
% 
%   freq/sceneGet(scene,'fov');
%
% The spectral radiance is set to an equal photon radiance (not equal
% energy).

if ~exist('parms','var'), parms = harmonicP; end

scene = sceneSet(scene,'name','harmonic');

if ieNotDefined('wave')
    scene = initDefaultSpectrum(scene,'hyperspectral');
else
    scene = initDefaultSpectrum(scene, 'custom',wave);
end

nWave = sceneGet(scene,'nwave');

% TODO: Adjust pass the parameters back from the imgHarmonic window. In
% other cases, they are simply attached to the global parameters in
% vcSESSION.  We can get them by a getappdata call in here, but not if we
% close the window as part of imageSetHarmonic
%
% Switched to using the harmonicP method instead of this. (July 2022).
%
% if ieNotDefined('parms')
%     global parms; %#ok<REDEF>
%     h   = imageSetHarmonic; waitfor(h);
%     img = imageHarmonic(parms);
%     p   = parms;
%     clear parms;
% else
%     [img,p] = imageHarmonic(parms);
% end

[img,p] = imageHarmonic(parms);

% To reduce rounding error problems for large dynamic range, we set the
% lowest value to something slightly more than zero.  This is due to the
% ieCompressData scheme.
img(img==0) = 1e-4;             % Peak is 1.
img   = img/(2*max(img(:)));    % Forces mean reflectance to 25% gray

% Mean illuminant at 100 cd
wave  = sceneGet(scene,'wave');
il    = illuminantCreate('equal photons',wave,100);
scene = sceneSet(scene,'illuminant',il);

img       = repmat(img,[1,1,nWave]);
[img,r,c] = RGB2XWFormat(img);
illP = illuminantGet(il,'photons');
img  = img*diag(illP);
img  = XW2RGBFormat(img,r,c);
scene = sceneSet(scene,'photons',img);

end

%--------------------------------------------------
function scene = sceneRamp(scene,sz,dynamicRange)
%% Intensity ramp (see L-star chart for L* steps)

if ieNotDefined('sz'), sz = 128; end
if ieNotDefined('dynamicRange'), dynamicRange = 256; end

scene = sceneSet(scene,'name',sprintf('ramp DR %.1f',dynamicRange));
scene = initDefaultSpectrum(scene,'hyperspectral');
nWave = sceneGet(scene,'nwave');
wave = sceneGet(scene,'wave');

img = imgRamp(sz,dynamicRange);

% Scale to 0,1
img = img/(max(img(:)));

il = illuminantCreate('equal photons',wave,100);
scene = sceneSet(scene,'illuminant',il);

img = repmat(img,[1,1,nWave]);
[img,r,c] = RGB2XWFormat(img);
illP = illuminantGet(il,'photons');
img = img*diag(illP);
img = XW2RGBFormat(img,r,c);
scene = sceneSet(scene,'photons',img);

end
%--------------------------------------------------
function scene = sceneExpRamp(scene,sz,dynamicRange)
% Exponentially increasing intensities with horizontal position
% Contrast decreases from top to bottom of the image
%

if ieNotDefined('sz'), sz = 128; end
if ieNotDefined('dynamicRange'), dynamicRange = 256; end

scene = sceneSet(scene,'name',sprintf('ramp DR %.1f',dynamicRange));
scene = initDefaultSpectrum(scene,'hyperspectral');
nWave = sceneGet(scene,'nwave');
wave = sceneGet(scene,'wave');

img = logspace(0,log10(dynamicRange),sz);
img = repmat(img,sz,1);
img = ieScale(img,1,dynamicRange);

% Scale to 0,1
img = img/(max(img(:)));

il = illuminantCreate('equal photons',wave,100);
scene = sceneSet(scene,'illuminant',il);

img = repmat(img,[1,1,nWave]);
[img,r,c] = RGB2XWFormat(img);
illP = illuminantGet(il,'photons');
img = img*diag(illP);
img = XW2RGBFormat(img,r,c);
scene = sceneSet(scene,'photons',img);

end

%--------------------------------------------------
function scene = sceneUniform(scene,spectralType,sz,varargin)
%% Create a spatially uniform scene.
%
% Various spd types are supported, including d65, blackbody, equal energy,
% equal photon
%
% D65, equal energy, equal photons
% Blackbody - varargin{1} should be the color temperature
%

if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('spectralType'), spectralType = 'ep'; end
if ieNotDefined('sz'), sz = 32; end
scene = sceneSet(scene,'name',sprintf('uniform-%s',spectralType));

% Add the spectral wavelength sampling
if ~isfield(scene,'spectrum')
    scene = initDefaultSpectrum(scene,'hyperspectral');
end
wave  = sceneGet(scene,'wave');
nWave = sceneGet(scene,'nwave');

% 100% reflectance
d = ones(sz,sz,nWave);

spectralType = ieParamFormat(spectralType);
switch lower(spectralType)
    case {'d65','equalenergy','equalphotons','ee'}
        il = illuminantCreate(spectralType,wave);
    case {'blackbody'}
        if isempty(varargin), cTemp = 5000;
        else,                 cTemp = varargin{1};
        end
        il = illuminantCreate('blackbody',wave,cTemp);
    otherwise
        error('Unknown spectral type:%s\n',spectralType);
end

% Set illuminant
scene = sceneSet(scene,'illuminant',il);

% Create scene photons
illP = sceneGet(scene,'illuminant photons');
for ii=1:nWave, d(:,:,ii) = d(:,:,ii)*illP(ii); end

scene = sceneSet(scene,'photons',d);

end
%--------------------------------------------------
function scene = sceneLine(scene,spectralType,sz,offset)
%% Create a single line scene.
% This is used for computing linespreads and OTFs.

if ieNotDefined('spectralType'), spectralType = 'ep'; end
if ieNotDefined('sz'),     sz = 64; end
if ieNotDefined('offset'), offset = 0; end

scene = sceneSet(scene,'name',sprintf('line-%s',spectralType));

if ~isfield(scene,'spectrum')
    scene = initDefaultSpectrum(scene,'hyperspectral');
end
wave    = sceneGet(scene,'wave');
nWave   = sceneGet(scene,'nwave');

% Black is more than zero to prevent HDR problem with ieCompressData
linePos = round(sz/2) + offset;
photons = ones(sz,sz,nWave)*1e-4;
photons(:,linePos,:) = 1;

spectralType = ieParamFormat(spectralType);
% Figure out a way to do this using sceneSet.
switch lower(spectralType)
    case {'ep','equalphotons','ephoton','equalphoton'}
        % Equal number of photons at every wavelength
        il = illuminantCreate('equal photons',wave);
    case {'ee','equalenergy','eenergy'}
        % Equal energy at every wavelength.  The large scale factor applied
        % to the number of photons is just to produce a reasonable energy
        % level.
        il = illuminantCreate('equal energy',wave);
        
    case 'd65'
        % D65 spectra for the line
        il = illuminantCreate('d65',wave);
        
    otherwise
        error('Unknown uniform field type %s.',spectralType);
end

scene = sceneSet(scene,'illuminant',il);
p     = sceneGet(scene,'illuminant photons');
for ii=1:nWave, photons(:,:,ii) = photons(:,:,ii)*p(ii); end

scene = sceneSet(scene,'photons',photons);

end
%--------------------------------------------------
function scene = sceneBar(scene,sz,width)
%% Create a single bar scene.
% This is used for computing the effect of scene dot density, say for a
% display with varying dots per inch.

if ieNotDefined('sz'),     sz = 64; end
if ieNotDefined('width'), width = 5; end

scene = sceneSet(scene,'name',sprintf('bar-%d',width));

if ~isfield(scene,'spectrum')
    scene = initDefaultSpectrum(scene,'hyperspectral');
end
wave    = sceneGet(scene,'wave');
nWave   = sceneGet(scene,'nwave');

% Black is more than zero to prevent HDR problem with ieCompressData
barPos = (1:width) + round((sz - width)/2);
photons = ones(sz,sz,nWave)*1e-8;   % Very dark reflectance mostly
photons(:,barPos,:) = 1;            % White reflectance in bar region

il = illuminantCreate('equal photons',wave);
scene = sceneSet(scene,'illuminant',il);
p     = sceneGet(scene,'illuminant photons');

% Create the radiance that matches reflectance and illuminant
for ii=1:nWave, photons(:,:,ii) = photons(:,:,ii)*p(ii); end

% Attach the photons to the scene
scene = sceneSet(scene,'photons',photons);

end

%------------------------
function scene = sceneVernier(scene,sz,width,offset,lineReflectance,backReflectance)
%% Equal photon vernier targets
%
% Need to allow changing color of top and bottom, perhaps other features.
% We will create params structure for parameters in the future, i.e.
% params.sz, params.width, params.lineReflectance, ... and so forth
%
if ieNotDefined('sz'),     sz = 64;    end
if ieNotDefined('width'),  width = 0;  end
if ieNotDefined('offset'), offset = 1; end
if ieNotDefined('lineReflectance'), lineReflectance = 0.6; end
if ieNotDefined('backReflectance'), backReflectance = 0.3; end

scene = sceneSet(scene,'name',sprintf('vernier-%d',offset));

%% We make the image square
r = sz; c = sz;

% Make the column number odd so we can really center the top line
if ~isodd(c), c = c+1; end

% Vernier line size and offset
% Top and bottom half rows and columns
% Columns containing top line, shifted offset/2
topCols = (1:width) + round((c - width)/2) - floor(offset/2);

% Columns containing bottom line, shifted offset from top columns
% With this algorithm, the width of the
botCols = topCols + offset;

% Split the rows, too
topHalf = round(r/2);
topRows = 1:topHalf; botRows = (topHalf+1):r;

%% Init spectrum

if ~isfield(scene,'spectrum')
    scene = initDefaultSpectrum(scene,'hyperspectral');
end
wave    = sceneGet(scene,'wave');
nWave   = sceneGet(scene,'nwave');

%% Make the photon data
il    = illuminantCreate('equal photons',wave);
scene = sceneSet(scene,'illuminant',il);
illP  = sceneGet(scene,'illuminant photons');

photons = ones(r,c,nWave);
for ii=1:nWave
    photons(:,:,ii)     = backReflectance*photons(:,:,ii)*illP(ii);
    photons(topRows,topCols,ii)  = (lineReflectance/backReflectance)*photons(topRows,topCols,ii);
    photons(botRows,botCols,ii)  = (lineReflectance/backReflectance)*photons(botRows,botCols,ii);
end

scene = sceneSet(scene,'photons',photons);

end
%------------------------
function scene = sceneRadialLines(scene,imSize,spectralType,nLines)
%% sceneCreate('star pattern')
%  Create a Siemens Star (radial line) scene.
%
%   scene = sceneRadialLines(scene,imSize,spectralType,nLines)
%
% In this test chart the intensities along lines from the center are
% constant. Measuring on a circle around the center the intensity is a
% harmonic. Hence, frequency varies as a function of radial distance.
%
% Reference:
%   Dieter Wueller thinks this pattern is cool.
%   Digital camera resolution measurement using sinusoidal Siemens stars
%   Proc. SPIE, Vol. 6502, 65020N (2007); doi:10.1117/12.703817
%
% Examples:
%  scene = sceneCreate('radialLines');
%

if ieNotDefined('scene'), error('Scene must be defined'); end
if ieNotDefined('spectralType'), spectralType = 'ep'; end
if ieNotDefined('imSize'), imSize = 256; end
if ieNotDefined('nLines'), nLines = 8; end

scene = sceneSet(scene,'name',sprintf('radialLine-%s',spectralType));
scene = initDefaultSpectrum(scene,'hyperspectral');

% Determine the line angles
radians = pi*(0:(nLines-1))/nLines;
endPoints = zeros(nLines,2);
for ii=1:nLines
    endPoints(ii,:) = round([cos(radians(ii)),sin(radians(ii))]*imSize/2);
end
% plot(endPoints(:,1),endPoints(:,2),'o')

img = zeros(imSize,imSize);

% The routine for drawing lines could be better.
for ii=1:nLines
    x = endPoints(ii,1); y = endPoints(ii,2);
    u = -x; v = -y;
    % Flip so x is the lower one
    if x > 0
        tmp = [x,y]; x = u; y = v; u = tmp(1); v = tmp(2);
    end
    
    if ~isequal(u,x), slope = (y - v) / (u - x);
        for jj=x:0.2:u
            kk = round(jj*slope);
            img(round(kk + (imSize/2)) + 1, round(jj + (imSize/2)) + 1) = 1;
        end
    else, img(:, (imSize/2) + 1) = 1;
    end
end

img = img(1:imSize,1:imSize);
% To reduce rounding error problems for large dynamic range, we set the
% lowest value to something slightly more than zero.  This is due to the
% ieCompressData scheme.
img(img==0) = 1e-4;
img = img/max(img(:));
% figure; imagesc(img)

% Create the photon image
wave    = sceneGet(scene,'wave');
nWave   = sceneGet(scene,'nwave');
photons = zeros(imSize,imSize,nWave);

% Figure out a way to do this using sceneSet.
spectralType = ieParamFormat(spectralType);
switch spectralType
    case {'ep','equalphoton','ephoton'}
        % Equal number of photons at every wavelength
        il = illuminantCreate('equal photons',wave);
    case {'ee','equalenergy','eenergy'}
        il = illuminantCreate('equal energy',wave);
    case 'd65'
        % D65 spectra for the line
        il = illuminantCreate('d65',wave);
    otherwise
        error('Unknown uniform field type %s.\n',spectralType);
end

scene = sceneSet(scene,'illuminant',il);
p     = sceneGet(scene,'illuminant photons');
for ii=1:nWave, photons(:,:,ii) = img(:,:)*p(ii); end

scene = sceneSet(scene,'photons',photons);

end

%-----------------------
function scene = sceneFOTarget(scene,parms)
%% Frequency/Orientation target

% Default params if not sent in
if ieNotDefined('parms'), parms = FOTParams; end

scene = sceneSet(scene,'name','FOTarget');
scene = initDefaultSpectrum(scene,'hyperspectral');
nWave = sceneGet(scene,'nwave');

img = FOTarget('sine',parms);

% Prevent dynamic range problem with ieCompressData
img = ieClip(img,1e-4,1);
img = img/max(img(:));

% Create the illuminant
il = illuminantCreate('equal photons',sceneGet(scene,'wave'));
scene = sceneSet(scene,'illuminant',il);

% This routine returns an RGB image.  We base the final image on just the
% green channel
img = repmat(img(:,:,2),[1,1,nWave]);
[img,r,c] = RGB2XWFormat(img);
illP = illuminantGet(il,'photons');
img = img*diag(illP);
img = XW2RGBFormat(img,r,c);
scene = sceneSet(scene,'photons',img);

end

%-----------------------
function scene = sceneMOTarget(scene,parms)
%% Moire/Orientation target

if ieNotDefined('parms'), parms = []; end

scene = sceneSet(scene,'name','MOTarget');
scene = initDefaultSpectrum(scene,'hyperspectral');
nWave = sceneGet(scene,'nwave');

% Select one among sinusoidalim, squareim, sinusoidalim_line, squareim_line, flat
% img = MOTarget('squareim',parms);
img = MOTarget('sinusoidalim',parms);


% Prevent dynamic range problem with ieCompressData
img = ieClip(img,1e-4,1);

% This routine returns an RGB image.  We take the green channel and expand
% it
scene = sceneSet(scene,'photons',repmat(img(:,:,2),[1,1,nWave]));

%
wave = sceneGet(scene,'wave');
illPhotons = ones(size(wave))*max(scene.data.photons(:));
scene = sceneSet(scene,'illuminantPhotons',illPhotons);

end

%-------------------
function scene = sceneCheckerboard(scene,checkPeriod,nCheckPairs,spectralType)
%% Checkerboard

if ieNotDefined('scene'), error('Scene required'); end
if ieNotDefined('checkPeriod'), checkPeriod = 16; end
if ieNotDefined('nCheckPairs'), nCheckPairs = 8; end
if ieNotDefined('spectralType'), spectralType = 'ep'; end

scene = sceneSet(scene,'name',sprintf('Checker-%s',spectralType));
scene = initDefaultSpectrum(scene,'hyperspectral');
wave  = sceneGet(scene,'wave');
nWave = sceneGet(scene,'nwave');

% The dynamic range of the checkerboard is kept to < 10^4 to prevent
% problems with the rounding error
d = checkerboard(checkPeriod,nCheckPairs); d = double((d > 0.5));
d = d/max(d(:));

% Prevent ieCompressData problem.
d = ieClip(d,1e-6,1);
spectralType = ieParamFormat(spectralType);
switch spectralType
    case {'d65'}
        il = illuminantCreate('d65',wave);
    case {'ee','equalenergy'}
        il = illuminantCreate('equalenergy',wave);
    case {'ep','equalphoton','equalphotons'}
        il = illuminantCreate('equal photons',wave);
    otherwise
        error('Unknown spectral type:%s\n',spectralType);
end

img = zeros(size(d,1),size(d,2),nWave);
illP = illuminantGet(il,'photons');
for ii=1:nWave, img(:,:,ii) = d*illP(ii); end
scene = sceneSet(scene,'photons',img);

end
%---------------------------------------------------------------
function scene = sceneSlantedBar(scene,imSize,barSlope,fieldOfView,wave,darklevel)
%%
%  Slanted bar, 2 deg field of view
%  Slope 2.6 (upper left to lower right)
%  Default size:  384
%
% The scene is set to equal photons across wavelength.

if ieNotDefined('imSize'),      imSize = 384; end
if ieNotDefined('barSlope'),    barSlope = 2.6; end
if ieNotDefined('fieldOfView'), fieldOfView = 2; end
if ieNotDefined('wave'),        wave = 400:10:700; end
if ieNotDefined('darklevel'),   darklevel = 0; end
scene = sceneSet(scene,'name','slantedBar');

scene = sceneSet(scene,'wave',wave);

wave = sceneGet(scene,'wave');
nWave  = sceneGet(scene,'nwave');

img = imageSlantedEdge(imSize, barSlope, darklevel);
%{
% Make the image
imSize = round(imSize/2);
[X,Y] = meshgrid(-imSize:imSize,-imSize:imSize);
img = zeros(size(X));
%  y = barSlope*x defines the line.  We find all the Y values that are
%  above the line
list = (Y > barSlope*X );

% We assume target is perfectly reflective (white), so the illuminant is
% the equal energy illuminant; that is, the SPD is all due to the
% illuminant
img( list ) = 1;
%}

% Prevent dynamic range problem with ieCompressData
img = ieClip(img,1e-6,1);

% Now, create the illuminant
il = illuminantCreate('equal energy',wave);
scene = sceneSet(scene,'illuminant',il);
illP = illuminantGet(il,'photons');

% Create the scene photons
photons = zeros(size(img,1),size(img,2),nWave);
for ii=1:nWave, photons(:,:,ii) = img*illP(ii); end
scene = sceneSet(scene,'photons',photons);

% Set the field of view
scene = sceneSet(scene,'horizontalfieldofview',fieldOfView);

end

%-----------------------
function scene = sceneZonePlate(scene,imSize,fieldOfView)
%% Circular zone plate image
%

if ieNotDefined('imSize'), imSize = 256; end
if ieNotDefined('fieldOfView'), fieldOfView = 4; end

scene = sceneSet(scene,'name','zonePlate');
scene = initDefaultSpectrum(scene,'hyperspectral');
nWave = sceneGet(scene,'nwave');

img = imgZonePlate(imSize);
% Prevent dynamic range problem with ieCompressData
img = ieClip(img,1e-4,1);

scene = sceneSet(scene,'photons',repmat(img,[1,1,nWave]));
scene = sceneSet(scene,'horizontalfieldofview',fieldOfView);

end

%-----------------------
function scene = sceneLstarSteps(scene,bSize,nBars,deltaE)
%% Scene with vertical bars in equal L* steps
%
% For a bar width of 50 pixels, 5 bars, at L* levels (1:nBars)-1 * 10, use
%   scene = sceneCreate('lstar',[100 50],5,10);
%   ieAddObject(scene); sceneWindow;

scene = initDefaultSpectrum(scene,'hyperspectral');

% Create the Y values that will define the intensities of the spd.  First,
% equal spaced L* values, centered around L* of 50
L = (0:(nBars-1))*deltaE + 50 - (nBars-1)*deltaE/2;
LAB = zeros(nBars,3);
LAB(:,1) = L(:);

% Transform them to Y values
C = makecform('lab2xyz');
XYZ = applycform(LAB,C);
Y = XYZ(:,2); Y = Y/max(Y(:));
% vcNewGraphWin; plot(Y)

% Create equal photons illuminant
nWave = sceneGet(scene,'nwave');
il = illuminantCreate('equal photons',sceneGet(scene,'wave'));
scene = sceneSet(scene,'illuminant',il);
illPhotons = illuminantGet(il,'photons');

% Now, make the photon image
photons = ones(1,nBars,nWave);
for ii=1:nBars
    photons(1,ii,:) = Y(ii)*illPhotons;
end

% Adjust the size of the image
if length(bSize) == 1,     barWidth = bSize; barHeight = 128;
elseif length(bSize) == 2, barHeight = bSize(1); barWidth = bSize(2);
else,                      error('Bad bSize %f\n',bSize);
end
photons = imageIncreaseImageRGBSize(photons,[barHeight,barWidth]);

% On return, the luminance level is scaled to a mean of 100 cd/m2.
scene = sceneSet(scene,'photons',photons);

end
