function val = wvfGet(wvf, parm, varargin)
% Get wavefront structure parameters and derived properties
%
% Syntax:
%   val = wvfGet(wvf, parm, [varargin])
%
% Description:
%    Wavefront properties are either stored as parameters or computed from
%    those parameters. We generally store only unique values and  calculate
%    all derived values.
%
%    A '*' indicates that the syntax wvfGet(wvf, param, unit) can be used,
%    where unit specifies the spatial scale of the returned value:
%
%       length: 'm', 'cm', 'mm', 'um', 'nm'.
%       angle: 'deg', 'min', 'sec'
%
%    The wavefront to psf calculations are performed in angular units.
%    The conversion to spatial units is done using the value set in
%    the object's field umPerDegree.  This defaults to 300 in
%    wvfCreate, which is a reasonable number for the human eye.  But
%    it is not a reasonable value for general optics.  In general we
%    have the tan(a) = opp/flength, so for a = 1 deg, we have
%
%               opp = tand(1)*flength = umPerDegree
%
%    A leading + indicates that this is a get only parameter and may not
%    be set directly.
%
% Inputs:
%    wvf      - The wavefront object
%    parm     - The parameter to retrieve, options are below, sorted into
%               categories due to the large number of options.
%
%      Bookkeeping
%        'name'                   - Name of this object
%        'type'                   - Type of this object, is always 'wvf'
%        'um per degree'          - Conversion factor degree of visual angle
%                                   and um on retina
%
%      Zernike coefficients and pupil function
%        'zcoeffs'                - wvfGet(wvf, 'zcoeffs', [zidx])
%
%                                   Zernike coefficients, OSA standard
%                                   numbering/coordinates, units are such
%                                   that synthesized pupil function is in
%                                   microns.
%
%                                   Argument zidx is optional, and can be a
%                                   vector of j values or a string array of
%                                   coefficient names (see
%                                   wvfOSAIndexToVectorIndex). It specifies
%                                   which coefficients are being passed.
%                                   If not passed, passed zcoeefs are treated
%                                   as sequential starting with j = 0.
%
%                                   Note that j values start at 0, and that
%                                   is the convention followed here. If idx
%                                   is passed, the length of val matches
%                                   that of idx. And, it is an error if you
%                                   try to get a coefficient that has not
%                                   been set.
%        +'wavefront aberrations' - wvfGet(wvf, 'wavefront aberrations', [wl])
%
%                                   Wavefront aberrations in microns.  If
%                                   wl is not provided, the answer comes
%                                   back at the list of calc wavelengths.
%                                   If there are multiple wavelengths, then
%                                   this is a cell array of matrices. If wl
%                                   is passed, is should be a single
%                                   scalar.
%
%                                   If you are asking for this, you are
%                                   deep in it, and will need to go read
%                                   the code for wvfComputePupilFunction to
%                                   figure out exactly what these are and
%                                   how they are represented.  If you
%                                   figure it out, improve this comment.
%        +'pupil function'        - wvfGet(wvf, 'pupilfunc', [wl])
%
%                                   Pupil function in microsn. If wl is not
%                                   provided, the answer comes back at the
%                                   list of calc wavelengths. If there are
%                                   multiple wavelengths, then this is a
%                                   cell array of matrices. If wl is
%                                   passed, is should be a single scalar.
%
%      Spatial sampling parameters
%        'sample interval domain' - Which domain has sample interval held
%                                   constant with wavelength. The options
%                                   are: ('psf', 'pupil')
%        'number spatial samples' - Number of spatial samples (pixel) for
%                                   pupil function and psf
%        'ref pupil plane size'   - Size of sampled pupil plane at
%                                   measurement wavelength (mm, *)
%        'ref pupil plane sample interval'
%                                 - Pixel sample interval in pupil plane at
%                                   measurement wavelength (mm, *)
%        'ref psf sample interval'
%                                 - Sampling interval for psf at measurment
%                                   wavelength (arcminute/pixel)
%       +'pupil plane size'       - Size of sampled pupil plane at any
%                                   calculated wavelength(s) (mm)
%       +'psf arcmin per sample'  - Sampling interval for psf at any
%                                   calculated wavelength(s) (min/pixel)
%       +'psf angle per sample'   - Sampling interval for psf at any
%                                   calculated wavelength(s) (min, */pixel)
%       +'psf angular samples'    - One-d slice of sampled angles for psf,
%                                   centered on 0, for a single wavelength
%                                   (min, *)
%       +'psf spatial samples'    - One-d slice of sampled psf in spatial
%                                   units, centered on 0 for a single
%                                   wavelength (*)
%       +'pupil spatial samples'  - One-d slice of sampled pupil function
%                                   in spatial units, centered on 0 for a
%                                   single wavelength (*)
%       +'middle row'             - The middle row of sampled functions
%
%      Calculation parameters
%        'calc pupil diameter'    - Pupil size for calculation (mm, *)
%        'calc optical axis'      - Optical axis to compute for (deg)
%        'calc observer accommodation'
%                                 - Observer accommodation at calculation
%                                   time (diopters)
%        'calc observer focus correction'
%                                 - Focus correction added optically for
%                                   observer at calculation time (diopters)
%        'calc wavelengths'       - Wavelengths to calculate over (nm, *)
%        'calc cone psf info'     - Structure with cone sensitivities and
%                                   weighting spectrum for computing the
%                                   cone psfs.
%       +'number calc wavelengths'
%                                 - Number of wavelengths to calculate over
%                                   Pupil and sointspread function
%
%      Psf related
%       +'psf'                    - Point spread function. Must call
%                                   wvfComputePSF on wvf before get
%       +'psf centered'           - The peak of PSF is at the center of the
%                                   returned matrix
%       +'1d psf'                 - One dimensional horizontal (along row)
%                                   slice through PSF centered on its max
%       +'diffraction psf'        - Diffraction limite PSF
%       +'cone psf'               - PSF as seen by cones for given
%                                   weighting spectrum.
%
%      Stiles Crawford Effect
%        'sce params'             - The whole structure
%        'sce x0'                 -
%        'sce y0'                 -
%        'sce rho'                -
%        'sce wavelengths'*       -
%       +'sce fraction'           - How much light is effectively lost by
%                                   cones because of sce
%       +'areapix'                - Used in computation of sce fraction
%       +'areapixapod'            - Used in computation of sce fraction
%       +'cone sce fraction'      - SCE fraction for cone psfs
%
%      Measurement parameters
%        'measured pupil diameter'- Pupil size for wavefront aberration
%                                   meaurements (mm, *)
%        'measured wl'            - Wavefront aberration measurement
%                                   wavelength (nm, *)
%        'measured optical axis'
%                                 - Measured optical axis (deg)
%        'measured observer accommodation'
%                                 - Observer accommodation at aberration
%                                   measurement time (diopters)
%        'measured observer focus correction'
%                                 - Focus correction added optically for
%                                   observer at measurement time (diopters)
%
%
%      Need to be implemented/checked/documented
%       +'distanceperpix'          -
%       +'samplesspace'            -
%       +'strehl'                  - Ratio of the peak of diffraction
%                                    limited to actual
%
% Outputs:
%    val      - The value of the parameter ('parm')
%
% Optional key/value pairs:
%    *Needs attention*
%
% Notes:
%    * [Note: JNM - From 'refpupilplanesampleinterval' case -- shouldn't
%      all of these options have 'measured' in the title?]
%    * [Note: JNM - From 'pupilplanesize' - What if varargin{2} is empty?]
%    * [Note: JNM - Some input options for parm are missing their
%      definitions, can we specify these please?]
%    * TODO: Fill out optional key/value pairs section.
%
% See Also:
%    wvfSet, wvfCreate, wvfComputePupilFunction, wvfComputePSF, sceCreate,
%    sceGet, wvfOSAIndexToVectorIndex.
%

% History:
%    xx/xx/11       (c) Wavefront Toolbox Team 2011, 2012
%    12/08/17  dhb  Pass parm through synonym routine.
%              dhb  Don't center the returned 1D psf. That really messes
%                   things up if the max psf is not at the center, as can
%                   occur with aberrations and defocus.
%              dhb  umPerDegree is now obtained from the wvf structure.
%              dhb  Return otf with DC in upper left, not centered, to
%                   match isetbio conventions.  Changed calls to this to
%                   keep everything working.
%              dhb  Broke out into multiple switches to start to organize.
%                   Worked on help text.
%    07/05/22  npc  Custom LCA
%    07/03/23  baw  Many comments as part of integration with ISETBio/Cam

% Examples:
%{
    % Compute diffraction limited psf
    wvfP = wvfCreate('wave',550);
    wvfP = wvfCompute(wvfP);
    wvfPlot(wvfP,'image psf','wave',550,'plot range',15,'airy disk',true,'unit','um');

    psf = wvfGet(wvfP, 'diffraction psf', 550);
    support = wvfGet(wvfP,'psf support','um');
    wvfPlot(wvfP,'image psf','wave',550,'plot range',15,'airy disk',true,'unit','um');
%}
%{
    % Strehl is ratio of diffraction and current
    wvfP = wvfCreate;
    wvfP = wvfCompute(wvfP,'humanlca',false);
    wvfGet(wvfP, 'strehl', 550)
%}
%{
    % Blur and recompute. 5th coefficient is defocus,
    % see wvfOSAIndexToVectorIndex.
    % In case you didn't happen know that, you could also call
    %   wvfP = wvfSet(wvfP,'zcoeffs',0.3,'defocus')
    % to the same effect as the code setting the defocus
    % below.
    wvfP = wvfCreate;
	z = wvfGet(wvfP, 'zcoeffs');
    z(5) = 0.3;
    wvfP = wvfSet(wvfP, 'zcoeffs', z);
	wvfP = wvfCompute(wvfP,'humanlca',false);
    wvfGet(wvfP, 'strehl', 550)
%}
%{
	wvf = wvfCreate;
    wvf = wvfCompute(wvf);
    otf = wvfGet(wvf,'otf',wvfGet(wvf,'wave'));
    f = wvfGet(wvf, 'otf support', 'mm');
	ieNewGraphWin; mesh(f, f, abs(otf));
%}
%{
    wvf = wvfCreate;
    wvf = wvfCompute(wvf);
	lsf = wvfGet(wvf, 'lsf', wvfGet(wvf,'wave'));
    x = wvfGet(wvf, 'lsf support', 'um');
	ieNewGraphWin; plot(x, lsf); grid on; xlabel('Pos (mm)');
%}

%% Massage parameters
if ~exist('parm', 'var') || isempty(parm)
    error('Parameter must be defined.');
end
parm = ieParamFormat(parm);
parm = wvfKeySynonyms(parm);

% Default return is empty
val = [];

%% Bookkeeping gets
isBookkeeping = true;
switch (parm)
    case 'name'
        val = wvf.name;
        
    case 'type'
        val = wvf.type;
        
    case {'umperdegree','umperdeg'}
        % Conversion factor between um on retina & visual angle in degreees
        val = wvf.umPerDegree;
        
    case {'customlca'}
        val = wvf.customLCA;
        
    otherwise
        isBookkeeping = false;
end

%% Zernike/pupil plane properties
%
% The Zernicke coefficients define the wavefront aberrations in the
% pupil plane. Various quantities are derived from this.
isZernike = true;
switch (parm)
    case {'zcoeffs'}
        % Zernike coeffs themselves.
        if (isempty(varargin))
            val = wvf.zcoeffs;
        else
            idx = wvfOSAIndexToVectorIndex(varargin{1});
            tempcoeffs = wvf.zcoeffs;
            maxidx = max(idx);
            if (maxidx > length(wvf.zcoeffs))
                tempcoeffs(length(tempcoeffs) + 1:maxidx) = 0;
            end
            val = tempcoeffs(idx);
        end
        
    case {'wavefrontaberrations','wavefrontaberration'}
        % wvfGet(wvf,'wavefront aberration',[thisWave])
        %
        % The wavefront aberrations are calculated from Zernicke
        % coefficients in the routine wvfComputePupilFunction
        %
        % If there are multiple wavelengths, then this is a cell array of
        % matrices wvfGet(wvf, 'wavefront aberrations', wList) This comes
        % back in microns.
        %
        % The wavefront aberrations are specified across a support that can
        % extend past the pupil aperture function.  Returning the
        % aberration is not precisely the same as returning the phase of
        % the pupil function, which has the aperture function multiplied
        % into it.
        
        % You can't do the get unless it has already been computed, and is
        % not stale.
        if (~isfield(wvf, 'pupilfunc') || ...
                ~isfield(wvf, 'PUPILFUNCTION_STALE') || ...
                wvf.PUPILFUNCTION_STALE)
            error(['Must compute wavefront aberrations before '...
                'getting them. Use wvfComputePupilFunction or '...
                'wvfComputePSF.']);
        end
        
        % Return whole cell array of wavefront aberrations over the calc
        % wavelengths if no argument passed. If there is just one
        % wavelength, we return the wavefront aberrations as a matrix,
        % rather than as a cell array with one entry.
        if isempty(varargin)
            if (length(wvf.wavefrontaberrations) == 1)
                val = wvf.wavefrontaberrations{1};
            else
                val = wvf.wavefrontaberrations;
            end
        else
            wList = varargin{1};
            if (length(wList) > 1)
                error('Can only request one wavelength here');
            end
            idx = wvfWave2idx(wvf, wList);
            nWave = wvfGet(wvf, 'nwave');
            if idx > nWave
                error('idx (%d) > nWave', idx, nWave);
            else
                val = wvf.wavefrontaberrations{idx};
            end
        end
        
    case {'pupilfunction', 'pupilfunc'}
        %   wvfGet(wvf, 'pupilfunc', wList)
        %
        % The pupil function is derived from Zernike coefficients in the
        % routine wvfComputePupilFunction, and in some cases (e.g.,
        % computing with flare) an aperture function is incorporated as the
        % amplitude component.
        %
        % If there are multiple wavelengths, then this is a cell array of
        % matrices
        
        % To do the get, we check whether it has already been computed and
        % is not stale.
        if (~isfield(wvf, 'pupilfunc') || ...
                ~isfield(wvf, 'PUPILFUNCTION_STALE') || ...
                wvf.PUPILFUNCTION_STALE)
            error(['Must compute pupil function before getting it. '...
                'Use wvfComputePupilFunction or wvfComputePSF.']);
        end
        
        % Return whole cell array of pupil functions over the calc
        % wavelengths if no argument passed. If there is just one
        % wavelength, we return the pupil function as a matrix, rather than
        % as a cell array with one entry.
        if isempty(varargin)
            if (length(wvf.pupilfunc) == 1)
                val = wvf.pupilfunc{1};
            else
                val = wvf.pupilfunc;
            end
        else
            wList = varargin{1};
            if (length(wList) > 1), error('Request only one wavelength.'); end
            idx = wvfWave2idx(wvf, wList);
            nWave = wvfGet(wvf, 'nwave');
            if idx > nWave, error('idx (%d) > nWave', idx, nWave);
            else,           val = wvf.pupilfunc{idx};
            end
        end
    case {'pupilfunctionamplitude','aperture'}
        % wvfGet(wvf,'pupil function amplitude',thisWave);
        %
        % Amplitude of the pupil function
        thisWave = wvfGet(wvf,'wave');
        if ~isempty(varargin), thisWave = varargin{1}; end
        pf = wvfGet(wvf,'pupil function',thisWave);

        if iscell(pf),  for ii=1:numel(pf), pf{ii} = abs(pf{ii});  end
        else,           pf = abs(pf);
        end
        val = pf;

    case {'pupilfunctionphase'}
        % wvfGet(wvf,'pupil function phase',thisWave);
        %
        % The pupil function combines the wavefront aberration and the
        % aperture function.  The pupil function phase is not the same as
        % the wavefront aperture because the aperture function can limit
        % the spatial extent of the phase.
        %
        thisWave = wvfGet(wvf,'wave');
        if ~isempty(varargin), thisWave = varargin{1}; end
        pf = wvfGet(wvf,'pupil function',thisWave);
        if iscell(pf),  for ii=1:numel(pf), pf{ii} = angle(pf{ii});  end
        else,           pf = angle(pf);
        end
        val = pf;
    otherwise
        % BW:  What is this?
        isZernike = false;
end


%% The set of measured properties
% These form the backdrop for the calculation parameters.
%
isMeas = true;
switch (parm)
    case {'zpupildiameter','measuredpupildiameter', 'pupilsizemeasured', ...
            'measuredpupilsize', 'measuredpupil', 'measuredpupilmm','pupildiameter','pupilsize'}
        % Added pupilsize for ISETCam integration (BW).
        %
        % Pupil diameter in mm over for which wavefront expansion is valid
        % wvfGet(wvf, 'measured pupil diameter', 'mm')
        % wvfGet(wvf, 'measured pupil')
        val = wvf.measpupilMM;
        if ~isempty(varargin)
            % Convert to meters and then scale
            val = (val * 1e-3) * ieUnitScaleFactor(varargin{1});
        end
        
    case {'zwavelength','measuredwavelength', 'wlmeasured', 'wavelengthmeasured', ...
            'measuredwl'}
        % Measurement wavelength (nm) where the Zernike polynomial was
        % obtained.
        val = wvf.measWlNM;
        if ~isempty(varargin)
            % Convert to meters and then scale
            val = (val * 1e-9) * ieUnitScaleFactor(varargin{1});
        end
        
    case {'measuredopticalaxis', 'opticalaxismeasued', ...
            'measuredopticalaxisdeg'}
        % Measurement optical axis, degrees eccentric from fovea
        val = wvf.measOpticalAxisDeg;
        
    case {'measuredobserveraccommodation', ...
            'measuredobserveraccommodationdiopters'}
        % Observer accommodation, measured in diopters relative to relaxed
        % state of eye
        val = wvf.measObserverAcommodationDiopters;
        
    case {'measuredobserverfocuscorrection', ...
            'measuredobserverfocuscorrectiondiopters'}
        % Focus correction added optically for observer at measurement
        % time (diopters)
        val = wvf.measObserverAcommodationDiopters;
        
    case {'flippsfupsidedown'}
        val = wvf.flipPSFUpsideDown;
        
    case {'rotatepsf90degs'}
        val = wvf.rotatePSF90degs;
        
    case {'focallength','flength'}
        % wvfGet(wvf,'focal length',unit);
        % We use the focal length (m) to calculate meters per degree in psf
        % spatial samples.
        if isfield(wvf,'focallength'), val = wvf.focallength; 
        else
            warning('Using 17 mm focal length by default.')
            val = 17e-3;  % 17 mm is default
        end
        
        if ~isempty(varargin)
            val = val*ieUnitScaleFactor(varargin{1});
        end

    case {'fnumber'}
        % If we have a pupil diameter and focal length, we can produce
        % the fnumber.  Not always appropriate, but sometimes it is.
        %
        % I think this should be the calc parameters, not the measured
        % pupil diameter and focal length.
        % Changed June 2023 by BW.
        fl = wvfGet(wvf,'focal length','m');
        pd = wvfGet(wvf,'calc pupil diameter','m');
        val = fl/pd;
    otherwise
        isMeas = false;
end

%% Spatial sampling parameters.
isSpatial = true;
switch (parm)
    case {'sampleintervaldomain'}
        % What's held constant with calculated wavelength.
        % Choices are 'psf' and 'pupil'
        % This really needs a better explanation. It has to do with
        % accounting for the index of refraction, undoubtedly.
        val = wvf.constantSampleIntervalDomain;
        
    case {'numberspatialsamples', 'nsamples', 'spatialsamples', ...
            'npixels', 'fieldsizepixels'}
        % Number of pixels for both the pupil and psf planes
        % discretization This is a master value - which means that this is
        % the finest resolution.
        % Why are there both psf and pupil plane spatial samples?
        % Something about the index of refraction for the separation, but
        % not for the number ...
        val = wvf.nSpatialSamples;
        
    case {'refpupilplanesize', 'refpupilplanesizemm', 'reffieldsizemm'}
        % wvfGet(wvf,'pupil plane size',units);
        %
        % There is a simple 'pupil plane size' earlier.  I think ref means
        % the measured (reference?) plane size.        
        %
        % Size of computed field in pupil plane. This is for the sets the
        % scale for calculations at other wavelengths.
        val = wvf.refSizeOfFieldMM;
        if ~isempty(varargin)
            val = (val * 1e-3) * ieUnitScaleFactor(varargin{1});
        end
        
    case {'pupilpositions','pupilpos','pupilsamples'}
        % wvfGet(wvf,'pupil samples',wave,unit);
        %
        % Sample positions in the pupil
        %
        thisWave = wvfGet(wvf,'wave');
        if numel(thisWave)> 1, thisWave = thisWave(1); end
        unit = 'mm';
        if ~isempty(varargin), thisWave = varargin{1}; end
        if numel(varargin) > 1, unit = varargin{2}; end        

        nPixels = wvfGet(wvf, 'number spatial samples');
        pupilPos = (1:nPixels) - wvfGet(wvf,'middle row');
        dx = wvfGet(wvf,'pupil sample spacing',unit,thisWave);
        val = pupilPos * dx;

    case {'pupilsamplespacing','pupilsampleinterval'}
        % wvfGet(wvf,'pupil sample spacing',unit,wave)
        % Default unit is 'mm'
        %
        % BW: TODO
        % Not sure about the difference between refpupil and just pupil.
        % Also there is calc pupil.
        
        unit = 'mm';
        waves = wvfGet(wvf,'wave'); thisWave = waves(1);
        if ~isempty(varargin), unit = varargin{1}; end
        if numel(varargin)>1, thisWave = varargin{2}; end

        val = wvfGet(wvf,'pupil plane size','m',thisWave)/wvfGet(wvf,'npixels');
        if ~isempty(varargin)
            val = val * ieUnitScaleFactor(unit);
        end

    case {'refpupilplanesampleinterval', 'fieldsamplesizemmperpixel', ...
            'refpupilplanesampleintervalmm', 'fieldsamplesize'}
        % Pixel sample interval of sample pupil field. This is for the
        % measurement wavelength and sets the scale for calculations at
        % other wavelengths.
        % Shouldn't this have measured in the title?
        val = wvf.refSizeOfFieldMM / wvf.nSpatialSamples;
        if ~isempty(varargin)
            val = (val * 1e-3) * ieUnitScaleFactor(varargin{1});
        end
        
    case {'psfsamplespacing','psfsampleinterval',...
            'refpsfsampleinterval' 'refpsfarcminpersample', ...
            'refpsfarcminperpixel'}
        % Arc minutes per pixel of the sampled psf at the measurement
        % wavelength. This is for the measurement wavelength and sets the
        % scale for calculations at other wavelengths.
        radiansPerPixel = wvfGet(wvf, 'measured wl', 'mm') / ...
            wvfGet(wvf, 'ref pupil plane size', 'mm');
        val = (180 * 60 / pi) * radiansPerPixel;
        
    otherwise
        isSpatial = false;
end

%% Calculation parameters
% The calculation can take place at different wavelengths and pupil
% diameters than the measurement. The settings for the calculation
% are below here, I think. These should have calc in the title, I
% think.
isCalculation = true;
switch (parm)
    case {'pupilplanesize', 'pupilplanesizemm'}
        % wvfGet(wvf, 'pupil plane size', units, wList)
        %
        % BW: TODO
        % I do not understand this fully.  Also there is a calc pupil
        % plane that is probably the same as this.  Fix the overlap!
        %
        wList = wvfGet(wvf,'calc wave');
        unit = 'mm';
        if ~isempty(varargin),  unit = varargin{1}; end
        if numel(varargin) > 1, wList = varargin{2}; end

        waveIdx = wvfWave2idx(wvf, wList);
        wavelengths = wvfGet(wvf, 'calc wavelengths', 'nm');
        
        % Figure out what's being held constant with wavelength and act
        % appropriately.
        whichDomain = wvfGet(wvf, 'sample interval domain');
        if (strcmp(whichDomain, 'psf'))
            val = wvfGet(wvf, 'ref pupil plane size', 'mm') ...
                * wavelengths(waveIdx) / wvfGet(wvf, 'measured wl', 'nm');
        elseif (strcmp(whichDomain, 'pupil'))
            val = wvfGet(wvf, 'ref pupil plane size', 'mm') ...
                * ones(length(waveIdx), 1);
        else
            error('Unknown sample interval domain ''%s''', whichDomain);
        end
        
        % Unit conversion. If varargin{1} is empty, then the units are
        % 'mm' and we leave it alone.
        if ~isempty(varargin)
            val = (val * 1e-3) * ieUnitScaleFactor(unit);
        end
        
    case {'calcpupildiameter', 'calcpupilsize'}
        % Pupil diameter to use when computing pupil function and PSF.
        % The calc pupil diameter must
        % be less than or equal to measured pupil size.
        %  wvfGet(wvf, 'calculated pupil', 'mm')
        %  wvfGet(wvf, 'calculated pupil', 'um')
        %
        % alias deleted June 2023: 'calculatedpupil'

        val = wvf.calcpupilMM;
        
        % Adjust units
        if ~isempty(varargin)
            val = (val * 1e-3) * ieUnitScaleFactor(varargin{1});
        end
        
    case {'calcopticalaxis'}
        % Specify optical axis at calculation time
        val = wvf.calcOpticalAxisDegrees;
        if (val ~= wvfGet(wvf, 'measuredobserveraccommodation'))
            error(['We do not currently know how to deal with values '...
                'that differ from measurement time']);
        end
        
    case {'calcobserveraccommodation'}
        % Specify observer accommodation at calculation time
        val = wvf.calcObserverAccommodationDiopters;
        if (val ~= wvfGet(wvf, 'measuredobserveraccommodation'))
            error(['We do not currently know how to deal with values '...
                'that differ from measurement time']);
        end
        
    case {'calcobserverfocuscorrection', 'defocusdiopters'}
        % Specify optical correction added to observer focus at the
        % calculation time
        val = wvf.calcObserverFocusCorrectionDiopters;
        
    case {'calcwave', 'calcwavelengths', 'wavelengths', 'wavelength', ...
            'wls'}
        % Wavelengths to compute on
        % wvfGet(wvf, 'wave', unit, idx)
        % wvfGet(wvf, 'wave', 'um', 3)
        % May be a vector or single wavelength
        val = wvf.wls;
        
        % Adjust units
        if ~isempty(varargin)
            unit = varargin{1};
            val = val * (1e-9) * ieUnitScaleFactor(unit);
        end
        
        % Select wavelength if indices were passed
        if length(varargin) > 1, val = val(varargin{2}); end
        
    case {'calcconepsfinfo'}
        % Weighting spectrum used in calculation of polychromatic psf
        val = wvf.conePsfInfo;
        
    case {'calcnwave', 'nwave', 'numbercalcwavelengths', 'nwavelengths'}
        % Number of wavelengths to calculate at
        val = length(wvf.wls);
        
    otherwise
        isCalculation = false;
end

%% Point spread parameters
%  The point spread is an important calculation.
%  We need linespread and otf, too.
isPsf = true;
switch (parm)
    case 'psf'
        % wvfGet(wvf, 'psf', wList)
        %   Get the PSF.
        
        % Force user to code to explicitly compute the PSF if it isn't
        % done. Not ideal but should be OK.
        if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
                wvf.PSF_STALE)
            error(['Compute PSF on wvf structure '...
                'before getting it. Use wvfComputePSF']);
        end
        
        % Return whole cell array of psfs over wavelength if no varargin
        % for wave is passed. If there is just one wavelength, we return
        % the pupil function as a matrix, rather than as a cell array with
        % one entry.
        if isempty(varargin)
            % Nothing sent in, but there is only one.
            if (length(wvf.psf) == 1)
                val = wvf.psf{1};
            else
                % Nothing sent in, so return the whole psf
                val = wvf.psf;
            end
        else
            % Get the wavelength requested
            wList = varargin{1};
            idx = wvfWave2idx(wvf, wList);
            nWave = wvfGet(wvf, 'nwave');
            if idx > nWave
                error('idx (%d) > nWave', idx, nWave);
            else
                val = wvf.psf{idx};
            end
        end
        
    case 'diffractionpsf'
        % wvfGet(wvf, 'diffraction psf', [wList]);
        %
        % Compute and return diffraction limited PSF for the calculation
        % wavelength and the wavefront fnumber.
        %
        if ~isempty(varargin), wList= varargin{1};
        else,                  wList = wvfGet(wvf, 'calc wave');
        end
        fprintf('Diff limited for wave %d and F/# %.1f\n',wList,wvfGet(wvf,'fnumber'));
        zcoeffs = 0;
        wvfTemp = wvfSet(wvf, 'zcoeffs', zcoeffs);
        wvfTemp = wvfSet(wvfTemp, 'wave', wList(1));
        wvfTemp = wvfCompute(wvfTemp);
        val = wvfGet(wvfTemp, 'psf', wList(1));
        
    case {'psfarcminpersample', 'psfarcminperpixel', 'arcminperpix'}
        % wvfGet(wvf, 'psf arcmin per sample', wList)
        %
        % Arc minutes per pixel in the psf domain, for the calculated
        % wavelength(s).
        
        % Get wavelengths
        wavelengths = wvfGet(wvf, 'calc wavelengths', 'mm');
        wList = varargin{1};
        waveIdx = wvfWave2idx(wvf, wList);
        
        % Figure out what's being held constant with wavelength and act
        % appropriately.
        whichDomain = wvfGet(wvf, 'sample interval domain');
        if (strcmp(whichDomain, 'psf'))
            val = wvfGet(wvf, 'ref psf arcmin per pixel') ...
                * ones(length(waveIdx), 1);
        elseif (strcmp(whichDomain, 'pupil'))
            radiansPerPixel = ...
                wavelengths(waveIdx) / wvfGet(wvf, ...
                'ref pupil plane size', 'mm');
            val = (180 * 60 / pi) * radiansPerPixel;
        else
            error('Unknown sample interval domain ''%s''', whichDomain);
        end
        
    case {'psfanglepersample', 'angleperpixel', 'angperpix'}
        % Angular extent for a single pixel in the psf domain, for
        % calculated wavelength(s).
        %
        % wvfGet(wvf, 'psf angle per sample', unit, wList)
        % unit = 'min' (default), 'deg', or 'sec'
        unit = 'min';
        wList = wvfGet(wvf, 'measured wavelength');
        if ~isempty(varargin), unit = varargin{1}; end
        if (length(varargin) > 1), wList = varargin{2}; end

        val = wvfGet(wvf, 'psf arcmin per sample', wList);
        if ~isempty(unit)
            unit = lower(unit);
            switch unit
                case 'deg'
                    val = val / 60;
                case 'sec'
                    val = val * 60;
                case 'min'
                    % Default
                otherwise
                    error('unknown angle unit %s\n', unit);
            end
        end
        
    case {'psfangularsamples'}
        % Return 1d array of sampled angles for psf, centered on 0, for
        % a single wavelength
        %
        % Previously included the following: 'samplesangle',
        % 'samplesarcmin', 'supportarcmin'
        %
        % wvfGet(wvf, 'psf angular samples', unit, waveIdx)
        % unit = 'min' (default), 'deg', or 'sec'
        % Should call routine below to get anglePerPix.
        unit = 'min';
        wList = wvfGet(wvf, 'measured wavelength');
        if ~isempty(varargin), unit = varargin{1}; end
        if (length(varargin) > 1), wList = varargin{2}; end
        if length(wList) > 1
            error('This only works for one wavelength at a time');
        end
        
        anglePerPix = wvfGet(wvf, 'psf angle per sample', unit, wList);
        middleRow = wvfGet(wvf, 'middle row');
        nPixels = wvfGet(wvf, 'spatial samples');
        val = anglePerPix * ((1:nPixels) - middleRow);
        
    case {'psfangularsample'}
        % Returns a single angle value that is per pixel step
        %
        % wvfGet(wvf, 'psf angular sample', unit, waveIdx)
        % unit = 'min' (default), 'deg', or 'sec'
        unit = 'min';
        wList = wvfGet(wvf, 'measured wavelength');
        if ~isempty(varargin), unit = varargin{1}; end
        if (length(varargin) > 1), wList = varargin{2}; end

        if (length(wList) > 1)
            error('This only works for one wavelength at a time');
        end
        val = wvfGet(wvf, 'psf angle per sample', unit, wList);
        
    case {'psfsupport','psfspatialsample','psfspatialsamples', ...
            'samplesspace', 'supportspace','spatialsupport'}
        % wvfGet(wvf, 'samples space', 'um', wList)
        %
        %  Spatial support in samples, centered on 0
        %  Unit and wavelength must be specified
        %  Should call case below to get one val, and then scale up by
        %  number of pixels.
        
        % This parameter matters for the OTF and PSF quite a bit. It
        % is the number of um per degree on the retina.
        unit = 'deg';
        wave = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        
        % Get the angular samples in degrees
        val = wvfGet(wvf, 'psf angular samples', 'deg', wave);
        
        % The commented out code seems to be in error.  It did not account
        % for possible changes in focal length and umPerDeg
        %
        %{
         % Convert to meters and then to selected spatial scale 
         val = val * mPerDeg;  % Convert angle to sample in meters 
         val = val * ieUnitScaleFactor(unit);  % Convert to spatial scale
        %}
        switch unit
            case {'nm', 'um', 'mm', 'cm', 'm', 'km', 'in', 'ft'}
                mPerDeg = (wvfGet(wvf,'um per degree') * 10^-6);
                val = val * mPerDeg;  % Sample in meters
                val = val * ieUnitScaleFactor(unit);
            case {'min'}
                val = val*60;
            case {'sec'}
                val = val*60*60;
            case {'deg'}
                % Leave it alone
            otherwise
                error('Bad unit for samples space, %s', unit);
        end               

    case {'pupilsupport','pupilspatialsamples'}
        % wvfGet(wvf, 'pupil spatial samples', 'mm', wList)
        % Spatial support in samples, centered on 0
        % Unit and wavelength must be specified
        
        % TO CHECK BW/DHB.
        unit = varargin{1};
        wList = varargin{2};
        
        % Get the sampling rate in the pupil plane in space per sample
        spacePerSample = wvfGet(wvf, 'pupil plane size', unit, wList) ...
            / wvfGet(wvf, 'spatial samples');
        nSamples  = wvfGet(wvf, 'spatial samples');
        middleRow = wvfGet(wvf, 'middle row');
        val = spacePerSample * ((1:nSamples) - middleRow);
        
    case {'pupilspatialsample'}
        % wvfGet(wvf, 'pupil spatial sample', 'mm', wList)
        %
        
        unit = 'mm';
        wList = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wList = varargin{2}; end
        
        % Get the sampling rate in the pupil plane in space per sample
        val = wvfGet(wvf, 'pupil plane size', unit, wList) ...
            / wvfGet(wvf, 'spatial samples');
        
    case {'psfxaxis'}
        % wvfGet(wvf,'psf xaxis','mm',wave)
        unit = 'mm';
        wList = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wList = varargin{2}; end
                
        psf  = wvfGet(wvf,'psf',wList);
        samp = wvfGet(wvf,'psf spatial samples',unit,wList);

        % X axis
        val.samp = samp;
        val.data = interp2(samp,samp,psf,0,samp);
        
    case {'psfyaxis'}
        % wvfGet(wvf,'psf yaxis','mm',wave)
        unit = 'mm';
        wList = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wList = varargin{2}; end
                
        psf  = wvfGet(wvf,'psf',wList);
        samp = wvfGet(wvf,'psf spatial samples',unit,wList);

        % X axis
        val.samp = samp;
        val.data = interp2(samp,samp,psf,samp,0);

    case {'middlerow'}
        % This matches conventions for psf and otf when we use the PTB
        % routines to obtain these.
        val = floor(wvfGet(wvf, 'npixels') / 2) + 1;
        
    case {'otf'}
        % wvfGet(wvf, 'otf', wave)
        %
        % Compute OTF from the psf, using the PTB routine PsfToOtf
        %        
        % The frequency support can be calculated with respect to
        % different units using
        %
        %    wvfGet(wvf, 'otfsupport', unit, wave)

        wave = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), wave = varargin{1}; end
        if (length(wave) > 1)
            error('otf requires a single wavelength');
        end
        psf = wvfGet(wvf, 'psf', wave);
        
        % Use PTB PsfToOtf to convert to (0,0) sf at the center of the
        % otf representation.  This differs from the ISETCam optics
        % structure convention, where (0,0) sf is at the upper left.
        %
        % The basic calculation in PsfToOtf is
        %
        %   otf = fftshift(fft2(ifftshift(psf)));
        %
        [~,~,val] = PsfToOtf([],[],psf);
        
        % From PTB:  We used to zero out small imaginary values.
        % This, however, can cause numerical problems much worse than
        % having small imaginary values in the otf.  So we don't do it
        % anymore.
        
    case {'otfsupport'}
        % Spatial frequency support (default cyc/mm) for the OTF.
        % Different units can be requested.
        %
        % wvfGet(wvf, 'otfsupport', unit, wave)
        %
        % The frequency support is wavelength specific
        %
        unit = 'mm';
        wave = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        
        % s = wvfGet(wvf, 'psf spatial sample', unit, wave);
        % Should specify psf or pupil, but I think they are the same
        %
        % n = wvfGet(wvf, 'nsamples');
        % val = (0:(n - 1)) * (s * n);   % Cycles per unit
        % val = val - mean(val);
        %
        samp = wvfGet(wvf, 'samples space', unit, wave);
        nSamp = length(samp);
        dx = samp(2) - samp(1);
        nyquistF = 1 / (2 * dx);   % Line pairs (cycles) per unit space
        val = unitFrequencyList(nSamp) * nyquistF;

    case {'otfandsupport'}
        % val = wvfGet(wvf,'otf and support',unit,wave);
        %
        % For plotting it is convenient to get both the OTF and its
        % frequency support
        unit = 'mm';
        wave = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        val.data = wvfGet(wvf,'otf',wave);
        val.samp = wvfGet(wvf,'otfsupport',unit,wave);

    case {'lsf'}
        % wave = wvfGet(wvf, 'calc wave');
        % lsf = wvfGet(wvf, 'lsf', unit, wave); ieNewGraphWin; plot(lsf)
        % For the moment, this only runs if we have precomputed the PSF and
        % we have a matching wavelength in the measured and calc
        % wavelengths. We need to think this through more.
        wave = wvfGet(wvf, 'calc wave');
        if length(varargin) > 1, wave = varargin{1}; end
        psf = wvfGet(wvf,'psf',wave);
        val = psf2lsf(psf);

        % OLD: Get OTF
        %{
        otf  = fftshift(wvfGet(wvf, 'otf', wave));
        mRow = wvfGet(wvf, 'middle row');
        val  = fftshift(abs(fft(otf(mRow, :))));
        %}
    case {'lsfsupport'}
        % wvfGet(wvf, 'lsf support');
        %
        unit = 'mm';
        wave = wvfGet(wvf, 'calc wave');
        if ~isempty(varargin), unit = varargin{1}; end
        if length(varargin) > 1, wave = varargin{2}; end
        val = wvfGet(wvf, 'psf spatial samples', unit, wave);
        
    case 'psfcentered'
        % PSF has its peak at middle position in coordinate grid
        %   wvfGet(wvf, 'psf centered', wList)
        
        % Force user to explicitly compute the PSF if it isn't done. Not
        % ideal but should be OK.
        if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
                wvf.PSF_STALE)
            error(['Must compute PSF on wvf structure before retrieving'...
                ' %s. Use wvfComputePSF'], parm);
        end
        
        if isempty(varargin)
            wList = wvfGet(wvf, 'wave');
        else
            wList = varargin{1};
        end
        if length(wList) > 1
            error('Only one wavelength permitted');
        else
            val = psfCenter(wvfGet(wvf, 'psf', wList));
        end
        
    case '1dpsf'
        % One dimensional row slice through the PSF.
        %   wvfGet(wvf, '1d psf', wList, row)
        
        % Force user to code to explicitly compute the PSF if it isn't
        % done. Not ideal but should be OK.
        if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
                wvf.PSF_STALE)
            error(['Must compute PSF on wvf structure before retrieving'...
                ' %s. Use wvfComputePSF'], parm);
        end
        
        % Defaults
        wList = wvfGet(wvf, 'calc wave');
        whichRow = wvfGet(wvf, 'middle row');
        
        % Override with varargins
        if ~isempty(varargin), wList = varargin{1}; end
        if length(varargin) > 1, whichRow = varargin{2}; end
        
        % Get the 2D psf and then return the specified row
        psf = wvfGet(wvf, 'psf', wList);
        val = psf(whichRow, :);
        
    case 'conepsf'
        % PSF as seen by cones for specified weighting spectrum
        
        % Force user to code to explicitly compute the PSF if it isn't
        % done. Not ideal but should be OK.
        if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
                wvf.PSF_STALE)
            error(['Must compute PSF on wvf structure before retrieving'...
                ' %s. Use wvfComputePSF'], parm);
        end
        
        % Defaults
        val = wvfComputeConePSF(wvf);
        
    otherwise
        isPsf = false;
end

%% Stiles-Crawford Effect related
isSce = true;
switch (parm)
    case 'sce'
        % Account for angle sensitivity of the cone photoreceptors
        if isfield(wvf, 'sceParams'), val = wvf.sceParams; end
        
    case 'scex0'
        if checkfields(wvf, 'sceParams', 'xo')
            val = wvf.sceParams.xo;
        else
            val = 0;
        end
        
    case 'scey0'
        if checkfields(wvf, 'sceParams', 'yo')
            val = wvf.sceParams.yo;
        else
            val = 0;
        end
        
    case {'scewavelength', 'scewavelengths', 'scewave'}
        % This returns the wvf wavelength list if there isn't a sceParams
        % structure. Might be OK.
        % wvfGet(wvf, 'sce wavelengths', unit)
        if checkfields(wvf, 'sceParams', 'wavelengths')
            val = wvf.sceParams.wavelengths;
        else
            val = wvf.wls;
        end
        % Adjust units
        if ~isempty(varargin)
            unit = varargin{1};
            val = val * 10e-9 * ieUnitScaleFactor(unit);
        end
        
    case 'scerho'
        % Get rho value for a particular wavelength
        %  wvfGet(wvf, 'rho', waveList)
        if checkfields(wvf, 'sceParams', 'rho')
            val = wvf.sceParams.rho;
        else
            val = zeros(wvfGet(wvf, 'nWave'), 1);
        end
        
        % Return rho values for selected wavelengths
        if ~isempty(varargin)
            wave = wvfGet(wvf, 'sce wave');  % The waves for rho
            wList = varargin{1};
            index = find(ismember(round(wave), round(wList)));
            if ~isempty(index)
                val = val(index);
            else
                error('Passed wavelength not contained in sceParams');
            end
        end
        
    case {'scefraction', 'scefrac', 'stilescrawfordeffectfraction'}
        % How much light is effectively lost at each wavelength during cone
        % absorption becauseof the Stiles-Crawford effect. The most likely
        % use of this is via the scefrac get above.
        %
        % This is computed with the pupil function, and is thus stale
        % if the pupil function is stale.
        if (~isfield(wvf, 'pupilfunc') || ...
                ~isfield(wvf, 'PUPILFUNCTION_STALE') || ...
                wvf.PUPILFUNCTION_STALE)
            error(['Must compute pupil function  before retrieving %s. '...
                'Use wvfComputePupilFunction or wvfComputePSF'], parm);
        end
        
        if isempty(varargin)
            val = wvfGet(wvf, 'area pixapod') ./ wvfGet(wvf, 'areapix');
        else
            wList = varargin{1};
            val = wvfGet(wvf, 'area pixapod', wList) ...
                ./ wvfGet(wvf, 'areapix', wList);
        end
        
    case {'areapix'}
        % This is the summed amplitude of the pupil function *before*
        % Stiles-Crawford correction over the pixels where the pupil
        % function is defined. It doesn't have much physical significance,
        % but taking the ratio with areapixapod (just below) tells us how
        % much light is effectively lost at each wavelength during cone
        % absorption becauseof the Stiles-Crawford effect. The most likely
        % use of this is via the scefrac get above.
        %
        % This is computed with the pupil function, and is thus stale
        % if the pupil function is stale.
        if (~isfield(wvf, 'pupilfunc') || ...
                ~isfield(wvf, 'PUPILFUNCTION_STALE') || ...
                wvf.PUPILFUNCTION_STALE)
            error(['Must compute pupil function  before retrieving %s. '...
                'Use wvfComputePupilFunction or wvfComputePSF'], parm);
        end
        
        if isempty(varargin)
            val = wvf.areapix;
        else
            wList = varargin{1};
            idx = wvfWave2idx(wvf, wList);
            nWave = wvfGet(wvf, 'nwave');
            if idx > nWave
                error('idx (%d) > nWave', idx, nWave);
            else
                val = wvf.areapix(idx);
            end
        end
        
    case {'areapixapod'}
        % This is the summed amplitude of the pupil function *after*
        % Stiles-Crawford correction over the pixels where the pupil
        % function is defined. It doesn't have much physical significance,
        % but taking the ratio with areapixapod (just above) tells us how
        % much light is effectively lost at each wavelength during cone
        % absorption becauseof the Stiles-Crawford effect. The most likely
        % use of this is via the scefrac get above.
        %
        % This is computed with the pupil function, and is thus stale
        % if the pupil function is stale.
        if (~isfield(wvf, 'pupilfunc') || ...
                ~isfield(wvf, 'PUPILFUNCTION_STALE') || ...
                wvf.PUPILFUNCTION_STALE)
            error(['Must compute pupil function  before retrieving %s. '...
                'Use wvfComputePupilFunction or wvfComputePSF'], parm);
        end
        
        if isempty(varargin)
            val = wvf.areapixapod;
        else
            wList = varargin{1};
            idx = wvfWave2idx(wvf, wList);
            nWave = wvfGet(wvf, 'nwave');
            if idx > nWave
                error('idx (%d) > nWave', idx, nWave);
            else
                val = wvf.areapixapod(idx);
            end
        end
        
    case {'sceconesfraction', 'conescefraction'}
        % SCE fraction for cone psfs
        
        % Can't do this unless psf is computed and not stale
        if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
                wvf.PSF_STALE)
            error(['Must compute PSF on wvf structure before retrieving'...
                ' %s. Use wvfComputePSF'], parm);
        end
        
        [nil, val] = wvfComputeConePSF(wvf);
        
    case 'strehl'
        % Strehl ratio. The strehl is the ratio of the peak of diff limited
        % and the existing PSF at each wavelength.
        %   wvfGet(wvf, 'strehl', wList);
        
        % Force user to code to explicitly compute the PSF if it isn't
        % done. Not ideal but should be OK.
        if (~isfield(wvf, 'psf') || ~isfield(wvf, 'PSF_STALE') || ...
                wvf.PSF_STALE)
            error(['Must compute PSF on wvf structure before '...
                'retrieving %s. Use wvfComputePSF'], parm);
        end
        
        % We could write this so that with no arguments we return all of
        % the ratios across wavelengths. For now, force a request for a
        % wavelength index.
        wList = varargin{1};
        psf = wvfGet(wvf, 'psf', wList);
        dpsf = wvfGet(wvf, 'diffraction psf', wList);
        val = max(psf(:)) / max(dpsf(:));
        
        % areaPixapod = wvfGet(wvf, 'area pixapod', waveIdx);
        % val = max(psf(:))/areaPixapod^2;
        % % Old calculation was done in the compute pupil function routine.
        % Now, we do it on the fly in here, for a wavelength
        % strehl(wl) = max(max(psf{wl}))./(areapixapod(wl)^2);
        
    otherwise
        isSce = false;
end

%% Check that a known get parameter was requested
if (~isBookkeeping && ~isZernike && ~isMeas && ~isSpatial && ~isCalculation && ~isPsf && ~isSce)
    error('Unknown parameter %s\n', parm);
end

return
