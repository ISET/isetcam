function val = wvfGet(wvf,parm,varargin)
% Get wavefront structure parameters and derived properties
%
%    val = wvfGet(wvf,parm,varargin)
%
% Wavefront properties are either stored as parameters or computed from
% those parameters. We generally store only unique values and  calculate
% all derived values.
%
%  A '*' indicates that the syntax wvfGet(wvf,param,unit) can be used, where
%  unit specifies the spatial scale of the returned value:
%
%    length: 'm', 'cm', 'mm','um', 'nm'.
%    angle: 'deg', 'min', 'sec'
%
%  The wavefront to psf calculations are fundamentally performed in angular
%  units.  The conversion here to spatial units is done assumming .33 mm
%  per degree, which is a reasonable number for the human eye.  At some
%  future date this should stop being hardcoded and be inherited from an
%  optics structure to which the wavefront object is attached.
%
%  A leading '+ indicates that this is a get only parameter and may not be
%  set.
%
% Parameters:
%
%  Bookkeeping
%   'name' - Name of this object
%   'type' - Type of this object, should always be 'wvf'
%
%  Spatial sampling parameters
%    'sample interval domain' - Which domain has sample interval held constant with wavelength ('psf', 'pupil')
%    'number spatial samples' - Number of spatial samples (pixel) for pupil function and psf
%    'ref pupil plane size' - Size of sampled pupil plane at measurement wavelength (mm,*)
%    'ref pupil plane sample interval' - Pixel sample interval in pupil plane at measurement wavelength (mm,*)
%    'ref psf sample interval' - Sampling interval for psf at measurment wavelength (arcminute/pixel)
%  + 'pupil plane size' - Size of sampled pupil plane at any calculated wavelength(s) (mm)
%  + 'psf arcmin per sample' - Sampling interval for psf at any calculated wavelength(s) (min/pixel)
%  + 'psf angle per sample' - Sampling interval for psf at any calculated wavelength(s) (min,*/pixel)
%  + 'psf angular samples' - One-d slice of sampled angles for psf, centered on 0, for a single wavelength (min,*)
%  + 'psf spatial samples' - One-d slice of sampled psf in spatial units, centered on 0 for a single wavelength (*)
%  + 'pupil spatial samples' - One-d slice of sampled pupil function in spatial units, centered on 0 for a single wavelength (*)
%  + 'middle row' - The middle row of sampled functions
%
%  Calculation parameters
%     'zcoeffs'     - Zernike polynomial coefficients
%     'pupil diameter'  - Pupil size for calculation (mm,*)
%     'wavelengths' - Wavelengths to calculate over (nm,*)
%
% Pupil and pointspread function
%  +  'wavefront aberrations' - The wavefront aberrations in microns.  Must call wvfComputePupilFunction on wvf before get (um)
%  +  'pupil function' - The pupil function.  Must call wvfComputePupilFunction on wvf before get.
%  +  'psf' - Point spread function.  Must call wvfComputePSF on wvf before get
%  +  'psf centered' - Peak of PSF is at center of returned matrix
%  +  '1d psf' - One dimensional horizontal (along row) slice through PSF centered on its max
%  +  'diffraction psf' - Diffraction limite PSF
%  +  'cone psf' - PSF as seen by cones for given weighting spectrum.
%
% Need to be implemented/checked/documented
%  +  'distanceperpix'
%  +  'samplesspace'
%  +  'strehl'     - Ratio of peak of diffraction limited to actual
%
% Examples:
% * Compute diffraction limited psf
%   wvfP = wvfCreate;
%   wvfP = wvfComputePSF(wvfP);
%   vcNewGraphWin; wvfPlot(wvfP,'image psf','um',550);
%
%   psf = wvfGet(wvfP,'diffraction psf',550); vcNewGraphWin; mesh(psf)
%
% * Strehl is ratio of diffraction and current
%   wvfP = wvfComputePSF(wvfP); wvfGet(wvfP,'strehl',550)
%
% * Blur and recompute.  4th coefficient is defocus
%   z = wvfGet(wvfP,'zcoeffs');z(4) = 0.3; wvfP = wvfSet(wvfP,'zcoeffs',z);
%   wvfP = wvfComputePSF(wvfP); wvfGet(wvfP,'strehl',550)
%
%   wvf = wvfCreate; wvf = wvfComputePSF(wvf); 
%   otf = wvfGet(wvf,'otf'); f = wvfGet(wvf,'otf support','mm');
%   vcNewGraphWin; mesh(f,f,otf);
%
%   lsf = wvfGet(wvf,'lsf'); x = wvfGet(wvf,'lsf support','mm');
%   vcNewGraphWin; plot(x,lsf);
%
% See also: wvfSet, wvfCreate, wvfComputePupilFunction, wvfComputePSF,
% sceCreate, sceGet
%
% (c) Wavefront Toolbox Team 2011, 2012

if ~exist('parm','var') || isempty(parm), error('Parameter must be defined.'); end

% Default is empty when the parameter is not yet defined.
% val = [];

parm = ieParamFormat(parm);

%% We will subdivide the gets over time
%  We plan to create get functions, such as wvfpsfGet(), or wvfsceGet, to
%  introduce some more order.  We will modify ieParameterOtype to help with
%  this.
%
switch parm
    %% Book-keeping
    case 'name'
        val = wvf.name;
    case 'type'
        val = wvf.type; 
    
        %% Pupil plane properties
        %
        % The Zernike coefficients define the wavefront aberrations in the
        % pupil plane.  Various quantities are derived from this.
        %
        % This group contains many parameters related to the pupil
        % functions
    case {'zcoeffs','zcoeff','zcoef'}
        % Zernike coeffs
        % wvfGet(wvf,'zcoeffs',idx);
        % idx is optional, and can be a vector of j values
        % or a string array of coefficient names (see wvfOSAIndexToVectorIndex).
        % Note that j values start at 0, and that is the convention followed
        % here.  If idx is passed, the length of val matches that of idx.
        % And, it is an error if you try to get a coefficient that has not
        % been set.
        if (isempty(varargin))
            val = wvf.zcoeffs;
        else
            idx = wvfOSAIndexToVectorIndex(varargin{1});
            tempcoeffs = wvf.zcoeffs;
            maxidx = max(idx);
            if (maxidx > length(wvf.zcoeffs))
                tempcoeffs(length(tempcoeffs)+1:maxidx) = 0;
            end
            val = tempcoeffs(idx);
        end
       case {'wavefrontaberrations'}
        % The wavefront aberrations are derived from Zernike coefficients
        % in the routine wvfComputePupilFunction
        % 
        % If there are multiple wavelengths, then this is a cell array of
        % matrices wvfGet(wvf,'wavefront aberrations',wList) This comes
        % back in microns, and if I were a better person I would have
        % provided unit passing and conversion.
        
        % Can't do the get unless it has already been computed and is not stale.
        if (~isfield(wvf,'pupilfunc'))
            error('Must compute wavefront aberrations before getting them.  Use wvfComputePupilFunction or wvfComputePSF.');
        end
        
        % Return whole cell array of wavefront aberrations over wavelength if
        % no argument passed.  If there is just one wavelength, we
        % return the .wavefront aberrations as a matrix, rather than as a cell
        % array with one entry.
        if isempty(varargin)
            if (length(wvf.wavefrontaberrations) == 1)
                val = wvf.wavefrontaberrations{1};
            else
                val = wvf.wavefrontaberrations;
            end
        else
            wList = varargin{1}; idx = wvfWave2idx(wvf,wList);
            nWave = wvfGet(wvf,'nwave');
            if idx > nWave, error('idx (%d) > nWave',idx,nWave);
            else, val = wvf.wavefrontaberrations{idx};
            end
        end
        
    case {'pupilfunction','pupilfunc','pupfun'}
        % The pupil function is derived from Zernike coefficients in the
        % routine wvfComputePupilFunction 
        %
        % If there are multiple wavelengths, then this is a cell array of
        % matrices
        %   wvfGet(wvf,'pupilfunc',wList)
        
        % Can't do the get unless it has already been computed and is not
        % stale.
        if (~isfield(wvf,'pupilfunc'))
            error('Must compute pupil function before getting it.  Use wvfComputePupilFunction or wvfComputePSF.');
        end
        
        % Return whole cell array of pupil functions over wavelength if
        % no argument passed.  If there is just one wavelength, we
        % return the pupil function as a matrix, rather than as a cell
        % array with one entry.
        if isempty(varargin)
            if (length(wvf.pupilfunc) == 1)
                val = wvf.pupilfunc{1};
            else
                val = wvf.pupilfunc;
            end
        else
            wList = varargin{1}; idx = wvfWave2idx(wvf,wList);
            nWave = wvfGet(wvf,'nwave');
            if idx > nWave, error('idx (%d) > nWave',idx,nWave);
            else, val = wvf.pupilfunc{idx};
            end
        end
        
        
        %% Spatial sampling parameters related to ...
        %
        % Say more here
    case {'sampleintervaldomain'}
        % What's held constant with calculated wavelength.
        % Choices are 'psf' and 'pupil'
        % This really needs a better explanation.  It has to do with
        % accounting for the index of refraction, undoubtedly.
        val = wvf.constantSampleIntervalDomain;
        
    case {'numberspatialsamples','nsamples','spatialsamples', 'npixels', 'fieldsizepixels'}
        % Number of pixels for both the pupil and psf planes
        % discretization This is a master value - which means that this is
        % the finest resolution.  
        % Why are there both psf and pupil plane spatial samples?
        % Something about the index of refraction for the separation, but
        % not for the number ...
        val = wvf.nSpatialSamples;
        
        % This reference plane concept what is it? Describe here! BW
    case {'refpupilplanesize', 'refpupilplanesizemm', 'fieldsizemm'}
        % Total size of computed field in pupil plane.  This is for the
        % measurement wavelength and sets the scale for calculations at
        % other wavelengths.
        %
        val = wvf.refSizeOfFieldMM;
        if ~isempty(varargin)
            val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'refpupilplanesampleinterval', 'refpupilplanesampleintervalmm', 'fieldsamplesize', 'fieldsamplesizemmperpixel'}
        % Pixel sample interval of sample pupil field. This is for the measurement
        % wavelength and sets the scale for calculations at other
        % wavelengths.  
        % Shouldn't this have measured in the title?
        val = wvf.refSizeOfFieldMM/wvf.nSpatialSamples;
        if ~isempty(varargin)
            val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'refpsfsampleinterval' 'refpsfarcminpersample', 'refpsfarcminperpixel'}
        % Arc minutes per pixel of the sampled psf at the measurement
        % wavelength.  This is for the measurement
        % wavelength and sets the scale for calculations at other
        % wavelengths.
        radiansPerPixel = wvfGet(wvf,'measured wl','mm')/wvfGet(wvf,'ref pupil plane size','mm');
        val = (180*60/3.1416)*radiansPerPixel;
        
         
        %% Calculation parameters
        % The calculation can take place at different wavelengths and pupil
        % diameters than the measurement.  The settings for the calculation
        % are below here, I think.  These should have calc in the title, I
        % think.
        %
        case {'pupilplanesize', 'pupilplanesizemm'}
        % wvfGet(wvf,'pupil plane size',units,wList)
        %
        % Size of computed field in pupil plane, for calculated
        % wavelengths(s)
        
        % Get wavelengths.  What if varargin{2} is empty?
        if length(varargin) < 2
            error('Wavelength required for pupil plane size in mm');
        else
            wList = varargin{2};
            waveIdx = wvfWave2idx(wvf,wList);
            wavelengths = wvfGet(wvf,'wavelengths','nm');
        end
        
        % Figure out what's being held constant with wavelength and act
        % appropriately.
        %
        % I don't understand the psf and pupil domain.  I guess it means
        % how many samples we have in which domain, at the pupil or the psf
        % might mean on the sensor domain?  It looks like we would do well
        % to always have samples in the pupil plane.  But that is not the
        % default in the toolbox.
        switch  wvfGet(wvf,'sample interval domain')
            case 'psf'
                % Seems to account for some measurement, which we don't
                % have. That is why we are in the other case.
                val = wvfGet(wvf,'ref pupil plane size','mm')*wavelengths(waveIdx)/wvfGet(wvf,'measured wl','nm');
            case 'pupil'
                % We are always using this one, these days.  Still, I don't
                % really understand (BW).
                val = wvfGet(wvf,'ref pupil plane size','mm')*ones(length(waveIdx),1);
            otherwise
                error('Unknown sample interval domain ''%s''',wvfGet(wvf,'sample interval domain'));
        end
        
        % Unit conversion.  If varargin{1} is empty, then the units are
        % 'mm' and we leave it alone.  Otherwise, we convert from
        % millimeters to the requested unit.
        if ~isempty(varargin)
            val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'pupildiameter','pupilsize'}
        %  wvfGet(wvf,'pupil diameter','mm')
        % Pupil diameter 
        %
        % Used when computing pupil function and PSF.  
        % (For the moment, it is stored in mm.  But that should change
        % shortly!)
        val = wvf.pupilDiameter;
        
        % Adjust units from millimeters to requested
        if ~isempty(varargin)
            val = (val*1e-3)*ieUnitScaleFactor(varargin{1});
        end
        
    case {'focallength','flength'}
        % wvfGet(wvf,'focal length',unit);
        % We use the focal length (m) to calculate meters per degree in psf
        % spatial samples.
        val = 17e-3;  % 17 mm is default
        if isfield(wvf,'focalLength'), val = wvf.focalLength; end
        
        if ~isempty(varargin) 
            val = val*ieUnitScaleFactor(varargin{1}); 
        end
    case {'fnumber'}
        % If we have a pupil diameter and focal length, we can produce the
        % fnumber.  Not always appropriate, but sometimes it is
        fl = wvfGet(wvf,'focal length','m');
        pd = wvfGet(wvf,'pupil diameter','m');
        val = fl/pd;
        
    case {'wave','wavelength','wavelengths'}
        % Wavelengths to compute on
        % wvfGet(wvf,'wave',unit,idx)
        % wvfGet(wvf,'wave','um',3)
        % May be a vector or single wavelength
        val = wvf.wls;
        
        % Adjust units
        if ~isempty(varargin)
            unit = varargin{1};
            val = val*(1e-9)*ieUnitScaleFactor(unit);
        end
        
        % Select wavelength if indices were passed
        if length(varargin) > 1, val = val(varargin{2}); end
        
        
    case {'nwave','nwavelengths'}
        % Number of wavelengths to calculate at
        val = length(wvf.wls);
       
        %% Point spread parameters
        %  The point spread is an important calculation.
        %  We need linespread and otf, too.
        %
        case 'psf'
        % Get the PSF.
        %   wvfGet(wvf,'psf',wList)
        
        % Force user to code to explicitly compute the PSF if it isn't done.  Not ideal
        % but should be OK.
        if (~isfield(wvf,'psf'))
            error('Must explicitly compute PSF on wvf structure before getting it.  Use wvfComputePSF');
        end
        
        % Return whole cell array of psfs over wavelength if no argument
        % passed.  If there is a specific wavelength listed, we return the
        % pupil function as a matrix, rather than as a cell array.
        if isempty(varargin)
            % No wavelength listed.
            if (length(wvf.psf) == 1), val = wvf.psf{1};
            else,                      val = wvf.psf;
            end
        else
            % Wavelength listed.  Get the matrix for that wavelength
            wList = varargin{1}; idx = wvfWave2idx(wvf,wList);
            nWave = wvfGet(wvf,'nwave');
            if idx > nWave, error('idx (%d) > nWave',idx,nWave);
            else, val = wvf.psf{idx};
            end
        end
        
    case 'diffractionpsf'
        % Compute and return diffraction limited PSF for the calculation
        % wavelength  and pupil diameter.
        %
        %   wvfGet(wvf,'diffraction psf',wList);
        if ~isempty(varargin), wList= varargin{1};
        else,                  wList = wvfGet(wvf,'wave');
        end
        zcoeffs = 0;
        wvfTemp = wvfSet(wvf,'zcoeffs',zcoeffs);
        wvfTemp = wvfSet(wvfTemp,'wave',wList(1));
        wvfTemp = wvfComputePSF(wvfTemp);
        val = wvfGet(wvfTemp,'psf',wList(1));
        
    case {'psfarcminpersample', 'psfarcminperpixel', 'arcminperpix'}
        % wvfGet(wvf,'psf arcmin per sample',wList)
        %
        % Arc minutes per pixel in the psf domain, for the calculated
        % wavelength(s).
        %
        % I gather this is wavelength dependent when calculated in the
        % pupil domain, but not in the psf domain. I didn't know what I was
        % doing when I started this, so I put things in the pupil domain.
        % But this makes me think I should flip that and choose the psf
        % domain.  
        % 
        % Go back and check!!! Then RETURN HERE and either delete pupil or
        % psf.
        % 
        
        % Get wavelengths
        wavelengths = wvfGet(wvf,'wavelengths','mm');
        wList = varargin{1};
        waveIdx = wvfWave2idx(wvf,wList);
        
        % Figure out what's being held constant with wavelength and act
        % appropriately.
        whichDomain = wvfGet(wvf,'sample interval domain');
        if (strcmp(whichDomain,'psf'))
            val = wvfGet(wvf,'ref psf arcmin per pixel')*ones(length(waveIdx),1);
        elseif (strcmp(whichDomain,'pupil'))
            radiansPerPixel = ...
                wavelengths(waveIdx)/wvfGet(wvf,'ref pupil plane size','mm');
            val = (180*60/pi)*radiansPerPixel;
        else
            error('Unknown sample interval domain ''%s''',whichDomain);
        end
        
    case {'psfanglepersample','angleperpixel','angperpix'}
        % Angular extent per pixel in the psf or pupil domain, for
        % calculated wavelength(s).
        %
        % wvfGet(wvf,'psf angle per sample',unit,wList)
        % unit = 'min' (default), 'deg', or 'sec'%  wvfGet(wvf,'psf angle per sample')
        %

        unit  = varargin{1};
        wList = varargin{2};
        val = wvfGet(wvf,'psf arcmin per sample',wList);
        if ~isempty(unit)
            unit = lower(unit);
            switch unit
                case 'deg'
                    val = val/60;
                case 'sec'
                    val = val*60;
                case 'min'
                    % Default
                otherwise
                    error('unknown angle unit %s\n',unit);
            end
        end
        
    case {'psfangularsamples'} 
        % Return 1-d slice of sampled angles for psf, centered on 0, for
        % a single wavelength
        %
        % THIS HAD measuredWavelength, but since we don't have that any
        % more, I am not sure what to do.  Do we need a reference
        % wavelength in general?  
        %
        %  wvfGet(wvf,'psf angular samples',unit,waveIdx)
        % unit = 'min' (default), 'deg', or 'sec'
        % Should call routine below to get anglePerPix.
        unit = 'min'; wList = wvfGet(wvf,'wavelengths');
        if ~isempty(varargin), unit = varargin{1}; end
        if (length(varargin) > 1), wList = varargin{2}; end
        if length(wList) > 1
            error('This only works for one wavelength at a time');
        end
        
        anglePerPix = wvfGet(wvf,'psf angle per sample',unit,wList);
        middleRow = wvfGet(wvf,'middle row');
        nPixels = wvfGet(wvf,'spatial samples');
        val = anglePerPix*((1:nPixels)-middleRow);
        
    case {'psfangularsample'}
        % wvfGet(wvf,'psf angular sample',unit,waveIdx)
        %
        % The angular unit and wavelength must be specified
        %   unit = 'min', 'deg', or 'sec'
        %
        unit = varargin{1};
        wList = varargin{2};
        if (length(wList) > 1)
            error('This only works for one wavelength at a time');
        end
        val = wvfGet(wvf,'psf angle per sample',unit,wList);

    case {'psfspatialsamples','samplesspace','supportspace','spatialsupport'}
        % wvfGet(wvf,'samples space',unit,waves)
        %
        % Returns the spatial support in samples, centered on 0
        % The spatial unit (e.g., 'um') and wavelength (e.g., 550) must be
        % specified 
        %
        % When calculated in the pupil plane, as we do here, the spatial
        % samples (and frequency support for the OTF) are wavelength
        % dependent.  To convert the wvf to oi, where this is not the case,
        % we need to interpolate the different spatial samples at each
        % wavelength into a common frame.
        
        unit = 'deg'; wave = wvfGet(wvf,'wave');
        if ~isempty(varargin),   unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        
        % The number of meters per deg matters for the OTF and PSF
        % specification on the imaging surface. The value can be calculated
        % from the focal length using tand(opp/adj) = 1, and in this case
        % adj is the focal length, opposite is the distance on the imaging
        % surface, and the equation says the tangent of that ratio is 1
        % deg.
        flength = wvfGet(wvf,'focal length','m');
        mPerDeg = flength*tand(1);    % Meters per deg
        
        % Get the angular samples in degrees.  This is the wavelength
        % dependent step.
        val = wvfGet(wvf,'psf angular samples','deg',wave);
        
        % Convert angle to meters
        val = val*mPerDeg;  
        
        % Now convert to selected spatial scale
        val = val*ieUnitScaleFactor(unit);
        
    case {'psfspatialsample'}
        % This parameter matters for the OTF and PSF quite a bit.  It
        % is the number of um per degree on the retina.
        umPerDeg = (330*10^-6);
        unit = 'mm'; wList = wvfGet(wvf,'measured wavelength');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wList = varargin{2}; end
        if length(wList) > 1, error('One wavelength only'); end
        
        % Get the samples in degrees
        val = wvfGet(wvf,'psf angular sample','deg',wList);
        
        % Convert to meters and then to selected spatial scale
        val = val*umPerDeg;  % Sample in meters assuming 300 um / deg
        val = val*ieUnitScaleFactor(unit);
        
    case {'pupilspatialsamples'}
        % wvfGet(wvf,'pupil spatial samples','mm',wList)
        % Spatial support in samples, centered on 0
        % Unit and wavelength must be specified
        
        unit = varargin{1}; wList = varargin{2};
        
        % Get the sampling rate in the pupil plane in space per sample
        spacePerSample = wvfGet(wvf,'pupil plane size',unit,wList)/wvfGet(wvf,'spatial samples');
        nSamples = wvfGet(wvf,'spatial samples');
        middleRow = wvfGet(wvf,'middle row');
        val = spacePerSample*((1:nSamples)-middleRow);
        
    case {'pupilspatialsample'}
        % wvfGet(wvf,'pupil spatial sample','mm',wList)
        % Spatial support in samples, centered on 0

        unit = 'mm'; wList = wvfGet(wvf,'wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wList = varargin{2}; end
        
        % Get the sampling rate in the pupil plane in space per sample
        val = wvfGet(wvf,'pupil plane size',unit,wList)/wvfGet(wvf,'spatial samples');

    case {'middlerow'}
        val = floor(wvfGet(wvf,'npixels')/2) + 1;
        
    case {'otf'}
        % Return the otf from the psf
        %
        %   wvfGet(wvf,'otf',wave)
        %
        % The units are calculated in 'otf support' (see below).
        
        wave = wvfGet(wvf,'wave');
        if ~isempty(varargin), wave = varargin{1}; end
        psf = wvfGet(wvf,'psf',wave);   % vcNewGraphWin; mesh(psf)
        val = fftshift(psf2otf(psf));   % vcNewGraphWin; mesh(val)
        
    case {'otfsupport'}
        % wvfGet(wvf,'otfsupport',unit,wave)
        unit = 'mm'; wave = wvfGet(wvf,'wave');
        if ~isempty(varargin),   unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        
        %  s = wvfGet(wvf,'psf spatial sample',unit,wave);
        %  n = wvfGet(wvf,'nsamples');   % Should specify psf or pupil, but I think they are the same
        %  val = (0:(n-1))*(s*n);   % Cycles per unit
        %  val = val - mean(val);
        %
        samp = wvfGet(wvf,'samples space',unit,wave);
        nSamp = length(samp);
        dx = samp(2) - samp(1);
        nyquistF = 1 / (2*dx);   % Line pairs (cycles) per unit space
        val = unitFrequencyList(nSamp)*nyquistF;
        

    case {'lsf'}
        % wave = wvfGet(wvf,'wave');
        % lsf = wvfGet(wvf,'lsf',unit,wave); vcNewGraphWin; plot(lsf)
        % For the moment, this only runs if we have precomputed the PSF and
        % we have a matching wavelength in the measured and calc
        % wavelengths.  We need to think this through more.
        wave = wvfGet(wvf,'wave');
        if length(varargin) > 1, wave = varargin{1}; end
        
        otf  = wvfGet(wvf,'otf',wave);
        mRow = wvfGet(wvf,'middle row');
        val  = fftshift(abs(fft(otf(mRow,:))));
        
    case {'lsfsupport'}
        % wvfGet(wvf,'lsf support');
        %
        unit = 'mm'; wave = wvfGet(wvf,'wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        val = wvfGet(wvf,'psf spatial samples',unit,wave);
        
        
        %     case {'areapix'}
        %         % This is the summed amplitude of the pupil function *before*
        %         % Stiles-Crawford correction over the pixels where the pupil
        %         % function is defined.  It doesn't have much physical significance,
        %         % but taking the ratio with areapixapod (just below) tells us
        %         % how much light is effectively lost at each wavelength during
        %         % cone absorption becauseof the Stiles-Crawford effect.  The most likely
        %         % use of this is via the scefrac get above.
        %         %
        %         % This is computed with the pupil function, and is thus stale
        %         % if the pupil function is stale.
        %         if (~isfield(wvf,'pupilfunc'))
        %             error('Must compute pupil function  before retrieving %s. Use wvfComputePupilFunction or wvfComputePSF', parm);
        %         end
        %
        %         if isempty(varargin)
        %             val = wvf.areapix;
        %         else
        %             wList = varargin{1}; idx = wvfWave2idx(wvf,wList);
        %             nWave = wvfGet(wvf,'nwave');
        %             if idx > nWave, error('idx (%d) > nWave',idx,nWave);
        %             else val = wvf.areapix(idx);
        %             end
        %         end
        %
        %     case {'areapixapod'}
        %         % This is the summed amplitude of the pupil function *after*
        %         % Stiles-Crawford correction over the pixels where the pupil
        %         % function is defined.  It doesn't have much physical significance,
        %         % but taking the ratio with areapixapod (just above) tells us
        %         % how much light is effectively lost at each wavelength during
        %         % cone absorption becauseof the Stiles-Crawford effect.  The most likely
        %         % use of this is via the scefrac get above.
        %         %
        %         % This is computed with the pupil function, and is thus stale
        %         % if the pupil function is stale.
        %         if (~isfield(wvf,'pupilfunc'))
        %             error('Must compute pupil function  before retrieving %s. Use wvfComputePupilFunction or wvfComputePSF', parm);
        %         end
        %
        %         if isempty(varargin)
        %             val = wvf.areapixapod;
        %         else
        %             wList = varargin{1}; idx = wvfWave2idx(wvf,wList);
        %             nWave = wvfGet(wvf,'nwave');
        %             if idx > nWave, error('idx (%d) > nWave',idx,nWave);
        %             else val = wvf.areapixapod(idx);
        %             end
        %         end
        %
        %     case {'sceconesfraction','conescefraction'}
        %         % SCE fraction for cone psfs
        %
        %         % Can't do this unless psf is computed and not stale
        %         if (~isfield(wvf,'psf'))
        %             error('Must compute PSF on wvf structure before retrieving %s. Use wvfComputePSF', parm);
        %         end
        %
        %         [nil,val] = wvfComputeConePSF(wvf);
        
        
    case 'strehl'
        % Strehl ratio. The strehl is the ratio of the peak of diff limited and the
        % existing PSF at each wavelength.
        %   wvfGet(wvf,'strehl',wList);
        
        % Force user to code to explicitly compute the PSF if it isn't done.  Not ideal
        % but should be OK.
        if (~isfield(wvf,'psf'))
            error('Must compute PSF on wvf structure before retrieving %s. Use wvfComputePSF', parm);
        end
        
        % We could write this so that with no arguments we return all of
        % the ratios across wavelengths.  For now, force a request for a
        % wavelength index.
        wList = varargin{1};
        psf = wvfGet(wvf,'psf',wList);
        dpsf = wvfGet(wvf,'diffraction psf',wList);
        val = max(psf(:))/max(dpsf(:));
        
        %         areaPixapod = wvfGet(wvf,'area pixapod',waveIdx);
        %         val = max(psf(:))/areaPixapod^2;
        %         % Old calculation was done in the compute pupil function routine.
        % Now, we do it on the fly in here, for a wavelength
        % strehl(wl) = max(max(psf{wl}))./(areapixapod(wl)^2);
        
    case 'psfcentered'
        % PSF entered so that peak is at middle position in coordinate grid
        %   wvfGet(wvf,'psf centered',wList)
        
        % Force user to code to explicitly compute the PSF if it isn't done.  Not ideal
        % but should be OK.
        if (~isfield(wvf,'psf'))
            error('Must compute PSF on wvf structure before retrieving %s. Use wvfComputePSF', parm);
        end
        
        if isempty(varargin), wList = wvfGet(wvf,'wave');
        else, wList = varargin{1};
        end
        if length(wList) > 1, error('Only one wavelength permitted');
        else,                 val = psfCenter(wvfGet(wvf,'psf',wList));
        end
        
    case '1dpsf'
        % One dimensional slice through the PSF.
        %   wvfGet(wvf,'1d psf',wList,row)
        
        % Force user to code to explicitly compute the PSF if it isn't done.  Not ideal
        % but should be OK.
        if (~isfield(wvf,'psf'))
            error('Must compute PSF on wvf structure before retrieving %s. Use wvfComputePSF', parm);
        end
        
        % Defaults
        wList = wvfGet(wvf,'wave');
        whichRow = wvfGet(wvf,'middle row');
        
        % Override with varargins
        if ~isempty(varargin),   wList    = varargin{1}; end
        if length(varargin) > 1, whichRow = varargin{2}; end
        
        psf = psfCenter(wvfGet(wvf,'psf',wList));
        val = psf(whichRow,:);
        
    otherwise
        error('Unknown parameter %s\n',parm);
        
end



return

