function val = sceneGet(scene,parm,varargin)
% Get scene parameters and derived properties
%
%     val = sceneGet(scene,parm,varargin)
%
%  Unique scene parameters are stored and many others are derived from the
%  stored values.
%
%  The key structures (scene, oi, sensor, ip, display) are stored in the
%  ISET database.  To retrieve the currently selected optical image, use
%      
%     scene = ieGetObject('scene');
%
%  A '*' indicates that the syntax sceneGet(scene,param,unit) can be used,
%  where unit specifies the spatial scale of the returned value:  'm',
%  'cm', 'mm', 'um', 'nm'.  Default length scale is always meters ('m').
%
% Examples
%    scene = ieGetObject('scene');
%    sceneGet(scene,'name')
%    sceneGet(scene,'size');
%    sceneGet(scene,'width','um')
%    sceneGet(scene,'rgb image');
%    sceneGet(scene,'nyquist','cpd');
%
% General parameters
%      'name'     - name
%      'type'     - always 'scene'
%      'filename' - if derived from file, stored here
%      'rows'     - number of row samples
%      'cols'     - number of column samples
%      'size'*    - scene size (rows,cols)
%      'height'*  - height (meters),
%      'width'*   - width (meters)
%      'heightandwidth'*    - (height,width)
%      'diagonalsize'*      - diagonal
%      'area'*              - area (meters^2)
%
% Optical and resolution properties
%      'object distance' - distance from lens to object
%      'fov horizontal'  - horizontal field of view (deg)
%      'fov vertical'    - vertical field of view (deg)
%      'diagonal field of view' - diagonal field of view
%      'aspectratio'     - row/col
%      'magnification','mag' -  Always 1.
%      'depthmap'        - Distance to points in meters
%      'depth range'     - Smallest distance > 0 and largest distance
%
% Radiance and reflectance information
%      'data'
%        'photons'          - radiance data (photons)
%        'photons noise'    - radiance data plus photon noise (photons)
%        'known reflectance'- 4-vector, reflectance, row, col, wave
%        'peak radiance'     - peak radiance at specified (or all) wavelengths
%        'peak radiance and wave' - peak radiance and its wavelength
%        'datamax'     - max photons radiance value (across all waves)
%        'datamin'     - min photons radiance value (across all waves)
%        'compressbitdepth' - 32 (single precision), 64 allowed.
%        'energy'           - radiance data (energy)
%        'mean energy spd'  - mean spd in energy units
%        'mean photons spd' - mean spd in photon units
%
%    The roi can be specified as either Nx2 locations or as a 4-vector of
%    [row,col,height,width].  Returned values are the mean over the roi.
%
%        'roi photons'      - spd of the points in a region of interest
%                               The region can be a rect or xy locs
%        'roi energy'      - as above, but energy 
%        'roi reflectance' - as above, but reflectance 
%        'roi mean energy'        - energy spd averaged within a region of interest
%        'roi mean photons'       - photons spd averaged within in a region of interest
%        'roi mean reflectance'   - reflectance spd averaged within in a region of interest
%
% * You can add a region of interest (roi) to the get
%
%  Luminance and other colorimetric properties
%        'mean luminance' - mean luminance
%        'luminance'      - spatial array of luminance
%        'roi luminance'  - spatial roi of the luminance'
%        'xyz'            - 3D array of XYZ values(CIE 1931, 10 deg)
%        'lms'            - 3D array of cone values (Stockman)
%        
% Resolution parameters
%      'sample size'*          - size of each square pixel
%      'hspatial resolution'*  - height spatial resolution (distance between pixels)
%      'wspatial resolution'*  - width spatial resolution
%      'spatial resolution'*   - (height,width) spatial resolution
%      'sample spacing'*       - (width,height) spatial resolution (do not use)
%      'distance per degree'*  - sample spacing per deg of visual angle
%      'degrees per distance'  - degrees per unit distance, e.g.,  sceneGet(scene,'degPerDist','micron')
%      'degrees per sample'
%      'spatial support'       - spatial locations of points e.g., sceneGet(oi,'spatialsupport','microns')
%      'h angular resolution'  - height degrees per pixel
%      'w angular resolution'  - width degrees per pixel
%      'angular resolution'    - (height, width) degrees per pixel
%      'frequency resolution'* -
%         % Default is cycles per degree
%         % val = sceneGet(scene,'frequencyResolution',units);
%      'maxfrequencyresolution'*
%         % Default is cycles/deg.  By using, say,
%         % sceneGet(oi,'maxfreqres','mm')
%         % you can get units in cycles/{meters,mm,microns}
%      'frequencysupport'*
%         % val = sceneGet(scene,'frequencyResolution',units);
%      'fsupportx'*
%         % val = sceneGet(scene,'frequencyResolution',units);
%      'fsupporty'*
%         % val = sceneGet(scene,'frequencyResolution',units);
%
%  Wavelength parameters
%      'spectrum'
%        'binwidth'   - bin width of wavelength integration
%        'wavelength' - column vector of wavelength sample
%        'nwave'      - number of wavelength samples
%
% Auxiliary information
%      'illuminant'           - HDRS multispectral data illuminant stored here (watts/sr/m^2/nm)
%        'illuminant name'    - Illuminant name
%        'illuminant energy'  - energy data
%        'illuminant photons' - energy data
%        'illuminant xyz'     - CIE XYZ (1931, 10 deg)
%        'illuminant wave'    - wavelength samples - deprecated to wave
%        'illuminant comment' - comment
%        'illuminant format'  - 'spatial spectral' or 'spectral'
%        'roi illuminant photons'        - illuminant photon spd in a region of interest 
%        'roi mean illuminant photons'   - illuminant photon spd averaged within in a region of interest 
%
% Display
%      'rgb image'  - RGB image of the scene display
%
% Reflectance chart - for a sceneCreate('reflectance chart')
%       'chart parameters' - Structure of parameters
%       'roi'    - Sometimes we store a rect as a region of interest
%
% Copyright ImagEval Consultants, LLC, 2003.

if ~exist('parm','var') || isempty(parm), error('Parameter must be defined.'); end

% Default is empty when the parameter is not yet defined.
val = [];

parm = ieParamFormat(parm);

switch parm
    
    % Book keeping
    case 'type'
        val = scene.type;
    case 'name'
        val = scene.name;
    case 'filename'
        val = scene.filename;
    case 'consistency'
        val = scene.consistency;
        
        % Geometry
    case {'rows','row','nrows','nrow'}
        if checkfields(scene,'data','photons'), val = size(scene.data.photons,1); end
    case {'cols','col','ncols','ncol'}
        if checkfields(scene,'data','photons'), val = size(scene.data.photons,2); end
    case 'size'
        val = [sceneGet(scene,'rows'),sceneGet(scene,'cols')];
        
    case {'samplespacing'}
        % sceneGet(scene,'sampleSpacing','mm')
        sz = sceneGet(scene,'size');
        val = [sceneGet(scene,'width')/sz(2) , sceneGet(scene,'height')/sz(1)];
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'samplesize'}
        w = sceneGet(scene,'width');      % Image width in meters
        c = sceneGet(scene,'cols');       % Number of sample columns
        val = w/c;                        % M/sample
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'distance','objectdistance','imagedistance'}
        % Positive for scenes (object), negative for optical images
        % (images).
        val = scene.distance;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'fovhorizontal','fov','wangular','widthangular','hfov','horizontalfieldofview','horizontalfov'}
        if checkfields(scene,'wAngular'), val = scene.wAngular; end
        
    case {'fovvertical','hangular','heightangular','vfov','verticalfieldofview'}
        % We only store the width FOV.  We insist that the pixels are
        % square
        h = sceneGet(scene,'height');      % Height in meters
        d = sceneGet(scene,'distance');    % Distance in meters
        val = ieRad2deg(2*atan((0.5*h)/d));  % Vertical field of view
        
    case {'dangular','diagonalangular','diagonalfieldofview'}
        % For large field of views, we do the tangent computation.  When
        % the FOV is less than 10 deg, this is essentially the same as
        %
        %  val = sqrt(sceneGet(scene,'wAngular')^2 + sceneGet(scene,'hAngular')^2)
        %
        % The tangent calculation is:
        %  tan(r) = opp/adj, where adj is viewing distance (vd)
        %  opp1 = vd*tan(r1), opp2 = vd*tan(r2)
        %  d = sqrt((opp1^2) + (opp1^2))
        %  diagonalFOV = ieRad2deg(atan2(d,vd))
        vd = sceneGet(scene,'distance');
        rW = ieDeg2rad(sceneGet(scene,'wAngular'));
        rH = ieDeg2rad(sceneGet(scene,'hAngular'));
        d = sqrt( (vd*tan(rW))^2 + (vd*tan(rH))^2 );
        val = ieRad2deg(atan2(d,vd));
        
    case 'aspectratio'
        r = sceneGet(scene,'rows'); c = sceneGet(scene,'cols');
        if isempty(c) || c == 0 && strcmp(sceneGet(scene,'type'),'opticalimage')
            % Use the current scene information
            val = sceneGet(vcGetObject('SCENE'),'aspectRatio');
            return;
        else val = r/c;
        end
    case {'magnification','mag'}
        % Scenes always have a magnification of 1. Optical image mag
        % is calculated from the optics.
        val = 1;
        
        % Depth
    case {'depthmap'}
        % sceneGet(scene,'depth map',units);
        % dm = sceneGet(scene,'depth map','mm');
        if isfield(scene,'depthMap'), val = scene.depthMap;
        else
            sz = sceneGet(scene,'size');
            val = ones(sz(1),sz(2))*sceneGet(scene,'distance','m');
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'depthrange'}
        % Min and max of depth.  Units can be specified
        % sceneGet(scene,'depth range',units)
        dm = sceneGet(scene,'depth map');
        if isempty(dm), val = []; return;
        else
            dm = dm(dm > 0);   % Remove the zeros
            val = [min(dm(:)), max(dm(:))];
            if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        end
    case 'data'
        % sceneGet(scene,'data');
        % The whole data structure is returned.
        if checkfields(scene,'data'), val = scene.data; end;
        
    case {'photons'}
        % sceneGet(scene,'photons',[wavelength]); Returns radiance (photon)
        % data.  It is possible to ask for just a single waveband. Data are
        % returned as doubles, but they are stored as single.
        if checkfields(scene,'data','photons')
            if isempty(varargin)
                % allPhotons = sceneGet(scene,'photons')
                val = double(scene.data.photons);
            else
                % waveBandPhotons = sceneGet(scene,'photons',500)
                idx = ieFindWaveIndex(sceneGet(scene,'wave'),varargin{1});
                if max(idx(:)) == 0
                    warning('No data at wavelength %d\n',varargin{1});
                else
                    val = double(scene.data.photons(:,:,idx));
                end
            end
        end
        
    case {'photonsnoise'}
        % sceneGet(scene,'photons noise',roiLocs);
        if isempty(varargin), roiLocs = [];
        else, roiLocs = varargin{1};
        end
        
        val = scenePhotonNoise(scene,roiLocs);
        
    case {'roiphotons','roiphotonsspd'}
        % sceneGet(scene,'photons roi',rectOrlocs);
        % Read photon spd from a region of interest. Data are returned as
        % doubles.
        % The roi can be xy locs or it can be a rect,
        %  [col, row, height, width]
        % The number of returned points is (height+1) * (width+1)
        % So, [col,row,0,0] returns 1 point and [col,row,1,1] returns 4
        % points.
        if isempty(varargin), error('ROI required')
        else roiLocs = varargin{1};
        end
        val = vcGetROIData(scene,roiLocs,'photons');
                
    case {'reflectance'}
        % Divide the scene photons by the illuminant photons to derive
        % scene reflectance.
        % r = sceneGet(scene,'reflectance');
        %
        % We should also implement:
        %   r = sceneGet(scene,'mean reflectance',roiRect);
        %
        % radiance = vcGetROIData(scene,ieRoi2Locs(rect),'photons');
        % illuminantSPD = sceneGet(scene,'illuminant photons');
        % reflectance = radiance*diag(1./illuminantSPD);
        % reflectance = mean(reflectance);
        
        % % No space allocated
        illPhotons = scene.illuminant.data.photons; 
        nWave      = sceneGet(scene,'nWave');
        photons    = scene.data.photons;   
        
        % Direct access to scene data saves memory allocation.
        switch sceneGet(scene,'illuminant format')
            case 'spatial spectral'
                % Spatial-spectral illumination
                val = photons ./ illPhotons;
            case 'spectral'
                val = zeros(size(photons));
                % Single vector for the illumination
                for ii = 1:nWave
                    val(:,:,ii) = photons(:,:,ii)/illPhotons(ii);
                end
            otherwise
                val = [];
                disp('No illuminant data');
        end
    case {'roireflectance'}
        % sceneGet(scene,'roi reflectance',roi);
        %
        % roi can be roiLocs or a roi rect
        %
        % Return the reflectance in a region of interest
        % XW format
        if isempty(varargin), error('ROI required');
        else roiLocs = varargin{1};
        end
        
        sPhotons = vcGetROIData(scene,roiLocs,'photons');
        
        % This is a trick way (ugh) to get the illuminant photons in a ROI
        illuminantSPD = sceneGet(scene,'illuminant photons');
        if isempty(illuminantSPD), error('No illuminant data'); end
        
        illF = sceneGet(scene,'illuminant format');
        switch illF
            case 'spatial spectral'
                % Use scene ROI tools to extract the relevant portion of
                % the illuminantSPD
                scene = sceneSet(scene,'photons',illuminantSPD);
                illuminantSPD = vcGetROIData(scene,roiLocs,'photons');
                val = sPhotons ./ illuminantSPD;
            case 'spectral'
                val = sPhotons*diag(1./illuminantSPD);
            otherwise
                error('Unknown illuminant format %s\n',illF);
        end
        
    case {'roimeanreflectance'}
        % sceneGet(scene,'roi mean reflectance', roi)
        %
        % Return the mean reflectance spd in a region of interest
        if isempty(varargin), error('ROI required')
        else roiLocs = varargin{1};
        end
        val = sceneGet(scene,'roi reflectance', roiLocs);
        val = mean(val,1);
        
    case {'peakradiance'}
        % p = sceneGet(scene,'peakRadiance',500);
        % p = sceneGet(scene,'peakRadiance');
        % Return the peak radiance at a list of wavelengths.  If no
        % wavelengths are passed, then the peak at all wavelength is
        % returned in a vector.
        if isempty(varargin), wave = sceneGet(scene,'wave');
        else wave = varargin{1};
        end
        nWave = length(wave);
        val = zeros(nWave,1);
        for ii=1:nWave
            tmp = sceneGet(scene,'photons',wave(ii));
            val(ii) = max(tmp(:));
        end
    case {'peakradianceandwave'}
        % Probably deprecated
        % Return the peak radiance and its wavelength
        % v = sceneGet(scene,'peakRadianceAndWave');
        % v(1), v(2)
        p = sceneGet(scene,'peak radiance');
        wave = sceneGet(scene,'wave');
        [p,ii] = max(p);
        val = [p,wave(ii)];
    case {'datamax','dmax','peakphoton'}
        if checkfields(scene,'data','dmax'), val = scene.data.dmax; end
    case {'datamin','dmin','minphoton'}
        if checkfields(scene,'data','dmin'), val = scene.data.dmin; end
    case {'knownreflectance'}
        % We store the peak reflectance to set the illuminant level
        % properly and to plot reflectances.
        if checkfields(scene,'data','knownReflectance')
            val = scene.data.knownReflectance;
        end
    case {'bitdepth','compressbitdepth'}
        % Default bit depth is 32 (single precision)
        % Considering eliminating the 64 option (double precision)
        if checkfields(scene,'data','bitDepth')
             val = scene.data.bitDepth; 
        else val = 32;
        end
        
    case 'energy'
        % sceneGet(scene,'energy',[wavelength]);
        % Get the energy, possibly just one waveband
        if isempty(varargin),
            % Save memory using direct access.
            % val = sceneGet(scene,'photons');
            wave = sceneGet(scene,'wave');
            [XW,r,c,w] = RGB2XWFormat(scene.data.photons); %#ok<NASGU>
            val = Quanta2Energy(wave,XW);
            val = XW2RGBFormat(val,r,c);
        else
            thisWave = varargin{1};  % Only one wavelength, not a list yet
            val = sceneGet(scene,'photons',thisWave);
            [XW,r,c,w] = RGB2XWFormat(val); %#ok<NASGU>
            val = Quanta2Energy(thisWave,XW);
            val = XW2RGBFormat(val,r,c);
        end
    case {'roienergy'}
        % sceneGet(scene,'energy roi',rectOrlocs);
        % Read photon spd from a region of interest. Data are returned as
        % doubles (uncompressed).
        % The roi can be xy locs or it can be a rect,
        %  [col, row, height, width]
        % The number of returned points is (height+1) * (width+1)
        % So, [col,row,0,0] returns 1 point and [col,row,1,1] returns 4
        % points.
        if isempty(varargin), error('ROI required')
        else roiLocs = varargin{1};
        end
        val = vcGetROIData(scene,roiLocs,'energy');
        
    case {'roimeanenergy'}
        % sceneGet(scene,'roi mean energy', roi)
        % Return the mean energy spd in a region of interest
        if isempty(varargin), error('ROI required')
        else roiLocs = varargin{1};
        end
        val = sceneGet(scene,'roi energy', roiLocs);
        val = mean(val,1);
        
    case {'meanenergyspd'}
        % sceneGet(scene,'mean energy spd')
        % mean spd in energy units
        val = sceneGet(scene,'energy');
        val = mean(RGB2XWFormat(val));
    
    case {'roimeanphotons'}
        % sceneGet(scene,'roi mean photons', roi)
        % Return the mean photon spd in a region of interest
        if isempty(varargin), error('ROI required')
        else roiLocs = varargin{1};
        end
        val = sceneGet(scene,'roi photons', roiLocs);
        val = mean(val,1);
        
    case {'meanphotonsspd'}
        % sceneGet(scene,'mean photons spd')
        % mean spd in photon units
        val = sceneGet(scene,'photons');
        val = mean(RGB2XWFormat(val));
        
    case {'meanluminance','meanlum','meanl'}
        % sceneGet(scene,'meanLuminance');
        lum = sceneGet(scene,'luminance');
        val = double(mean(lum(:)));
        
    case {'luminanceimage','luminance'}
        % sceneGet(scene,'luminance image');
        if ~checkfields(scene,'data','luminance') || isempty(scene.data.luminance)
            val = sceneCalculateLuminance(scene);
        else
            val = scene.data.luminance;
        end
        val = double(val);
        
    case {'roiluminance'}
        error('Not yet implemented')
        
    case {'xyz','dataxyz'}
        % sceneGet(scene,'xyz');
        % RGB array of scene XYZ values.
        photons = sceneGet(scene,'photons');
        wave    = sceneGet(scene,'wave');
        val     = ieXYZFromEnergy(Quanta2Energy(wave,photons),wave);
        % sz = sceneGet(scene,'size');
        % val = XW2RGBFormat(val,sz(1),sz(2));
        
    case {'lms','datalms','cone'}
        % sceneGet(scene,'lms');
        % RGB (3D array) of scene Stockman LMS values
        energy = sceneGet(scene,'energy');
        wave   = sceneGet(scene,'wave');
        S      = ieReadSpectra('stockmanEnergy',wave);   % Changed March 2019 from 'stockman'
        if numel(wave) > 1, dWave = wave(2) - wave(1);
        else,               dWave = 10; disp('10 nm bandwidth assumed');
        end
        [energy,r,c] = RGB2XWFormat(energy);
        val = energy*S*dWave;
        val = XW2RGBFormat(val,r,c);
        
        % Wavelength parameters
    case {'spectrum','wavespectrum'}
        if checkfields(scene,'spectrum'), val = scene.spectrum; end
    case 'binwidth'
        % This is the integration range for the wavelength steps.  Lights
        % can be at 400,410,420 ... with narrow (1 nm) or wide (50 nm)
        % integration ranges.
        wave = sceneGet(scene,'wave');
        if length(wave) > 1, val = wave(2) - wave(1);
        else val = 1;
        end
    case {'wave','wavelength'}
        % Always a column vector, even if people stick it in the wrong way.
        if checkfields(scene,'spectrum'), val = scene.spectrum.wave(:); end
    case {'nwave','nwaves'}
        if checkfields(scene,'spectrum'), val = length(scene.spectrum.wave); end
        
    case 'height'
        % Height in meters is default
        % sceneGet(scene,'distance','microns')
        s = sceneGet(scene,'sampleSize'); % Each side of a sample, M
        r = sceneGet(scene,'rows');
        val = s*r;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
    case {'width'}
        % Width in meters is default
        % Maybe we should use the same method as in 'height'?
        d = sceneGet(scene,'distance');
        w = sceneGet(scene,'wangular');  % Field of view (horizontal, width)
        val = 2*d*tan(ieDeg2rad(w/2));
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'diagonal','diagonalsize'}
        val = sqrt(sceneGet(scene,'height')^2 + sceneGet(scene,'width')^2);
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'heightwidth','heightandwidth'}
        % sceneGet(scene,'heightwidth','mm');
        val(1) = sceneGet(scene,'height');
        val(2) = sceneGet(scene,'width');
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'area','areameterssquared'}
        % sceneGet(scene,'area')    %square meters
        % sceneGet(scene,'area','mm') % square millimeters
        val = sceneGet(scene,'height')*sceneGet(scene,'width');
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1})^2; end
        
    case {'hspatialresolution','heightspatialresolution','hres'}
        % Resolution parameters
        % Size in distance per pixel, default is meters per pixel
        % sceneGet(oi,'hres','microns') is acceptable syntax.
        h = sceneGet(scene,'height');
        r = sceneGet(scene,'rows');
        val = h/r;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'wspatialresolution','widthspatialresolution','wres'}
        % Resolution parameters
        % Size in m per pixel is default.
        % sceneGet(oi,'wres','microns')
        % sceneGet(oi,'wres')
        w = sceneGet(scene,'width');
        c = sceneGet(scene,'cols');
        val = w/c;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'spatialresolution','distancepersample','distpersamp'}
        % sceneGet(scene,'distPerSamp','mm')
        val = [sceneGet(scene,'hspatialresolution'), sceneGet(scene,'wspatialresolution')];
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'distperdeg','distanceperdegree'}
        % sceneGet(scene,'distanceperdegree')
        % sceneGet(scene,'distancePerDegree','microns');
        val = sceneGet(scene,'width')/sceneGet(scene,'fov');
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'degreesperdistance','degperdist'}
        % sceneGet(scene,'degPerMeter')
        % sceneGet(scene,'degPerDist','micron')
        val = sceneGet(scene,'fov')/sceneGet(scene,'width');
        if ~isempty(varargin), val = val/ieUnitScaleFactor(varargin{1}); end
    case {'degreepersample','degpersamp','degreespersample'}
        % sceneGet(scene,'deg per samp')
        val = sceneGet(scene,'fov')/sceneGet(scene,'cols');
        
    case {'spatialsupport','spatialsamplingpositions'}
        % Spatial locations of points in meters
        % Also, sceneGet(oi,'spatialsupport','microns')
        sSupport = sceneSpatialSupport(scene);
        [xSupport, ySupport] = meshgrid(sSupport.x,sSupport.y);
        val(:,:,1) = xSupport; val(:,:,2) = ySupport;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'hangularresolution','heightangularresolution'}
        % Angular degree per pixel --
        val = 2*ieRad2deg(atan((sceneGet(scene,'hspatialResolution')/sceneGet(scene,'distance'))/2));
    case {'wangularresolution','widthangularresolution'}
        % Angular degree per pixel --
        val = 2*ieRad2deg(atan((sceneGet(scene,'wspatialResolution')/sceneGet(scene,'distance'))/2));
    case {'angularresolution'}
        % Height and width
        val = [sceneGet(scene,'hangularresolution'), sceneGet(scene,'wangularresolution')];
        
    case {'frequencyresolution','freqres'}
        % Default is cycles per degree (cpd).
        % val = sceneGet(scene,'frequencyResolution','mm');
        % val = sceneGet(scene,'frequencyResolution','cpd');
        if isempty(varargin), units = 'cyclesPerDegree';
        else units = varargin{1};
        end
        val = sceneFrequencySupport(scene,units);
    case {'maxfrequencyresolution','maxfreqres'}
        % Default is cycles/deg.  By using
        % sceneGet(scene,'maxfreqres','cpd')
        % sceneGet(scene,'maxfreqres','mm')
        % you can get cycles/{meters,mm,microns}
        %
        if isempty(varargin), units = 'cyclesPerDegree';
        else units = varargin{1};
        end
        % val = sceneFrequencySupport(scene,units);
        if isempty(varargin), units = []; end
        fR = sceneGet(scene,'frequency Resolution',units);
        val = max(max(fR.fx),max(fR.fy));
    case {'frequencysupport','fsupportxy','fsupport2d','fsupport'}
        % val = sceneGet(scene,'frequencyResolution',units);
        if isempty(varargin), units = 'cyclesPerDegree';
        else units = varargin{1};
        end
        fResolution = sceneGet(scene,'frequencyresolution',units);
        [xSupport, ySupport] = meshgrid(fResolution.fx,fResolution.fy);
        val(:,:,1) = xSupport; val(:,:,2) = ySupport;
    case {'frequencysupportcol','fsupportx'}
        % val = sceneGet(scene,'frequencyResolution',units);
        if isempty(varargin), units = 'cyclesPerDegree';
        else units = varargin{1};
        end
        fResolution = sceneGet(scene,'frequencyresolution',units);
        l=find(abs(fResolution.fx) == 0); val = fResolution.fx(l:end);
    case {'frequencysupportrow','fsupporty'}
        % val = sceneGet(scene,'frequencyResolution',units);
        if isempty(varargin), units = 'cyclesPerDegree';
        else units = varargin{1};
        end
        fResolution = sceneGet(scene,'frequencyresolution',units);
        l=find(abs(fResolution.fy) == 0); val = fResolution.fy(l:end);
        
        % Illuminant information from multispectral scenes
    case {'illuminant'}
        % This is the whole illuminant structure.
        if checkfields(scene,'illuminant'), val = scene.illuminant; end
    case {'illuminantname'}
        % sceneGet(scene,'illuminant name')
        il = sceneGet(scene,'illuminant');
        val = illuminantGet(il,'name');
    case {'illuminantformat'}
        % sceneGet(scene,'illuminant format')
        % Returns: spectral, spatial spectral, or empty
        % Check whether illuminant is spatial spectral or just an SPD
        % vector.
        
        il = sceneGet(scene,'illuminant');
        if isempty(il), disp('No scene illuminant.'); return;
        else            val = illuminantGet(il,'illuminant format');
        end
        
    case {'illuminantphotons'}
        % The data field is has illuminant in photon units.
        il = sceneGet(scene,'illuminant');
        val = illuminantGet(il,'photons');
        
    case {'roiilluminantphotons'}
        % sceneGet(scene,'roi illuminant photons',roi)
        % roi is either roiLocs or roi rect
        %
        % The illuminant data is an XW representation of the illuminant
        %
        % If spectral, then just the illuminant data in a c
        %
        if isempty(varargin), error('ROI required');
        else roi = varargin{1};
        end
        val = vcGetROIData(scene,roi,'illuminant photons');
        
    case {'roimeanilluminantphotons'}
        % sceneGet(scene,'roi mean illuminant photons', roi)
        % Return the mean illuminant photon spd in a region of interest
        if isempty(varargin), error('ROI required')
        else roiLocs = varargin{1};
        end
        val = sceneGet(scene,'roi illuminant photons', roiLocs);
        val = mean(val,1);
        
    case {'illuminantenergy'}
        % The data field is has illuminant in standard energy units.  We
        % convert from energy to photons here.  We account for the two
        % different illuminant formats (RGW or vector).
        W = sceneGet(scene,'illuminant wave');
        switch sceneGet(scene,'illuminant format')
            case 'spectral'
                val = sceneGet(scene,'illuminant photons');
                val = Quanta2Energy(W,val(:));
                val = val(:);
            case 'spatial spectral'
                % Spatial-spectral format.  Sorry about all the transposes.
                val = sceneGet(scene,'illuminant photons');
                [val,r,c] = RGB2XWFormat(val);
                val = Quanta2Energy(W,val);
                val = XW2RGBFormat(val,r,c);
            otherwise
                % No illuminant data
        end
    case {'illuminantwave'}
        % Must be the same as the scene wave
        val = sceneGet(scene,'wave');
        
    case {'illuminantxyz','whitexyz'}
        % XYZ coordinates of illuminant, which is also the scene white
        % point.
        energy = sceneGet(scene,'illuminant energy');
        wave   = sceneGet(scene,'wave');
        
        % Deal with spatial spectral case and vector case
        if ndims(energy) == 3
            [energy,r,c] = RGB2XWFormat(energy);
            val = ieXYZFromEnergy(energy,wave);
            val = XW2RGBFormat(val,r,c);
        else
            val    = ieXYZFromEnergy(energy(:)',wave);
        end
        % This can be single with the new data format.
        val = double(val);
    case {'illuminantcomment'}
        if checkfields(scene,'illuminant','comment'),val = scene.illuminant.comment; end
        
        % Reflectance chart parameters,
        % for sceneCreate('reflectance chart') case
        % More parameters may be added into this section.
    case {'chartparameters'} % Structure of reflectance chart parameters
        if checkfields(scene,'chartP'), val = scene.chartP; end
        
        % For display purposes
    case {'rgb','rgbimage'}
        % Get the rgb image shown in the window
        % rgb = sceneGet(scene,'rgb image');
        %   ieNewGraphWin; imshow(rgb)
        
        gam     = sceneGet(scene,'display gamma');
        handles = ieSessionGet('scene handles');
        if isempty(handles), displayFlag = -1;
        else,                displayFlag = -1*abs(get(handles.popupDisplay,'Value'));
        end
        val = sceneShowImage(scene,displayFlag,gam);
                
    case {'displaygamma','gamma'}
        % sceneGet(scene,'display gamma')

        % See if there is a display window
        W = ieSessionGet('scene window handle');
        if isempty(W), val = 1;  % Default if no window
        else, val = str2double(get(W.editGamma,'string'));
        end
        
    otherwise
        disp(['Unknown parameter: ',parm]);
        
end

return;
