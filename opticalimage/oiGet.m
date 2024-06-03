function val = oiGet(oi,parm,varargin)
%Get properties and derived quantities from an optical image structure
%
%     val = oiGet(oi,parm,varargin)
%
%  Unique optical image parameters are stored and many others are derived
%  from the stored values.
%
%  The optical image structure contains the optics structure in a slot.
%  Because of the importance of the optics structure, it is possible to
%  retrieve the optics parameters from the oiGet() function using the
%  syntax
%
%     oiGet(oi,'optics <parameter name>'),
%     e.g., oiGet(oi,'optics fnumber');
%
%  The key structures (scene, oi, sensor, ip, display) are stored in the
%  ISET database.  To retrieve the currently selected optical image, use
%
%     oi = vcGetObject('oi');
%
%  A '*' indicates that the syntax oiGet(scene,param,unit) can be used,
%  where unit specifies the spatial scale of the returned value:  'm'
%  'cm', 'mm', 'um', 'nm'.  Default is meters ('m').
%
%  There is a limitation in that we can only add one additional argument.
%  So it is possible to call
%
%    oiGet(oi,'optics focal length','mm')
%
%  But we do not add a second argument to the list. If you need to have a
%  second argument, use
%       optics = oiGet(oi,'optics');
%       val = opticsGet(optics,param1,param2);
%
%  The source file contains examples.
%
%  List of OI parameters
%      {'name'}           - optical image name
%      {'type'}           - 'opticalimage'
%      {'filename'}       - if read from a file, could store here
%      {'consistency'}    - the oiWindow display reflects the current state (1) or not (0).
%      {'rows'}           - number of row samples
%      {'cols'}           - number of col samples
%      {'size'}           - rows,cols
%      {'image distance'} - distance from lens to image, negative
%      {'hfov'}           - horizontal field of view (deg)
%      {'vfov'}           - vertical field of view (deg)
%      {'aspectratio'}    - aspect ratio of image
%      {'height'}*        - image height
%      {'width'}*         - image width
%      {'diagonal'}*      - image diagonal length
%      {'heightandwidth'}*- (height,width)
%      {'area'}*          - optical image area
%      {'centerpixel'}    - (row,col) of point at center of image
%
% Irradiance
%      {'data'}            - Data structure
%        {'photons'}       - Irradiance data (single precision)
%        {'photons noise'} - Irradiance data with photon noise (single
%        precision)
%        {'energy'}       - Energy rather than photon representation
%        {'energy noise'} - Energy with photon noise
%        {'mean illuminance'}  - Mean illuminance
%        {'illuminance'}      - Spatial array of optical image illuminance
%        {'xyz'}         - (row,col,3) image of the irradiance XYZ values
%
%  N.B. Many of these values can be retrieved from within a spatial region
%  of interest (ROI). See the function
%
%       vcGetROIData(oi,roiLocs,dataType);
%
%  I added 'roi mean photons', and I may add roiphotons, roienergy, and so
%  forth here in the future, and make the vcGetROIData call here.
%
% Illuminance
%      illuminance              - Map of the illuminance
%      mean/max/min illuminance - One of these
%      percentile illuminance   - illuminance percentiles
%               default percentiles are [0.1 10 50 90 99.9];
%      illuminance dynamic range    - Linear dynamic range
%      illuminance dynamic range db - 10 log10 ( linear DR)
%
% Wavelength information
%      {'spectrum'}     - Wavelength information structure
%        {'binwidth'}   - spacing between samples
%        {'wave'}       - wavelength samples (nm)
%        {'nwave'}      - number of wavelength samples
%
% Resolution parameters
%      {'hspatial resolution'}*    - height spatial resolution
%      {'wspatial resolution'}*    - width spatial resolution
%      {'sample spacing'}*         - (width, height) spatial resolution
%      {'distance per sample'}*    - (row,col) distance per spatial sample
%      {'distance per degree'}*    - Distance per degree of visual angle
%      {'degrees per distance'}*   -
%      {'spatial support mesh'}*   - Two matrices of X,Y coordinates
%      {'spatial support linear'}* - Two vectors of x,y coordinates
%      {'spatial sampling positions'}*   - Spatial locations of points
%      {'hangular resolution'}     - angular degree per pixel in height
%      {'wangular resolution'}     - angular degree per pixel in width
%      {'angular resolution'}      - (height,width) angular resolutions
%                                    (deg per sample)
%      {'frequency Support'}*      - frequency resolution in cyc/deg or
%            lp/Unit, i.e., cycles/{meters,mm,microns}
%            oiGet(oi,'frequencyResolution','mm')
%      {'max frequency resolution'}* - Highest frequency
%            oiGet(oi,'maxFrequencyResolution','um')
%      {'frequency support col','fsupportx'}*  - Frequency support for cols
%      {'frequency support row','fsupporty'}*  - Frequency support for rows
%
% Depth
%     {'depth map'}   - Pixel wise depth map in meters
%     {'depth range'} - Depths beyond zero
%
% Optics information
%      {'optics'}           - See opticsSet/Get
%      {'optics model'}     - diffraction limited, shift invariant, ray
%                             trace
%      {'diffuser method'}   - 'skip','blur' (gaussian),'birefringent'
%      {'diffuser blur'}     - S.D. of Gaussian blur
%
%      {'zernike'}    - Zernike polynomial coefficients, which are stored
%                       here when we use the wavefront tools to create a
%                       shift invariant psf based on aberration.

%      {'psfstruct'}        - Entire shift-variant PSF structure
%       {'sampled rt psf'}     - Precomputed shift-variant psfs
%       {'psf sample angles'}  - Vector of sample angle
%       {'psf angle step'}     - Spacing between ray trace angle samples
%       {'psf image heights'}  - Vector of sampled image heights (use optics)
%       {'raytrace optics name'}  - Optics used to derive shift-variant psf
%       {'rt psf size'}        - row,col dimensions of the psf
%
%       {'compute method'}  - How to apply the OTF. 
%                              'opticspsf' - PSF method that regenerates PSF from the wvf.
%                              'opticsotf' - OTF method that splines the OTF
%                              'humanmw'   - Human Marimont-Wandell calc
%                             This applies for some methods, and
%                             is empty other methods where the question does not apply.
%
% Misc
%      {'gamma'}             - Gamma setting in the oiWindow
%      {'rgb image'}         - RGB rendering of OI data
%      {'centroid'}          - Centroid of a point image
%      {'corner points'}     - Chart corner points
%
% Metadata
%      {'metadata'}          - A slot used for misc parameters
%
% Auxiliary information
%      'illuminant'           - HDRS multispectral data illuminant stored here (watts/sr/m^2/nm)
%        'illuminant name'    - Illuminant name
%        'illuminant energy'  - energy data
%        'illuminant photons' - energy data
%        'illuminant xyz'     - CIE XYZ (1931, 10 deg)
%        'illuminant comment' - comment
%        'illuminant format'  - 'spatial spectral' or 'spectral'
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also ieParameterOtype, oiSet, oiCreate, opticsSet, opticsGet

% Examples:
%{
   oi = oiCreate;
   oi = oiSet(oi,'fov', 10);
   oiGet(oi,'rows')
   oiGet(oi,'wave')

   % Use oiGet(oi,'optics') to get the optics object out.
   % opticsGet and opticsSet can be used on optics. The struct
   % can be put back in with oi = oiSet(oi,'optics',optics);
   optics = oiGet(oi,'optics');
   oi = oiSet(oi,'optics',optics);

   % Some optics properties can be obtained directly with oiGet.
   oiGet(oi,'optics fnumber')
   oiGet(oi,'optics otf data','mm',500);

   % Compute oi for a scene and then get
   oi = oiCompute(oi,sceneCreate);
   oiGet(oi,'area','mm')
   oiGet(oi,'width spatial resolution','microns')
   oiGet(oi,'angular resolution')
   oiGet(oi,'dist Per Samp','mm');
   oiGet(oi,'spatial support','microns');             % Meshgrid of zero-centered (x,y) value
   photons = oiGet(oi,'photons',[400 600]);           % Photons at list of wavelengths
%}
%{
   [oi, wvf] = oiCreate('wvf');
   oiGet(oi,'wvf','number spatial samples')
   oiGet(oi,'wvf','calc pupil diameter','mm')
   oiGet(oi,'wvf','zcoeffs','defocus')
%}

val = [];
if ~exist('parm','var') || isempty(parm), error('Param must be defined.'); end

% The code here enables opticsGet calls using the oiGet.
%   oiGet(oi,'optics param',var1, var2, ...)
%
% Equivalent to
%   optics = oiGet(oi,'optics'); opticsGet(optics,param)
%
[oType,parm] = ieParameterOtype(parm);  % Object type is read from parm

switch oType
    case 'optics'
        % If the first string is optics, we either return the optics or an optics
        % parameter.  
        optics = oi.optics;
        if isempty(parm), val = optics;
        else            
            % There is a special case for the OTF when we use dlMTF.
            % See comment below.
            switch(parm)
                case {'otf','otfdata'}
                    % In the diffraction limited case the fsupport comes
                    % from an oiGet, so we need to send in the oi.  This is
                    % bad and we should have fsupport available from the
                    % optics itself. In general, this is not the case.  It
                    % would be best if we could make the opticsGet()
                    % retrieve fsupport without using the oi.  And maybe it
                    % does because there is a dlfsupport get in there.
                    if ~checkfields(optics,'OTF','OTF')
                        % DHB: 1/9/24 - Having the varargin{:} tacked on here as a
                        % fourth argument here caused an error.  So I took it
                        % out.  But I am not sure whether there are cases
                        % where we want the varargin{:} to get passed along.
                        % The varargin seemed to have the oi in it in the
                        % case I was looking at. But the comment above suggests
                        % it is important to pass in the oi explicitly in
                        % the diffraction limited case, so I was worried
                        % about just using the call that is used for the
                        % other cases.
                        % 
                        % It was the third example in opticsGet that caused me to 
                        % make this change.
                        %{
                            scene = sceneCreate; oi = oiCreate('diffraction limited'); 
                            oi = oiCompute(oi,scene); optics = oiGet(oi,'optics');
                            otf = oiGet(oi,'optics otf data',oi);
                            otf = opticsGet(optics,'otf data',oi);
                            otfSupport = oiGet(oi,'fsupport','mm');  % Cycles/mm
                            ieNewGraphWin; mesh(otfSupport(:,:,1),otfSupport(:,:,2),fftshift(abs(otf(:,:,10))));
                        %}
                        %
                        %  val = opticsGet(optics,parm,oi,varargin{:});
                        val = opticsGet(optics,parm,oi);  
                    else
                        val = opticsGet(optics,parm,varargin{:});
                    end
            
                otherwise
                    % All other gets.
                    val = opticsGet(optics,parm,varargin{:});
            end
        end

        %{
        elseif isempty(varargin), val = opticsGet(optics,parm);
        elseif length(varargin) == 1, val = opticsGet(optics,parm,varargin{1});
        elseif length(varargin) == 2, val = opticsGet(optics,parm,varargin{1},varargin{2});
        elseif length(varargin) == 3, val = opticsGet(optics,parm,varargin{1},varargin{2},varargin{3});
        elseif length(varargin) == 4, val = opticsGet(optics,parm,varargin{1},varargin{2},varargin{3},varargin{4});
        end
        %}

    case 'wvf'
        % If a wavefront structure, then we either return the wvf or
        % an wvf parameter.  See above for varargin{:}
        if checkfields(oi,'optics','wvf'),  wvf = oi.optics.wvf;
        else,                  error('OI optics does not have a wavefront slot.');
        end
        if isempty(varargin), val = wvf;
        else
            wvfParam = varargin{1};
            if numel(varargin) > 1, newV = varargin{2:end};
                val = wvfGet(wvf,wvfParam,newV);
            else
                val = wvfGet(wvf,wvfParam);
            end
        end

    otherwise
        % Must be an oi object.  Format the parameter and move on.
        parm = ieParamFormat(parm);
        
        switch parm
            
            case 'type'
                val = oi.type;
            case 'name'
                val = oi.name;
            case 'metadata'
                % Used in different ways.  Not always there.
                if isfield(oi,'metadata')
                    val = oi.metadata;
                end
            case 'human'
                % When the lens slot is there, this is a human model.
                if isfield(oi.optics,'lens'), val = true;
                else,                         val = false;
                end
            case 'filename'
                val = oi.filename;
            case 'consistency'
                % deprecated.
                val = oi.consistency;

            case 'computemethod'
                % This tries to be a little smart for backwards
                % compatibility with stored oi's, such as we have with the
                % mRGC mosaics.
                if (isfield(oi,'computeMethod'))
                    val = oi.computeMethod; 
                else
                    if (isfield(oi.optics,'wvf'))
                        val = 'opticspsf';
                    else
                        val = 'opticsotf';
                    end
                end

            case {'rows','row','nrows','nrow'}
                if checkfields(oi,'data','photons'), val = size(oi.data.photons,1);
                else
                    % disp('Using current scene rows')
                    scene = vcGetObject('scene');
                    if isempty(scene)
                        disp('oiGet: No scene and no oi data.  Using 256 rows.');
                        val = 256;
                    else
                        val = sceneGet(scene,'rows');
                    end
                end
                
            case {'cols','col','ncols','ncol'}
                if checkfields(oi,'data','photons'), val = size(oi.data.photons,2);
                else
                    % disp('Using current scene cols')
                    scene = vcGetObject('scene');
                    if isempty(scene)
                        disp('No scene and no oi data.  Using 256 cols.');
                        val = 256;
                    else
                        val = sceneGet(scene,'cols');
                    end
                end
            case 'size'
                val = [oiGet(oi,'rows'),oiGet(oi,'cols')];
            case {'samplespacing'}
                % Sample spacing, both height and width
                % oiGet(oi,'sample spacing','mm')
                % If no OI is yet computed, we pad the scene size as we would have
                % in the oiCompute calculation.
                sz = oiGet(oi,'size');
                if isempty(sz)
                    % This is what the computed OI size will be, given the
                    % current scene.
                    disp('Expected OI size from current scene')
                    scene  = vcGetObject('scene');
                    sz = sceneGet(scene,'size');
                    if isempty(sz), error('No scene or OI data');
                    else
                        padSize  = round(sz/8);
                        sz = size(padarray(zeros(sz(1),sz(2)),padSize,0,'both'));
                    end
                end
                val = [oiGet(oi,'width')/sz(2) , oiGet(oi,'height')/sz(1)];
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'samplesize'}
                % oiGet(oi,'sample size','mm')
                % This is the spacing between samples.  We expect row and
                % column spacing are equal.
                %
                % Not protected from missing oi data as in 'sample spacing'.
                % Should be integrated with that one.
                w = oiGet(oi,'width');      % Image width in meters
                c = oiGet(oi,'cols');       % Number of sample columns
                val = w/c;                  % M/sample
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'imagedistance','focalplanedistance','distance'}
                % oiGet(oi,'focal plane distance',[scene])
                %
                % The distance from the lens to the focal plane.
                %
                % We set the scene distance here, and then call
                %
                %     opticsGet(optics,'image distance')
                %
                % It is unfortunate that 'distance' is a possible get.
                % Issuing a warning.
                %
                % March 11, 2019 (BW) Created the minSize = 10 variable and
                % set the new logic. Value was 5.  This was in response to
                % an observation by Zhenyi.
                if isequal(parm,'distance')
                    warning('Returning lens to sensor focal distance given the scene depth.');
                end

                % The focal plane depends on the scene distance.  If there
                % is no scene, we check the depth map.  If there is no
                % depth map we assume very far away.
                if isempty(varargin)
                    % No scene distance sent in.  So, we use the oi depth
                    % map to figure out the scene distance in the middle
                    if checkfields(oi,'depthMap') && ~isempty(oi.depthMap)
                        sz = size(oi.depthMap);
                        minSize = 10;
                        if  sz(1) < 2*minSize || sz(2) < 2*minSize
                            sDist = mean(oi.depthMap(:));
                        else
                            % Use the middle of the depth map
                            sDist = getMiddleMatrix(oi.depthMap,minSize);
                            sDist = mean(sDist(:));
                        end
                    else
                        % fprintf('Assuming scene at infinity.\n');
                        %sDist = 1e10;

                        % Try to get the validation to work by forcing
                        % this to match what isetbio does for the
                        % validation.
                        sDist = 1.2;
                    end
                else
                    % The scene distance was sent in
                    sDist = sceneGet(varargin{1},'distance','m');
                end
                
                % Call the optics version of this routine, with the sDist
                % set.
                val = oiGet(oi,'optics image distance',sDist);
                
                % Adjust the units
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'wangular','widthangular','hfov','horizontalfieldofview','fov'}
                % oiCompute(oi,scene) assigns the angular field of
                % view to the oi. 
                %
                % This horizontal FOV represents the size of the OI,
                % usually after the computational padding. Reflects
                % the angle of the scene it represents.
                if checkfields(oi,'wAngular') && ~isempty(oi.wAngular)
                    val = oi.wAngular;
                else
                    % We use the scene or a default.  Maybe this should be
                    % an error.  Or computed from the 'width' and the
                    % 'focal plane distance'.
                    fprintf('*** The oi fov is not set yet.  ');
                    scene = vcGetObject('scene');
                    if isempty(scene) 
                        % Default scene visual angle.
                        fprintf('Using a default fov of 10.\n');
                        disp('oiGet:  No scene, arbitrary oi angle: 10 deg'), val = 10;
                    else              
                        % Use current scene angular width
                        fprintf('Using the scene fov.\n');
                        val = sceneGet(scene,'wangular');
                    end
                end
                
            case {'hangular','heightangular','vfov','verticalfieldofview'}
                % We only store the width FOV.  We insist that the pixels are square
                h = oiGet(oi,'height');               % Height in meters
                d = oiGet(oi,'focal plane distance'); % Distance to lens
                val = rad2deg(2*atan((0.5*h)/d));     % Vertical field of view
                
            case {'dangular','diagonalangular','diagonalfieldofview'}
                val = sqrt(oiGet(oi,'wAngular')^2 + oiGet(oi,'hAngular')^2);
                
            case 'aspectratio'
                r = oiGet(oi,'rows'); c = oiGet(oi,'cols');
                if (isempty(c) || c == 0), disp('No OI'); return;
                else, val = r/c;
                end
                
                % Terms related to the optics
                % This is the large optics structure
            case 'optics'
                if checkfields(oi,'optics'), val = oi.optics; end
            case 'opticsmodel'
                if checkfields(oi,'optics','model'), val = oi.optics.model; end

            case 'lens'
                % ISETBio Lens class.
                if checkfields(oi, 'optics', 'lens'), lens = oi.optics.lens;
                else, return;
                end
                
                if isempty(varargin), val = lens; return;
                else, val = lens.get(parm, varargin{:});
                end

            case {'zernike'}
                % Store the Zernike polynomial coefficients
                val = oi.zernike;
            case {'wvf'}
                % The whole wavefront struct.
                val = oi.wvf;
                
                % Sometimes we precompute the psf from the optics and store
                % it here. The angle spacing of the precomputation is
                % specified here.
            case {'psfstruct','shiftvariantstructure'}
                % Entire svPSF structure (sv = shift-varying)
                if checkfields(oi,'psf'), val = oi.psf; end
            case {'svpsf','sampledrtpsf','shiftvariantpsf'}
                % Precomputed shift-varying psfs
                if checkfields(oi,'psf','psf'), val = oi.psf.psf; end
            case {'rtpsfsize'}
                % Size of each PSF
                if checkfields(oi,'psf','psf'), val = size(oi.psf.psf{1,1,1}); end
            case {'psfsampleangles'}
                % Vector of sample angle
                if checkfields(oi,'psf','sampAngles'), val = oi.psf.sampAngles; end
            case {'psfanglestep'}
                % Spacing between angles
                if checkfields(oi,'psf','sampAngles')
                    val = oi.psf.sampAngles(2) - oi.psf.sampAngles(1);
                end
            case {'psfimageheights'}
                % Vector of sampled image heights
                if checkfields(oi,'psf','imgHeight'), val = oi.psf.imgHeight; end
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
            case {'psfopticsname','raytraceopticsname'}
                % Optics data are derived from
                if checkfields(oi,'psf','opticsName'), val = oi.psf.opticsName; end
            case 'psfwavelength'
                % Wavelengths for this calculation. Should match the optics, I
                % think.  Not sure why it is duplicated.
                if checkfields(oi,'psf','wavelength'), val = oi.psf.wavelength; end
                
                
                % optical diffuser properties
            case {'diffusermethod'}
                % 0 - skip, 1 - gauss blur, 2 - birefringent
                if checkfields(oi,'diffuser','method')
                    val = oi.diffuser.method;
                end
            case {'diffuserblur'}
                if checkfields(oi,'diffuser','blur')
                    val = oi.diffuser.blur;
                end
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case 'data'
                if checkfields(oi,'data'), val = oi.data; end
                
            case {'photons'}
                % oiGet(oi,'photons',[waveBand])
                % Read photon data.  Default is all wavebands in 3d matrix.
                
                % Note we avoid using oiGet(oi,'photons') so as to not
                % duplicate the memory usage in the photon data.
                if checkfields(oi,'data','photons')
                    if isempty(varargin)
                        % allPhotons = oiGet(oi,'photons')
                        val = double(oi.data.photons);
                    else
                        % waveBandPhotons = oiGet(oi,'photons',500)
                        idx = ieFindWaveIndex(oiGet(oi,'wave'),varargin{1});
                        val = double(oi.data.photons(:,:,idx));
                    end
                end

            case 'roiphotons'
                if isempty(varargin), error('ROI required')
                else, roiLocs = varargin{1};
                end
                val = vcGetROIData(oi, roiLocs, 'photons');

            case 'roimeanphotons'
                % oiGet(oi,'roi mean photons',roiLocs)
                % Returned as XW format
                %
                % Mean photons at each wavelength (SPD) in the ROI
                if isempty(varargin), error('ROI required'); end
                
                roiLocs = varargin{1};  % Either locs or rect is OK
                val = mean(vcGetROIData(oi,roiLocs));
                val = val(:)';

            case 'roienergy'
                if isempty(varargin), error('ROI required')
                else, roiLocs = varargin{1};
                end

                % Check format.
                val = vcGetROIData(oi, roiLocs, 'energy');

            case 'roimeanenergy'
                % oiGet(oi,'roi mean energy');
                % Returned as XW format (row vector)
                if isempty(varargin), error('ROI required')
                else, roiLocs = varargin{1};
                end
                val = oiGet(oi, 'roienergy', roiLocs);
                val = mean(val, 1);
                val = val(:)';

            case {'photonsnoise','photonswithnoise'}
                % pn = oiGet(oi,'photons noise');
                % The current photons are the mean.
                % This returns the mean photons plus Poisson noise
                val = oiPhotonNoise(oi);
                
            case {'energynoise','energywithnoise'}
                % Return mean energy plus Poisson photon noise
                % val = oiGet(oi,'energy noise');
                val = oiPhotonNoise(oi);
                wave = oiGet(oi,'wave');
                val = Quanta2Energy(wave(:),val);
            case {'datamax','dmax'}
                % Needed in oiCompute for padding.  But ...
                val = max(oi.data.photons(:));
            case {'datamin','dmin'}
                val = min(oi.data.photons(:));
            case {'bitdepth','compressbitdepth'}
                % Should only be single precision (32) storage, I think.
                % Though, we still allow 64 (double).
                % Not sure what happens with gpuArray.
                if checkfields(oi,'data','bitDepth'), val = oi.data.bitDepth;
                else, val = 32;
                end
                
            case 'energy'
                % We  compute the energy from the photons and only
                % store photons.  Otherwise, there could be an inconsistency.
                photons = oiGet(oi,'photons');
                wave = oiGet(oi,'wave');
                val = Quanta2Energy(wave,photons);
                
            case {'meanilluminance','meanillum'}
                % Derived from the illuminance
                if ~checkfields(oi,'data','illuminance') || isempty(oi.data.illuminance)
                    oi.data.illuminance = oiCalculateIlluminance(oi);
                end
                val = mean(oi.data.illuminance(:));
            case {'maxilluminance', 'peakilluminance'}
                % Derived from the illuminance
                if ~checkfields(oi,'data','illuminance') || isempty(oi.data.illuminance)
                    oi.data.illuminance = oiCalculateIlluminance(oi);
                end
                val = max(oi.data.illuminance(:));
            case {'minilluminance'}
                % Derived from the illuminance
                if ~checkfields(oi,'data','illuminance') || isempty(oi.data.illuminance)
                    oi.data.illuminance = oiCalculateIlluminance(oi);
                end
                val = min(oi.data.illuminance(:));

            case {'illuminance','illum'}
                % The whole spatial illuminance map
                if ~checkfields(oi,'data','illuminance') || isempty(oi.data.illuminance)
                    val = oiCalculateIlluminance(oi);
                else,    val = oi.data.illuminance;
                end
            case {'illuminancedynamicrangedb','dynamicrangedb'}
                illum = oiGet(oi,'illuminance');
                if min(illum(:)) > 0
                    val = 10*log10(max(illum(:))/min(illum(:)));
                else,  val = Inf;
                end
            case {'percentileilluminance','percentilesilluminance'}
                % Useful for finding and then setting the dynamic range
                if isempty(varargin)
                    percentiles = [0.1 10 50 90 99.9];
                else
                    assert(isvector(varargin{1}));
                    percentiles = varargin{1};
                end
                illum = oiGet(oi,'illuminance');
                val.percentiles = percentiles;
                val.lum = prctile(illum(:),percentiles);

            case {'illuminancedynamicrange','dynamicrange'}
                % oiGet(oi,'luminance dynamic range')
                illum = oiGet(oi,'illuminance');
                if min(illum(:)) > 0
                    val = max(illum(:))/min(illum(:));
                else,  val = Inf;
                end
                
            case {'xyz','dataxyz'}
                % oiGet(oi,'xyz');
                % RGB array of oi XYZ values.  These are returned as an RGB format
                % at the spatial sampling grid of the optical image.
                photons = oiGet(oi,'photons');
                wave    = oiGet(oi,'wave');
                val     = ieXYZFromEnergy(Quanta2Energy(wave,photons),wave);
                
            case {'spectrum'}
                if checkfields(oi,'spectrum'), val = oi.spectrum; end
            case 'binwidth'
                wave = oiGet(oi,'wave');
                if length(wave) > 1, val = wave(2) - wave(1);
                else, val = 1;
                end
            case {'datawave','wave','wavelength'}
                % oiGet(oi,'wave')
                % Always a column vector, even if people stick it in the
                % wrong way.
                if checkfields(oi,'spectrum')
                    val = oi.spectrum.wave(:);
                end
            case {'ndatawave','nwave','nwaves'}
                % oiGet(oi,'n wave')
                % Changed July 2012.
                val = length(oiGet(oi,'wave'));
                
            case 'height'
                % Height in meters is default
                % Computed from sample size times number of rows.
                % Sample size is computed from the width.
                % oiGet(oi,'height','microns')
                val = oiGet(oi,'sample size')*oiGet(oi,'rows');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
            case {'width'}
                % oiGet(oi,'width',units)
                % Width is computed from knowledge of the distance to focal
                % plane and the horizontal (width) field of view.
                %
                % Width in meters is default - We need to handle 'skip' case
                
                % TG/BW changed this from 'focal plane distance' to
                % 'optics focal length' (Nov 5 2021).  This might
                % cause various test failures.
                d   = oiGet(oi,'focal plane distance');
                % d   = oiGet(oi,'optics focal length');   % Distance from lens to image
                fov = oiGet(oi,'wangular');              % Field of view (horizontal, width)
                
                % fov   = 2 * atand((0.5*width)/d) % Opposite over adjacent
                % width = 2 * d * tand(fov/2)
                val = 2*d*tand(fov/2);
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'diagonal','diagonalsize'}
                val = sqrt(oiGet(oi,'height')^2 + oiGet(oi,'width')^2);
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'heightwidth','heightandwidth'}
                val(1) = oiGet(oi,'height');
                val(2) = oiGet(oi,'width');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'area','areameterssquared'}
                % oiGet(oi,'area')    %square meters
                % oiGet(oi,'area','mm') % square millimeters
                val = oiGet(oi,'height')*oiGet(oi,'width');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1})^2; end
                
            case {'centerpixel','centerpoint'}
                val = [oiGet(oi,'rows'),oiGet(oi,'cols')];
                val = floor(val/2) + 1;
                
            case {'hspatialresolution','heightspatialresolution','hres'}
                % oiGet(oi,'h spatial resolution',units)
                % Resolution parameters
                % Distance per pixel. Default is meters/pixel
                % oiGet(oi,'hres','microns') is acceptable syntax.
                h = oiGet(oi,'height');
                r = oiGet(oi,'rows');
                if isempty(r) && strcmp(oiGet(oi,'type'),'opticalimage')
                    % For optical images we return a default based on the scene.
                    % This is used when no optical image has been calculated.
                    scene = vcGetObject('scene');
                    if isempty(scene)
                        disp('oiGet: No scene or oi data.  Using 256 rows');
                        r = 256; % Make something up
                    else
                        r = oiGet(scene,'rows');
                    end
                end
                val = h/r;
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'wspatialresolution','widthspatialresolution','wres'}
                % oiGet(oi,'w spatial resolution',units)
                % Size in m per pixel is default.
                
                w = oiGet(oi,'width');
                c = oiGet(oi,'cols');
                if isempty(c)
                    % For optical images we return a default based on the scene.
                    % This is used when no optical image has been calculated.
                    scene = vcGetObject('scene');
                    if isempty(scene)
                        disp('No scene or oi data.  Using 256 cols');
                        c = 256;
                    else
                        c = oiGet(scene,'cols');
                    end
                    
                end
                val = w/c;
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'spatialresolution','distancepersample','distpersamp'}
                % oiGet(oi,'distPerSamp','mm')
                val = [oiGet(oi,'hspatialresolution'), oiGet(oi,'wspatialresolution')];
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'distperdeg','distanceperdegree'}
                % This routine should call
                % opticsGet(optics,'dist per deg',unit) rather than compute it
                % here.
                val = oiGet(oi,'width')/oiGet(oi,'fov');
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'degreesperdistance','degperdist'}
                % oiGet(oi,'degrees per distance')
                % oiGet(oi,'degPerDist','micron')
                %
                % We should probably call:
                %   opticsGet(optics,'dist per deg',unit)
                % which is preferable to this call.
                if isempty(varargin), units = 'm';
                else, units = varargin{1}; end
                val = oiGet(oi,'distance per degree',units);   % meters
                val = 1 / val;
                % val = oiGet(oi,'fov')/oiGet(oi,'width');
                % if ~isempty(varargin), val = val/ieUnitScaleFactor(varargin{1}); end
                
            case {'spatialsupportmesh','spatialsupport'}% ,'spatialsamplingpositions'}
                % oiGet(oi,'spatialsupport',[units])
                %
                % Mesh grid of oi image spatial locations of points
                % Default unit is meters, center of image is 0,0
                % val(:,:,[1 2]) where 1 is the x-dimension and
                %                      2 is the y-dimension.
                %
                
                sSupport = oiSpatialSupport(oi);  % Meters is default
                [xSupport, ySupport] = meshgrid(sSupport.x,sSupport.y);
                val(:,:,1) = xSupport; val(:,:,2) = ySupport;
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'spatialsupportlinear'}
                % oiGet(oi,'linear spatial support',[units])
                % linear samples of y,x spatial positions.
                % Default
                val = oiSpatialSupport(oi);
                if ~isempty(varargin)
                    val.x = val.x*ieUnitScaleFactor(varargin{1});
                    val.y = val.y*ieUnitScaleFactor(varargin{1});
                end
                
            case {'angularsupport','angularsamplingpositions'}
                % Angular values of sample points
                % Units can be deg (default), min or sec and should include radians
                %
                degPerSamp = oiGet(oi,'angular resolution');
                sz = oiGet(oi,'size');
                
                tmp = degPerSamp(2)*(1:sz(2));
                aSupport.x = tmp - mean(tmp(:));
                tmp = degPerSamp(1)*(1:sz(1));
                aSupport.y = tmp - mean(tmp(:));
                
                % Deal with units
                if ~isempty(varargin)
                    unit = lower(varargin{1});
                    switch unit
                        case {'deg'}
                            % Default
                        case 'min'
                            aSupport.x = aSupport.x*60;
                            aSupport.y = aSupport.y*60;
                        case 'sec'
                            aSupport.x = aSupport.x*60*60;
                            aSupport.y = aSupport.y*60*60;
                        case 'radians'
                            aSupport.x = deg2rad(aSupport.x);
                            aSupport.y = deg2rad(aSupport.y);
                        otherwise
                            error('Unknown angular unit %s\n',unit);
                    end
                end
                
                [xSupport, ySupport] = meshgrid(aSupport.x,aSupport.y);
                val(:,:,1) = xSupport; val(:,:,2) = ySupport;
                %
            case {'hangularresolution','heightangularresolution'}
                % Angular degree per pixel -- in degrees
                val = 2*rad2deg(atan((oiGet(oi,'hspatialResolution')/oiGet(oi,'focal plane distance'))/2));
            case {'wangularresolution','widthangularresolution'}
                % Angle (degree) per pixel -- width
                val = 2*rad2deg(atan((oiGet(oi,'wspatialResolution')/oiGet(oi,'focal plane distance'))/2));
            case {'angularresolution','degperpixel','degpersample','degreepersample','degreeperpixel'}
                % Height and width
                val = [oiGet(oi,'hangularresolution'), oiGet(oi,'wangularresolution')];
                
            case {'frequencyresolution','freqres'}
                % Default is cycles per degree
                % val = oiGet(oi,'frequencyResolution',units);
                
                if isempty(varargin), units = 'cyclesPerDegree';
                else, units = varargin{1};
                end
                val = oiFrequencyResolution(oi,units);
            case {'maxfrequencyresolution','maxfreqres'}
                % Default is cycles/deg.  By using
                % oiGet(oi,'maxfreqres',units) you can get cycles/{meters,mm,microns}
                %
                if isempty(varargin), units = 'cyclesPerDegree';
                else, units = varargin{1};
                end
                % val = oiFrequencyResolution(oi,units);
                if isempty(varargin), units = []; end
                fR = oiGet(oi,'frequency resolution',units);
                val = max(max(fR.fx),max(fR.fy));
            case {'frequencysupport','fsupportxy','fsupport2d','fsupport'}
                % val = oiGet(oi,'frequency support',units);
                if isempty(varargin), units = 'cyclesPerDegree';
                else, units = varargin{1};
                end
                fResolution = oiGet(oi,'frequencyresolution',units);
                [xSupport, ySupport] = meshgrid(fResolution.fx,fResolution.fy);
                val(:,:,1) = xSupport; val(:,:,2) = ySupport;
            case {'frequencysupportcol','fsupportx'}
                % val = oiGet(oi,'frequency support col',units);
                if isempty(varargin), units = 'cyclesPerDegree';
                else, units = varargin{1};
                end
                fResolution = oiGet(oi,'frequencyresolution',units);
                l=find(abs(fResolution.fx) == 0); val = fResolution.fx(l:end);
            case {'frequencysupportrow','fsupporty'}
                % val = oiGet(oi,'frequency support row',units);
                if isempty(varargin), units = 'cyclesPerDegree';
                else, units = varargin{1};
                end
                fResolution = oiGet(oi,'frequencyresolution',units);
                l=find(abs(fResolution.fy) == 0); val = fResolution.fy(l:end);
                
                % Visual information
            case {'rgb','rgbimage'}
                %  rgb = oiGet(oi,'rgb image');
                %
                % Get the rgb image shown in the oiWindow as per the
                % displayFlag
                
                % Uses oiShowImage() to compute the rgb data consistently
                % with what is in the oiWindow.  Force the renderFlag to
                % negative to prevent display.
                gam = oiGet(oi,'gamma');
                renderFlag = oiGet(oi,'render flag index');
                val = oiShowImage(oi,-1*abs(renderFlag),gam);
                
            case {'gamma'}
                % oiGet(oi,'display gamma')
                % There can be a conflict with the display window in display
                % gamma call
                %
                % See if there is a display window
                oiW = ieSessionGet('oi window');
                if isempty(oiW), val = 1;  % Default if no window
                else, val = str2double(oiW.editGamma.Value);
                end
                
            case {'renderflagindex'}
                % val = oiGet(oi,'display flag index')
                % When there is an oiWindow open and set in the vcSESSION,
                % find the display flag index
                %
                % See if there is a display window
                oiW = ieSessionGet('oi window');
                if isempty(oiW), val = 1;   % Default if no window
                else, val = find(ieContains(oiW.popupRender.Items,oiW.popupRender.Value));
                end
                
            case {'renderflagstring'}
                % val = oiGet(oi,'display flag string')
                % When there is an oiWindow open and set in the vcSESSION,
                % find the display flag index
                
                % See if there is a display window
                oiW = ieSessionGet('oi window');
                if isempty(oiW), val = 'Standard RGB';   % Default if no window
                else, val = oiW.popupRender.Value;
                end
                
            case {'chartparameters'}
                % Struct of chart parameters
                if checkfields(oi,'chartP'), val = oi.chartP; end
            case {'cornerpoints','chartcornerpoints','chartcorners'}
                % fourPoints = oiGet(oi,'chart corner points');
                if checkfields(oi,'chartP','cornerPoints'), val = oi.chartP.cornerPoints; end
            case {'chartrects','chartrectangles'}
                % rects = oiGet(oi,'chart rectangles');
                if checkfields(oi,'chartP','rects'), val = oi.chartP.rects; end
            case {'currentrect'}
                % [colMin rowMin width height]
                % Used for ROI display and management.
                if checkfields(oi,'chartP','currentRect'), val = oi.chartP.currentRect; end
                
            case {'centroid'}
                % val = oiGet(oi,'centroid',[units]);
                % Finding the centroid of the luminance distribution in the
                % oi.  The X and Y values (column and row) are returned in
                % the val.X and val.Y slots.
                %
                % The coordinates of the (X,Y) are arranged so that the
                % middle of the oi irradiance image is (0,0).
                %
                % By default, the units are col/row.
                % If a unit is specified, they are the physical units
                % (e.g., 'mm').
                
                img = oiGet(oi,'illuminance');
                sz  = oiGet(oi,'size');
                
                % Force to unit area and flip up/down for a point spread
                img = img./sum(img(:));
                
                if isempty(varargin)
                    % Calculate the weighted centroid/center-of-mass with
                    % respect to col/row units
                    xSample = (1:sz(2)) - sz(2)/2;  % Columns
                    ySample = (1:sz(1)) - sz(1)/2;  % Rows
                    [distanceX, distanceY] = meshgrid(xSample,ySample);
                else
                    % A unit is specified.  Use it.
                    s = oiGet(oi,'spatial support',varargin{1});
                    distanceX = s(:,:,1); distanceY = s(:,:,2);
                end
                
                % distanceMatrix = sqrt(distanceX.^2 + distanceY.^2);
                val.X = sum(sum(img .* distanceX));
                val.Y = sum(sum(img .* distanceY));
                
            case {'depthmap'}
                % oiGet(oi,'depth map',units)
                %
                % Depth information: The depth map in the OI domain
                % indicates locations where there were legitimate scene
                % data for computing the OI data.  Other regions are
                % 'extrapolated' by sceneDepthRange to keep the
                % calculations correct.  But they don't correspond to the
                % original data.  When there is no depthMap in the scene,
                % the oi depth map values are all logical '1' (true).
                if checkfields(oi,'depthMap'), val = oi.depthMap; end
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
            case {'depthrange'}
                % oiGet(oi,'depth map', units)
                % Min and max of the depth values > 0
                depthmap = oiGet(oi,'depth map');
                tmp = depthmap(depthmap > 0);
                val = [min(tmp(:)), max(tmp(:))];
                if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
                
                % Illuminant methods. Related to ISET3D.
                %
                % In some iset3d cases we compute illuminant information.
                % We run the PBRT Docker container and replace all the surfaces
                % with a white Lambertian surface.  piRender() in ISET3D
                % returns the spatial-spectral illuminant.
                %
            case {'illuminant'}
                % This is the whole illuminant structure.
                if checkfields(oi,'illuminant'), val = oi.illuminant; end
            case {'illuminantname'}
                % oiGet(scene,'illuminant name')
                il = oiGet(oi,'illuminant');
                val = illuminantGet(il,'name');
            case {'illuminantformat'}
                % oiGet(oi,'illuminant format')
                % Checks whether illuminant is spatial spectral or just an
                % SPD vector.
                % Returns: spectral, spatial spectral, or empty
                il = oiGet(oi,'illuminant');
                if isempty(il), disp('No OI illuminant.'); return;
                else,           val = illuminantGet(il,'illuminant format');
                end
                
            case {'illuminantphotons'}
                % The data field is has illuminant in photon units.
                il = oiGet(oi,'illuminant');
                val = illuminantGet(il,'photons');
            case {'illuminantenergy'}
                % The data field is has illuminant in standard energy units.  We
                % convert from energy to photons here.  We account for the two
                % different illuminant formats (RGW or vector).
                W = oiGet(oi,'wave');
                switch oiGet(oi,'illuminant format')
                    case 'spectral'
                        val = oiGet(oi,'illuminant photons');
                        val = Quanta2Energy(W,val(:));
                        val = val(:);
                    case 'spatial spectral'
                        % Spatial-spectral format.  Sorry about all the transposes.
                        val = oiGet(oi,'illuminant photons');
                        [val,r,c] = RGB2XWFormat(val);
                        val = Quanta2Energy(W,val);
                        val = XW2RGBFormat(val,r,c);
                    otherwise
                        % No illuminant data
                end
            case {'illuminantwave'}
                % Must be the same as the oi wave
                val = oiGet(oi,'wave');
                
            case {'illuminantxyz','whitexyz'}
                % XYZ coordinates of illuminant, which is also the scene white
                % point.
                energy = oiGet(oi,'illuminant energy');
                wave   = oiGet(oi,'wave');
                
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
                if checkfields(oi,'illuminant','comment'),val = scene.illuminant.comment; end
                
            otherwise
                disp(['Unknown parameter: ',parm]);
                
        end
end

end

