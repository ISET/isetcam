function val = opticsGet(optics,parm,varargin)
% Get optics parameters
%
%      val = opticsGet(optics,parm,varargin)
%
% This routine returns parameters of the optics model, such as f/#,
% numerical aperture, aperture diameter, focal length, and many other
% parameters.
%
% In some cases, the returned parameters depend on properties of the scene.
% In those cases, the varargin{} includes a scene parameter, such as the
% field of view.
%
% There are three types of optics models, of increasing complexity. The
% method in use can be selected by the popup menu in the optics window. The
% method is selected by the parameter opticsSet(optics,'model',parameter);
% See the discussion in oiCompute for a description of the different optics
% models.
%
% Note about the OTF and the PSF
%
%  We store the OTF data with DC at the (1,1) position.  This is true
%  throughout ISET. To understand the implications for certain calculations
%  see the script and tutorial in s_FFTinMatlab.
%
%  Although Matlab uses this representation, when we make graphs and
%  images we put the center of the image at the center -- of course -- and
%  we also put the DC value of the OTF in the middle of the image.  Hence,
%  when we return the frequency support or the spatial support we create
%  values for frequencies that run from negative to positive.  Similarly
%  when we compute the spatial support we create spatial samples that run
%  below and above zero.
%
% Example:
%   oi = oiCreate; optics = oiGet(oi,'optics');
%   oi = oiSet(oi,'wave',400:10:700);
%
%   NA = opticsGet(optics,'numerical aperture');   % Numerical aperture
%   f  = opticsGet(optics,'f number');
%   fLength = opticsGet(optics,'focal length','mm')
%
%   psf = opticsGet(optics,'psf Data',600);  % Shift invariant data
%   vcNewGraphWin; mesh(sSupport(:,:,1),sSupport(:,:,2),psf);
%
%   otf = opticsGet(optics,'otf data',oi, 'mm',450);
%   vcNewGraphWin; mesh(fftshift(abs(otf)));
%
%   otfAll = opticsGet(optics,'otf data',oi);
%
%   otfSupport = oiGet(oi,'fsupport','mm');  % Cycles/mm
%   vcNewGraphWin; mesh(otfSupport(:,:,1),otfSupport(:,:,2),fftshift(abs(otf)))
%
%   FOV = 10; opticsGet(optics,'image height',FOV,'mm')
%   FOV = 10; opticsGet(optics,'image diagonal',FOV,'um')
%
%  Many ray trace calls begin with rt, as in
%   psf = opticsGet(optics,'rt PSF',500);     % Shift-variant ray trace
%
% N.B. The OTF support does not work for ray trace optics (yet).
%
% Optics parameters
%
%   '*' means that you can use the syntax opticsGet(optics,'parm','unit'),
%   such as  opticsGet(optics,'focalLength','mm')
%
%      {'name'}    - name for these optics
%      {'type'}    - always 'optics'
%      {'model'}   - Type of optics computation,
%                    diffractionLimited, rayTrace, or shiftInvariant.
%      {'fnumber'}            - f#, ratio of focal length to aperture,
%                               a dimensionless quantity.
%      {'effective fnumber'}   - effective f-number
%      {'focal length'}        - focal length (M)
%      {'power'}               - optical power in diopters (1/f),units 1/M
%      {'image distance'}      - image distance from lensmaker's equation
%      {'image height'}*       - image height
%      {'image width'}*        - image width
%          opticsGet(optics,'imagewidth',10,'mm')
%      {'image diagonal'}*     - image diagonal size
%      {'numerical aperture'}  - numerical aperture
%      {'aperture diameter'}*  - aperture diameter
%      {'aperture radius'}*    - aperture radius
%      {'aperture area'}*      - aperture area
%      {'magnification'}       - optical image magnification (<0 inverted)
%      {'pupil magnification'} -
%
% Off-axis methods and data
%      {'off axis method'}     - custom relative illumination method
%      {'cos4th method'}       - default cos4th method
%      {'cos4th data'}         - place to store cos4th data
%
% OTF information   - Used for shift-invariant calculations
%      {'otf data'}        - the optical transfer function data
%      {'otf size'}
%      {'otf fx'}          - column (fx) samples of OTF data
%      {'otf fy'}          - row (fy) samples of OTF data
%      {'otf support'}     - cell array, val{1:2}, of fy,fx samples
%      {'otf wave'}        - wavelength samples of the otf data
%      {'otf binwidth'}    - difference between wavelength samples
%      {'psf data'}        - psf data, calculated from the stored otfdata
%      {'psf spacing'}
%      {'psf support'}
%      {'incoherentcutoffspatialfrequency'}*    - Vector of incoherent cutoff freq
%                                                 for all wavelengths
%      {'maxincoherentcutoffspatialfrequency'}* - Largest incoherent cutoff
%
% Lens transmittance
%      {'transmittance'}    - lens transmission function
%         {'wave'}          - sample wavelengths
%         {'scale'}         - fraction transmitted (0,1)
%
%  Ray Trace information - Used for non shift-invariant calculations
%      {'rtname'}        - name, may differ from file because of processing
%      {'raytrace'}      - structure of ray trace information
%      {'rtopticsprogram'}     - 'zemax' or 'code v'
%      {'rtlensfile'}          - Name of lens description file
%      {'rteffectivefnumber'}  - Effective fnumber
%      {'rtfnumber'}           - F-number
%      {'rtmagnification'}     - Magnification
%      {'rtreferencewavelength'}    - Design reference wavelength (nm)
%      {'rtobjectdistance'}*        - Design distance to object plane
%      {'rtfieldofview'}            - Diagonal field of view (deg)
%      {'rteffectivefocallength'}*  - Effective focal length
%      {'rtpsf'}               - structure containing psf information
%        {'rtpsfdata'}            - psf data
%                opticsGet(optics,'rtpsfdata')
%                opticsGet(optics,'rtpsfdata',fieldHeight,wavelength)
%        {'rtpsfsize'}            - (row,col) of the psf functions
%        {'rtpsfwavelength'}      - sample wavelengths of psf estimates
%        {'rtpsffieldheight'}*    - field heights for the psfs
%        {'rtpsfsamplespacing'}*  - sample spacing within the psfs
%        {'rtpsfsupport'}*        - spatial position (2D) of the psf functions
%        {'rtpsfsupportrow'}*     - spatial position of row samples
%        {'rtpsfsupportcol'}*     - spatial position of col samples
%        {'rtotfdata'}            - OTF derived from PSF ray trace data  *** (NYI)
%      {'rtrelillum'}       - structure of relative illumination information
%        {'rtrifunction'}       - Relative illumination function
%        {'rtriwavelength'}     - Wavelength samples (nm)
%        {'rtrifieldheight'}*   - Field heigh values
%      {'rtgeometry'}       - structure of geometric distortion information
%        {'rtgeomfunction'}         - Geometric distortion function
%               opticsGet(optics,'rtgeomfunction',[],'mm')
%               opticsGet(optics,'rtgeomfunction',500)
%        {'rtgeomwavelength'}       - Wavelength samples (nm)
%        {'rtgeomfieldheight'}*     - Field height samples
%        {'rtgeommaxfieldheight'}*  - Maximum field height sample
%
% Computational parameters
%       {'rtComputeSpacing'}*      - Sample spacing for PSF calculation
%
% Copyright ImagEval Consultants, LLC, 2005.


% Programming TODO:
%   Many of the rt spatial variables are stored in mm by the rtImportData
% function.  So, we are always dividing them by 1000 for return in meters.
% We should probably just store them in meters properly inside of
% rtImportData.
%
% Simmplify the OTF support functions
%
val = [];

if ~exist('optics','var') || isempty(optics),  error('No optics specified.'); end
if ~exist('parm','var')   || isempty(parm),    error('No parameter specified.'); end

% We return different parameters depending on whether the user has a
% shift-invariant lens model (e.g., diffraction-limited) or a general ray
% trace model.
rt = 0;
if checkfields(optics,'rayTrace') && ~isempty(optics.rayTrace)
    % If there are ray trace data, and the current model is ray trace,
    % set rt to 1.
    if strcmpi(optics.model,'raytrace'), rt = 1; end
end

parm = ieParamFormat(parm);
switch parm
    
    case 'name'
        val = optics.name;
    case 'type'
        val = optics.type;  % Should always be 'optics'
        
    case {'fnumber','f#'}
        % This is the f# assuming an object is infinitely far away.
        if rt
            if checkfields(optics,'rayTrace','fNumber')
                val = optics.rayTrace.fNumber;
            end
        else, val = optics.fNumber;
        end
    case {'model','opticsmodel'}
        if checkfields(optics,'model'), val = optics.model;
        else, val = 'diffractionLimited';
        end
        
        % The user can set 'Diffraction limited' but have
        % 'diffractionlimited' returned.
        val = ieParamFormat(val);
        
    case {'effectivefnumber','efffnumber','efff#'}
        % The f# if the object is not at infinity.
        if rt
            if checkfields(optics,'rayTrace','effectiveFNumber')
                val = optics.rayTrace.effectiveFNumber;
            end
        else
            val = opticsGet(optics,'fNumber')*(1 - opticsGet(optics,'mag'));
        end
    case {'focallength','flength'}
        % opticsGet(optics,'flength',units);
        if rt,  val = opticsGet(optics, 'RTeffectiveFocalLength');
        elseif strcmpi(opticsGet(optics,'model'),'skip')
            

            % I do not know what 'proper' distance means in these
            % comments. (BW).

            % Old comments
            % If you choose 'skip' because you want to treat the
            % optics/lens as a pinhole, you must have a scene and in
            % that case we use the proper distance (half the scene
            % distance). 
            % When you are just skipping to save time, you
            % may not have a scene.  In that case, use the optics
            % focal length.
            % End Old comments 
            %
            % Old code.  We used to send back the half the scene
            % distance.  ANd we never told the user what was
            % happening. 
            %
            % What we used to do (before March 17, 2022)
            %
            % if ~isempty(varargin), scene = varargin{1};
            % else, scene = vcGetObject('scene');
            % end
            % 
            % if isempty(scene), val = optics.focalLength;
            % else,              val = sceneGet(scene,'distance')/2;
            % end
            
            % New comments
            %
            % If this is a pinhole, then the focal length is how we
            % specify the distance to the image plane.  If it is not a
            % pinhole, here is the focal length.
            %
            % End new comments

            val = optics.focalLength;

        else, val = optics.focalLength;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'power','diopters'}
        % opticsGet(optics,'power','mm')
        % Diopters (1/m).
        % Sometimes we ask for a different unit when we don't want
        % diopters, but we want dist per deg in another unit.
        units = 'm';
        if ~isempty(varargin), units = varargin{1}; end
        val = 1/opticsGet(optics,'focallength',units);
        
    case {'imagedistance','focalplane','focalplanedistance'}
        % Lensmaker's equation calculation of distance from the center of a
        % thin lens to the sensor that brings the object in focus.  
        % 
        % If no object distance is provided, we assume infinite distance
        %
        % opticsGet(optics,'focalplane',sDist);    -- sDist is sourceDistance
        % opticsGet(optics,'focalplanedistance');  --   Infinite source dist
        
        % No need to check rt because focal length parameter checks,
        % returning RTeffectiveFocalLength.
        
        % What about 'skip' optics case?  Should 'focalLength' call set
        % this to 1/2 the object distance, which preserves the geometry?
        % (It does?  Not simply the object distance?)
        % ZLY: visited here. I think it can be focalLength, which is the
        % distance when the object is at infinity.  Should discuss with BW.
        if isequal(optics.model, 'skip')
            val = optics.focalLength;
            return;
        end
        fL = opticsGet(optics,'focal length');
        if isempty(varargin), sDist = Inf;
        else,                 sDist = varargin{1};
        end
        val = 1 / (1/fL - 1/sDist);   % Lens maker equation
        
        % These all need the scene field of view.  They can be computed
        % from the geometry of the image distance and FOV.
    case {'imageheight'}
        % opticsGet(optics,'imageheight',fov) -- field of view in degrees
        if isempty(varargin), disp('fov required.'); return;
        else
            fov = varargin{1};
            imageDistance = opticsGet(optics,'focal plane distance');
            val = 2*imageDistance*tan(deg2rad(fov/2));
            if length(varargin) < 2, return;
            else, val = ieUnitScaleFactor(varargin{2})*val;
            end
        end
        
    case {'imagewidth'}
        % opticsGet(optics,'imagewidth',fov) -- fov in degrees
        % opticsGet(optics,'imagewidth',fov,'mm') -- fov in degrees, output
        % units in mm
        if isempty(varargin), return;
        else
            fov = varargin{1};
            imageDistance = opticsGet(optics,'focalplanedistance');
            val = 2*imageDistance*tan(deg2rad(fov/2));
            if length(varargin) < 2, return;
            else, val = ieUnitScaleFactor(varargin{2})*val;
            end
        end
        
    case {'imagediagonal','diagonal'}
        % opticsGet(optics,'imagediagonal',fov)  -- fov in degrees
        if isempty(varargin), return;
        else
            fov = varargin{1};
            h = opticsGet(optics,'imageheight',fov,'m');
            w = opticsGet(optics,'imagewidth',fov,'m');
            val = sqrt(h^2 + w^2);
        end
        if length(varargin) < 2, return;
        else, val = ieUnitScaleFactor(varargin{2})*val;
        end
        
    case {'na','numericalaperture'}
        % Should this be a call to effective f#?
        val=1/(2*opticsGet(optics,'fnumber'));
    case {'aperturediameter','diameter','pupildiameter'}
        %These already check the rt condition, so no need to do it again
        val = opticsGet(optics,'focalLength')/opticsGet(optics,'fnumber');
        if ~isempty(varargin), val = ieUnitScaleFactor(varargin{1})*val; end
    case {'apertureradius','radius','pupilradius'}
        val = opticsGet(optics,'diameter')/2;
        if ~isempty(varargin), val = ieUnitScaleFactor(varargin{1})*val; end
    case {'aperturearea','pupilarea'}
        val = pi*((opticsGet(optics,'focalLength')/opticsGet(optics,'fnumber'))*(1/2))^2;
        if ~isempty(varargin), val = ieUnitScaleFactor(varargin{1})^2*val; end
        
    case {'magnification','mag'}
        % If the ray trace magnification is present, use that.  Otherwise
        % make a magnification estimate using the source distance and focal
        % length (via lensmaker equation).
        % opticsGet(optics,'mag',sDist) -- specify source distance
        % opticsGet(optics,'mag')       -- current source distance
        if rt
            val = opticsGet(optics,'rt magnification');
            return;
        end
        
        % Skip model has unit magnification, but still negative
        if strcmpi(opticsGet(optics,'model'),'skip')
            val = -1;
            return;
        elseif length(varargin) < 1
            scene = vcGetObject('scene');
            if ~isempty(scene),  sDist = sceneGet(scene,'distance');
            else
                % What should we do here?  No scene and no distance
                % specified.  Do we make the magnification 0?  Seems OK.
                val = 0;  return;
            end
        else
            sDist = varargin{1};
        end
        % Distance to the image divided by distance to the object (source)
        % http://en.wikipedia.org/wiki/Magnification
        % Also M = f / (f - distObj), where f is focal length of the lens
        % and distObj is the distance to the object.
        %
        % If you want the M to be -2, then
        %   -2*f + 2*distObj = f,
        %    2*distObj = 3*f
        %    distObj = 3f/2
        %
        % and in general distObj = (-M+1)f/(-M) * f
        val = -(opticsGet(optics,'focal Plane Distance',sDist))/sDist;
        
    case {'otf','otfdata','optical transfer function'}
        % You can ask for a particular wavelength with the syntax
        %    opticsGet(optics,'otfData',oi, spatialUnits, wave)
        %
        % OTF values can be complex. They are related to the PSF data by
        %    OTF(:,:,wave) = fft2(psf(:,:,wave))
        % For example, the PSF at 450 nm can be obtained via
        %    mesh(abs(fft2(opticsGet(optics,'otfdata',450))))
        %
        % We are having some issues on this point for shift-invariant and
        % diffraction limited models.  Apparently there is a problem with
        % fftshift???
        
        opticsModel = opticsGet(optics,'model');
        switch lower(opticsModel)
            case 'diffractionlimited'
                % For diffraction limited case, the call must be
                % otf = opticsGet(optics,'otf data',oi, fSupport, [wave]);
                
                if isempty(varargin)
                    error('opticsGet(optics,''otf data'',oi,fSupport,thisWave');
                end
                oi = varargin{1};
                if length(varargin) < 2, units = 'mm'; else, units = varargin{2}; end
                if length(varargin) < 3, thisWave = []; else, thisWave = varargin{3}; end
                
                % Could this be XXXXXX  and thus avoid the oi argument?
                %    opticsGet(optics,'dl fsupport',wave,unit,nSamp)
                fSupport = oiGet(oi,'fSupport',units);   % 'cycles/mm'
                % wavelength = oiGet(oi,'wave');
                
                % We don't store the OTF for diffraction limited. We
                % compute it on the fly.
                val = dlMTF(oi,fSupport,thisWave,units);
                return
                
            case 'shiftinvariant'
                % For the shift invariant case we store the OTF.
                % Ugly: the calling syntax for this model differs from the
                % calling syntax for diffraction limited.  We should fix!
                %
                %   opticsGet(optics,'otf data',thisWave);
                %
                if ~isempty(varargin), thisWave = varargin{1};
                else, thisWave = []; end
                
                if checkfields(optics,'OTF','OTF'), OTF = optics.OTF.OTF;
                else, val = []; return;  % No OTF found.
                end
                
                % A wavelength is specified
                if ~isempty(thisWave)
                    % If we have that wavelength, return it
                    [idx1,idx2] = ieWave2Index(opticsGet(optics,'otfWave'),thisWave);
                    if idx1 == idx2, val = OTF(:,:,idx1);
                    else
                        % Interpolate between wavelengths.  Not my favorite idea.
                        wave = opticsGet(optics,'otfwave');
                        w   = 1 - ((varargin{1} - wave(idx1))/(wave(idx2) - wave(idx1)));
                        val = (w*OTF(:,:,idx1) + (1-w)*OTF(:,:,idx2));
                        % wave(idx1),  varargin{1}, wave(idx2), w
                    end
                else
                    % No specified wavelength, so return the entire OTF
                    val = OTF;
                end
                
            case 'raytrace'
                error('opticsGet(optics,''OTF'') not supported for ray trace');
                
            otherwise
                error('OTFData not implemented for %s model',opticsModel);
        end
        
    case {'degreesperdistance','degperdist'}
        % opticsGet(optics,'deg per dist','mm')
        %
        % We use this constant to convert from the input spatial frequency units
        % (cycles/deg) to cycles/meter needed for the Hopkins eye. We need to
        % calculate this value from the optics data passed in.
        %
        % Given the power, D0, in units of 1/meters, the focal plane is
        % (1/D0) meters from the lens.  This is really just the focal
        % distance.  Call this the  adjacent edge of the right triangle
        % from the image plane to the lens.
        %
        % From geometry, 1 deg of visual angle has an opposite over
        % adjacent of
        %
        %   (opp/(1/D0)) = tand(1)
        %
        % So for 1 deg this is the distance (dist/deg)
        %   tand(1)*(1/D0)
        %
        % Finally, deg/distance is 1 / (tand(1)*(1/D0))
        %
        % The conversion is: (cycles/rad) * (rad/meter) = cycles/meter
        units = 'm';
        if ~isempty(varargin), units = varargin{1}; end
        D0 = opticsGet(optics,'power',units);
        val = (1/D0) * tand(1);     % deg/dist
        val = 1/val;
        
    case {'distperdeg','distanceperdegree'}
        units = 'm';
        if ~isempty(varargin), units = varargin{1}; end
        val = 1/opticsGet(optics,'deg per dist',units);
        
    case {'pupilmagnification','pupmag'}
        % Pupil magnification is the ratio of the exit pupil to the input
        % pupil (diameters)
        if rt
            % Needs to be checked more thoroughly!  Based on PC.
            efn = opticsGet(optics,'rteffectiveFnumber');
            fn = opticsGet(optics,'fnumber');
            val = (1/(1 - (efn/fn)))*opticsGet(optics,'rtmagnification');
        else, val = 1;
        end
        
    case {'transmittancescale','transmittance'}
        % opticsGet(optics,'transmittance',[wave])
        %
        % The lens transmittance, potentially interpolated or event
        % extrapolated to the requested wavelength samples
        
        % Stored
        val = optics.transmittance.scale;
        
        % If wavelength samples are requested ... always a column
        if ~isempty(varargin)
            newWave = varargin{1};
            wave = optics.transmittance.wave;
            scale = optics.transmittance.scale;
            
            if min(newWave(:))< min(wave(:)) || max(newWave(:)) > max(wave(:))
                % Extrapolation required.
                disp('Extrapolating lens transmittance with 1''s')
                val = interp1(wave,scale,newWave,'linear',1)';
            else
                val = interp1(wave,scale,newWave,'linear')';
            end
        end
        
    case {'transmittancewave'}
        % opticsGet(optics,'transmittance wave')
        %
        % Wavelength samples for the lens transmittance function.
        % Typically, these are set and stored once.  When the transmittance
        % is requested for different wavelengths, we interpolate as above.
        val = optics.transmittance.wave;
        
    case {'transmittancenwave'}
        % Number of lens transmittance wavelength samples stored
        val = length(optics.transmittance.wave);
        
        % ----- Diffraction limited parameters
    case {'dlfsupport','dlfsupportmatrix'}
        % Two different return formats.  Either
        %  val{1} and val{2} as vectors, or
        %  val  = fSupport(:,:,:);
        % opticsGet(optics,'dl fsupport',wave,unit,nSamp)
        % opticsGet(optics,'dl fsupport matrix',wave,unit,nSamp)
        %
        % Diffraction limited frequency support at a wavelength (i.e.
        % support out to the incoherent cutoff frequency).  This can be
        % used for plotting, for example.
        
        if length(varargin) < 1, error('Must specify wavelength'); else, thisWave = varargin{1}; end
        if length(varargin) < 2, units = 'mm'; else, units = varargin{2}; end
        if length(varargin) < 3, nSamp = 30; else, nSamp = varargin{3}; end
        
        % Sometimes the optics wavelength hasn't been defined because, say,
        % we haven't run through a scene.  So we trap that case here.
        waveList = opticsGet(optics,'wavelength');
        idx  = ieFindWaveIndex(waveList,thisWave);
        inCutoff = opticsGet(optics,'inCutoff',units);
        inCutoff = inCutoff(idx);
        
        % There are 2*nSamp frequencies out from +/- the incoherent cutoff
        % frequency for this diffraction limited optics.
        fSamp = (-nSamp:(nSamp-1))/(nSamp);
        val{1} = fSamp*inCutoff;
        val{2} = fSamp*inCutoff;
        
        % Alternative return format
        if ieContains(parm,'matrix')
            [valMatrix(:,:,1),valMatrix(:,:,2)] = meshgrid(val{1},val{2});
            val = valMatrix;
        end
        
    case {'incoherentcutoffspatialfrequency','incutfreq','incutoff'}
        % cycles/distance
        % Cutoff spatial frequency for a diffraction limited lens.  See
        % formulae in dlCore.m
        apertureDiameter = opticsGet(optics,'aperturediameter');
        imageDistance    = opticsGet(optics,'focalplanedistance');
        wavelength       = opticsGet(optics,'wavelength','meters');
        
        % Sometimes the optics wavelength have not been assigned because
        % there is no scene and no oiCompute has been run.  So, we can just
        % choose a sample set.
        if isempty(wavelength), wavelength = (400:10:700)*10^-9; end
        
        % See dlCore.m for a description of the formula.  We divide by the
        % scale factor, instead of multiplying, because these are
        % frequencies (1/m), not distances.
        val = (apertureDiameter / imageDistance) ./ wavelength;
        if ~isempty(varargin), val = val/ieUnitScaleFactor(varargin{1}); end
        
    case {'maxincoherentcutoffspatialfrequency','maxincutfreq','maxincutoff'}
        % Used particularly for calculating diffraction-limited OTF
        %   opticsGet(optics,'maxincutoff','m')
        %   opticsGet(optics,'maxincutoff')
        if isempty(varargin), val = max(opticsGet(optics,'incutoff'));
        else, val = max(opticsGet(optics,'incutoff',varargin{1}));
        end
        
        % -------   OTF information and specifications.
        %
        % Th shift-invariant calculations (including diffraction limited
        % human, and custom shift-invariant) use OTF information.  The
        % diffraction-limited case computes the OTF on the fly.  The other
        % cases store the OTF in the slots optics.OTF.[OTF,fx,fy].  The
        % stored units of the fx and fy are cycles/mm.
        %
        % The ray trace structures below are used for non shift-invariant
        % cases derived from Zemax or Code V data sets.
        
    case {'otfsupport','otfsupportmatrix'}
        % val = opticsGet(optics,'otf support','mm');
        %
        % Row and col (Y,X) spatial frequency range for the OTF data [Y,X].
        % The return can either be as vectors or if you ask for the matrix
        % form then returned as fSupport(:,:,1) for X and fSupport(:,:,2)
        % for Y.
        %
        %     [val.X,val.Y] = meshgrid(val.fy,val.fx)
        %
        %
        % Frequency is stored in non-standard units of cycles/mm. This will
        % be annoying to fix some day, sigh.
        units = 'mm';
        if ~isempty(varargin), units = varargin{1}; end
        val.fy = opticsGet(optics,'otf fy',units);
        val.fx = opticsGet(optics,'otf fx',units);
        
        % If called with matrix, then
        if ieContains(parm,'matrix') %#ok<*STRIFCND>
            [X,Y] = meshgrid(val.fy,val.fx); % Not sure about order yet!
            fSupport(:,:,1) = X; fSupport(:,:,2) = Y;
            val = fSupport;
        end
        
    case {'otffx'}
        % cycles/mm!!! Non-standard unit.  Must fix up some day.
        if checkfields(optics,'OTF','fx'), val = optics.OTF.fx; end
        % Put into meters and then apply scale factor
        if ~isempty(varargin), val = (val*1e+3)/ieUnitScaleFactor(varargin{1}); end
    case {'otffy'}
        % cycles/mm!!! Non-standard unit.  Must fix up some day.
        if checkfields(optics,'OTF','fy'), val= optics.OTF.fy; end
        % Put into meters and then apply scale factor
        if ~isempty(varargin), val = (val*1e+3)/ieUnitScaleFactor(varargin{1}); end
    case {'otfsize'}
        % Row and col samples
        if checkfields(optics,'OTF','OTF')
            tmp = size(optics.OTF.OTF); val = tmp(1:2);
        end
        
    case {'otfwave','otfwavelength','wave','wavelength'}
        % opticsGet(optics,'otf wave','nm');
        % nm is the default.
        % The optics has several functions that are wavelength dependent.
        % If the optics is diffraction limited, and no
        if checkfields(optics,'OTF','wave'), val = optics.OTF.wave;
        else, val = 400:10:700;
        end
        if ~isempty(varargin)
            units = varargin{1};
            val = val*1e-9*ieUnitScaleFactor(units);
        end
        
    case {'otfbinwidth'}
        % Bin width of the otf wavelength samples
        otfWave = opticsGet(optics,'otfWave');
        if length(otfWave)>1, val = otfWave(2) - otfWave(1);
        else, val = 1;
        end
        
    case {'otfnwave'}
        % Number of wavelength samples in OTF representation
        % When the rep is just a function (dlmtf) we return 31 by default
        val = length(opticsGet(optics,'otf wave'));
        
        % PSF related.  Mainly ised for plotting.  Computations go through
        % the OTF.
    case {'psfdata'}
        % psf = opticsGet(optics,'psf data',thisWave,units,nSamp);
        % Pointspread function data at a wavelength in specific units
        % The DL case and SI cases are handled differently.
        thisWave = opticsGet(optics,'wave'); units = 'um'; nSamp = 25;
        
        if length(varargin) >= 1, thisWave = varargin{1}; end
        if length(varargin) >= 2, units = varargin{2}; end
        if length(varargin) >= 3, nSamp = varargin{3}; end
        
        oModel = opticsGet(optics,'model');
        switch lower(oModel)
            case 'diffractionlimited'
                % opticsGet(optics,'psf Data',thisWave,'um');
                fSupport = opticsGet(optics,'dlFSupport matrix',thisWave(1),units,nSamp);
                
                % This increases the spatial frequency resolution (highest
                % spatial frequency) by a factor of 4, which yields a
                % higher spatial resolution estimate
                fSupport = fSupport*4;
                
                % Calculate the OTF using diffraction limited MTF (dlMTF)
                otf = dlMTF(optics,fSupport,thisWave,units);
                
                % Diffraction limited OTF
                if length(thisWave) == 1
                    psf = fftshift(ifft2(otf));
                    psf = abs(psf);
                else
                    psf = zeros(size(otf));
                    for ii=1:length(thisWave)
                        psf(:,:,ii) = fftshift(ifft2(otf(:,:,ii)));
                    end
                end
                sSupport = opticsGet(optics,'psf support',fSupport, nSamp);
                
            case 'shiftinvariant'
                % val = opticsGet(optics,'psf data',thisWave,'um');
                % What do we do about the units???  The OTF values are
                % generated at 0.25 micron spacing of the psf, I think.
                if checkfields(optics,'OTF','OTF')
                    otfWave = opticsGet(optics,'otf wave');
                    if ~isempty(varargin)
                        % Just at the interpolated wavelength
                        thisWave = varargin{1};
                        otf = opticsGet(optics,'otf data',thisWave);
                        % mesh(fftshift(otf))
                        psf = fftshift(ifft2(otf));
                        % mesh(abs(psf))
                    else
                        % All of them
                        psf = zeros(size(optics.OTF.OTF));
                        for ii=1:length(otfWave)
                            psf(:,:,ii) = fftshift(ifft2(optics.OTF.OTF(:,:,ii)));
                        end
                    end
                    
                    % We need to figure out the spatial sampling of the psf
                    % now.
                    nSamps = size(psf,1)/2;
                    fSupport = opticsGet(optics,'otf fx',units);
                    sSupport = opticsGet(optics,'psf support',fSupport,nSamps);
                    
                    % This is an error check in a way.
                    if ~isreal(val)
                        warning('ISET:complexpsf','complex psf');
                        psf = abs(psf);
                    end
                else
                    % Another error check
                    warning('ISET:otfdata','No OTF data stored in optics.')
                end
        end
        val.psf = psf;
        val.xy  = sSupport;
        
    case {'psfspacing'}
        % opticsGet(optics,'psf spacing',[fx])
        %
        % Sample spacing of the psf points.  These are handled differently
        % for diffraction and shift invariant cases.
        %
        % The units are always 1/units of the fx terms.  So, if these are
        % cyc/um then the spacing is um.
        %
        % By default, the OTF.fx units are cyc/mm, so we get mm if no fx is
        % specified for the shift invariant case.  The fx has to be
        % specified for the diffraction limited case because they are not
        % stored anywhere.
        
        oModel = opticsGet(optics,'model');
        switch oModel
            case 'diffractionlimited'
                % No fx value is stored in this case.
                % User must supply the peak
                if isempty(varargin)
                    warning('Diffraction limited psf support requires peak f');
                else
                    fx = varargin{1};
                end
            case 'shiftinvariant'
                % Use the stored fx values
                % Warning:  We are assuming that fx and fy have the same peak
                % spatial frequency and spatial sampling.
                % The fx values are stored in cyc/mm by default.  Unusual
                % and should be fixed.  If the fx is sent in with different
                % units, then the spacing is in those units.
                if length(varargin) >= 1, fx = varargin{1};
                else,  fx = opticsGet(optics,'otf fx');
                end
            otherwise
                
        end
        
        % Trap this error possibility.
        if isempty(fx), error('No otffx calculated yet. Fix me.'); end
        
        % Peak frequency in cycles/meter.  1/peakF is meters.  We have two
        % samples in that distance, so the sample spacing is half that
        % distance.
        peakF = max(fx(:));
        val = 1/(2*peakF);
        
    case {'psfsupport'}
        % opticsGet(optics,'psf support',fSupport, nSamps)
        %
        % Returns mesh grid of X and Y values.  But maybe we should check
        % the behavior and return the vector and matrix forms on request.
        %
        
        if length(varargin) < 2, error('fSupport and nSamps required.'); end
        fSupport = varargin{1};
        nSamp    = varargin{2};
        
        % Frequency units are cycles/micron. The spatial frequency support
        % runs from -Nyquist:Nyquist. With this support, the Nyquist
        % frequency is actually the highest (peak) frequency value. There
        % are two samples per Nyquist, so the sample spacing is 1/(2*peakF)
        samp = (-nSamp:(nSamp-1));
        [X,Y] = meshgrid(samp,samp);
        
        % Same as opticsGet(optics,'psf spacing',peakF);
        %         peakF = max(fSupport(:));
        %         deltaSpace = 1/(2*peakF);
        deltaSpace = opticsGet(optics,'psf spacing',fSupport);
        val(:,:,1) = X*deltaSpace;
        val(:,:,2) = Y*deltaSpace;
        
        %----------- Relative illumination (off-axis) specifications
    case {'offaxis','offaxismethod','relativeilluminationtype'}
        % This is the method used to compute relative illumination. It can
        % be 'Skip','cos4th'.  State is shown in the window by a switch.
        val = optics.offaxis;
    case {'cos4thmethod','cos4thfunction'}
        % We have only used cos4th as an offaxis method. In that case, the
        % function that implements cos4th can be stored here.  I suspect
        % this extra step is not needed. We have a cos4th function and we
        % use that without allowing some other implementation.  It is here
        % only for some old backwards compatibility.
        %
        % Do not run cos4th when you are using the Code V (or probably
        % Zemax methods.  These calculations include the relative
        % illumination as part of the lens calculations.
        if checkfields(optics,'cos4th','function'), val = optics.cos4th.function; end
    case {'cos4th','cos4thdata','cos4thvalue'}
        % Numerical values.  Should change field to data from value.  I
        % don't think this is ever used, is it?
        if checkfields(optics,'cos4th','value'), val = optics.cos4th.value; end
        
        % ---------------  Ray Trace information.
        % The ray trace computations differ from those above because they
        % are not shift-invariant.  When we use a custom PSF/OTF that is
        % shift invariant, we still store the information in the main
        % optics code region in the OTF structure.
    case {'raytrace','rt',}
        if checkfields(optics,'rayTrace'), val = optics.rayTrace; end
    case {'rtname'}
        if checkfields(optics,'rayTrace','name'), val = optics.rayTrace.name; end
    case {'opticsprogram','rtopticsprogram'}
        if checkfields(optics,'rayTrace','program'), val = optics.rayTrace.program; end
    case {'lensfile','rtlensfile'}
        if checkfields(optics,'rayTrace','lensFile'), val = optics.rayTrace.lensFile;end
        
    case {'rteffectivefnumber','rtefff#'}
        if checkfields(optics,'rayTrace','effectiveFNumber'), val = optics.rayTrace.effectiveFNumber;end
    case {'rtfnumber'}
        if checkfields(optics,'rayTrace','fNumber'), val = optics.rayTrace.fNumber;end
    case {'rtmagnification','rtmag'}
        if checkfields(optics,'rayTrace','mag'), val = optics.rayTrace.mag; end
    case {'rtreferencewavelength','rtrefwave'}
        if checkfields(optics,'rayTrace','referenceWavelength'), val = optics.rayTrace.referenceWavelength;end
    case {'rtobjectdistance','rtobjdist','rtrefobjdist','rtreferenceobjectdistance'}
        if checkfields(optics,'rayTrace','objectDistance')
            % These are stored in mm because, well, optics. We convert to
            % meters and then apply the scale factor.  This way the return
            % is always meters
            val = optics.rayTrace.objectDistance/1000;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'rtfov'}
        % Maximum field of view for the ray trace calculation (not
        % the computed image).
        %
        % The stored value is half the maximum diagonal.  The max
        % horizontal is the same.  The FOV (whatever direction) is as far
        % as the PSF is computed by Zemax. It doesn't matter whether it is
        % measured along the diagonal or the horizontal.
        if checkfields(optics,'rayTrace','fov'), val = optics.rayTrace.fov; end
    case {'rteffectivefocallength','rtefl','rteffectivefl'}
        % TODO:  These are stored in mm, because of, well, optics.
        if checkfields(optics,'rayTrace','effectiveFocalLength')
            val = optics.rayTrace.effectiveFocalLength/1000;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'rtpsf'}
        if checkfields(optics,'rayTrace','psf'), val = optics.rayTrace.psf; end
    case {'rtpsffunction','rtpsfdata'}
        % Return the psf - either the whole thing or a selected psf
        % Data are stored as 4D (row,col,fieldHeight,wavelength) images
        if checkfields(optics,'rayTrace','psf','function')
            if ~isempty(varargin)
                % Return the psf at a particular field height and wavelength
                % The units of the field height are meters and nanometers
                % for wavelength
                % psf = opticsGet(optics,'rtpsfdata',fieldHeight,wavelength);
                % Delete this warning after January 2009 (warning commented
                % out April 2011)
                % if varargin{1} > .1, warndlg('Suspiciously large field height (> 0.1m)'); end
                fhIdx   = ieFieldHeight2Index(opticsGet(optics,'rtPSFfieldHeight'),varargin{1});
                waveIdx = ieWave2Index(opticsGet(optics,'rtpsfwavelength'),varargin{2});
                val = optics.rayTrace.psf.function(:,:,fhIdx,waveIdx);
            else
                % Return the entire psf data
                % psfFunction = opticsGet(optics,'rtpsfdata');
                val = optics.rayTrace.psf.function;
            end
        end
    case {'rtpsfsize','rtpsfdimensions'}
        % psfSize = opticsGet(optics,'rtPsfSize')
        if checkfields(optics,'rayTrace','psf','function')
            % All 4 dimensions, in the order row,col,fieldnum,wavelength
            val = size(optics.rayTrace.psf.function);
        end
    case {'rtpsfwavelength'}
        if checkfields(optics,'rayTrace','psf','wavelength'), val = optics.rayTrace.psf.wavelength; end
    case {'rtpsffieldheight'}
        % opticsGet(optics,'rt psf field height','um')
        % Stored in mm. Returned in the requested units.
        if checkfields(optics,'rayTrace','psf','fieldHeight')
            val = optics.rayTrace.psf.fieldHeight/1000;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'rtpsfsamplespacing','rtpsfspacing'}
        % opticsGet(optics,'rtPsfSpacing','um')
        if checkfields(optics,'rayTrace','psf','sampleSpacing')
            % The 1000 is necessary because it is stored in mm
            val = optics.rayTrace.psf.sampleSpacing/1000;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
    case {'rtsupport','rtpsfsupport'}
        % Return the (x,y) positions of the PSF samples.
        % This list always contains a sample at 0
        % For a 2^n (e.g., 64,64) grid, Code V puts the zero point at 2^n - 1 (e.g., 33,33)
        % s = opticsGet(optics,'rtPsfSupport','um');
        psfSize = opticsGet(optics,'rtPSFSize');
        if isempty(varargin), units = 'm'; else, units = varargin{1}; end
        psfSpacing = opticsGet(optics,'rtPsfSpacing',units);
        colPsfPos = (((-psfSize(2)/2)+1):(psfSize(2)/2))*psfSpacing(2);
        rowPsfPos = (((-psfSize(1)/2)+1):(psfSize(1)/2))*psfSpacing(1);
        [xPSF,yPSF] = meshgrid(colPsfPos,rowPsfPos);
        val(:,:,1) = xPSF;
        val(:,:,2) = yPSF;
    case {'rtpsfsupportrow','rtpsfsupporty'}
        psfSize = opticsGet(optics,'rtPSFSize');
        if isempty(varargin), units = 'm'; else, units = varargin{1}; end
        psfSpacing = opticsGet(optics,'rtPsfSpacing',units);
        val = (((-psfSize(1)/2)+1):(psfSize(1)/2))*psfSpacing(1);
        % Useful to be a column for interpolation.  Maybe they should
        % always be columns?
        val = val(:);
        
    case {'rtpsfsupportcol','rtpsfsupportx'}
        psfSize = opticsGet(optics,'rtPSFSize');
        if isempty(varargin), units = 'm'; else, units = varargin{1}; end
        psfSpacing = opticsGet(optics,'rtPsfSpacing',units);
        val = (((-psfSize(2)/2)+1):(psfSize(2)/2))*psfSpacing(2);
        % Useful to be a row for interpolation.  But maybe it should always
        % be a column?
        val = val(:)';
    case {'rtfreqsupportcol','rtfreqsupportx'}
        % Calculate the frequency support across the column dimension
        % opticsGet(optics,'rtFreqSupportX','mm')
        if isempty(varargin), units = 'm'; else, units = varargin{1}; end
        psfSpacing = opticsGet(optics,'rtPsfSpacing',units);
        sz = opticsGet(optics,'rtPsfSize',units);
        val = (((-sz(2)/2)+1):(sz(2)/2))*(1/(sz(2)*psfSpacing(2)));
        val = val(:)';
    case {'rtfreqsupportrow','rtfreqsupporty'}
        % Calculate the frequency support across the column dimension
        % opticsGet(optics,'rtFreqSupportX','mm')
        if isempty(varargin), units = 'm'; else, units = varargin{1}; end
        psfSpacing = opticsGet(optics,'rtPsfSpacing',units);
        sz = opticsGet(optics,'rtPsfSize',units);
        val = (((-sz(1)/2)+1):(sz(1)/2))*(1/(sz(1)*psfSpacing(1)));
        val = val(:);
    case {'rtfreqsupport'}
        % val = opticsGet(optics,'rtFreqSupport','mm');
        if isempty(varargin), units = 'mm'; else, units = varargin{1}; end
        val{1} = opticsGet(optics,'rtFreqSupportX',units);
        val{2} = opticsGet(optics,'rtFreqSupportY',units);
    case {'rtrelillum'}
        % The sample spacing on this is given below in rtrifieldheight
        if checkfields(optics,'rayTrace','relIllum'), val = optics.rayTrace.relIllum; end
    case {'rtrifunction','rtrelativeilluminationfunction','rtrelillumfunction'}
        if checkfields(optics,'rayTrace','relIllum','function')
            val = optics.rayTrace.relIllum.function;
        end
    case {'rtriwavelength','rtrelativeilluminationwavelength'}
        if checkfields(optics,'rayTrace','relIllum','wavelength')
            val = optics.rayTrace.relIllum.wavelength;
        end
    case {'rtrifieldheight','rtrelativeilluminationfieldheight'}
        % TODO:  These are stored in mm, I believe.  Could change to m
        if checkfields(optics,'rayTrace','relIllum','fieldHeight')
            val = optics.rayTrace.relIllum.fieldHeight/1000;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'rtgeometry'}
        if checkfields(optics,'rayTrace','geometry'), val = optics.rayTrace.geometry; end
    case {'rtgeomfunction','rtgeometryfunction','rtdistortionfunction','rtgeomdistortion'}
        % opticsGet(optics,'rtDistortionFunction',wavelength,'units');
        if checkfields(optics,'rayTrace','geometry','function')
            % opticsGet(optics,'rtGeomFunction',[],'mm')
            % opticsGet(.,.,500,'um')  % 500 nm returned in microns
            % opticsGet(.,.)           % Whole function in meters
            % opticsGet(optics,'rtgeomfunction',500) % Meters
            if isempty(varargin)
                % Return the whole function units are millimeters
                val = optics.rayTrace.geometry.function;
                return;
            else
                % Return values at a specific wavelength
                if ~isempty(varargin{1})
                    idx = ieWave2Index(opticsGet(optics,'rtgeomwavelength'),varargin{1});
                    val = optics.rayTrace.geometry.function(:,idx);
                else
                    val = optics.rayTrace.geometry.function;
                end
            end
            
            % Stored in millimeters. Convert to meters.
            val = val/1000;
            % If there is a second varargin, it specifieds the units.
            if length(varargin) == 2
                val = val*ieUnitScaleFactor(varargin{2});
            end
        end
        
    case {'rtgeomwavelength','rtgeometrywavelength'}
        % The wavelength used for ray trace geometry distortions.
        % The units is nanometers
        if checkfields(optics,'rayTrace','geometry','wavelength')
            val = optics.rayTrace.geometry.wavelength;
        end
    case {'rtgeomfieldheight','rtgeometryfieldheight'}
        % val = opticsGet(optics,'rtGeomFieldHeight','mm');
        % These are stored in mm because of Zemax.  So we divide by 1000 to
        % put the value into meters and then convert to the user's
        % requested units.
        if checkfields(optics,'rayTrace','geometry','fieldHeight')
            % Convert from mm to meters
            val = optics.rayTrace.geometry.fieldHeight/1000;
        end
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'rtgeommaxfieldheight','rtmaximumfieldheight','rtmaxfieldheight'}
        % val = opticsGet(optics,'rtGeomMaxFieldHeight','mm');
        % The maximum field height.
        fh = opticsGet(optics,'rtgeometryfieldheight');  % Returned in meters
        val = max(fh(:));
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'rtcomputespacing'}
        % Spacing of the point spread function samples.
        % Is this really stored in meters, not millimeters like other
        % rt data.   Sigh.
        if checkfields(optics,'rayTrace','computation','psfSpacing')
            val = optics.rayTrace.computation.psfSpacing;
            if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        end
        
    otherwise
        error('Unknown optics parameter.');
        
end

end
