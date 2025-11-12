function wvf = wvfSet(wvf, parm, val, varargin)
% Set wavefront parameters to use for calculations
%
% Syntax:
%   wvf = wvfSet(wvf, parm, val, [varargin])
%
% Description:
%    Key wavefront parameters are stored in this struct. Many other
%    properties are computed from these identifiable parameters using other
%    functions, such as wvfGet.
%
%    Parameter names can be written with spaces and upper/lower case. The
%    strings are converted to lower case and all the spaces are removed by
%    this routine.
%
%    When parameters that influence the pupil function are changed,
%    wvf.PUPILFUNCTION_STALE is set too true.
%
%    The initial implementation separated parameters into the ones that
%    were measured and the ones we use for a calculation (from HH). In our
%    system, we mainly use the 'calc' form of the parameters.
%
% Inputs:
%    wvf      - The wavefront object prior to manipulation.
%    parm     - The parameter you wish to alter
%    val      - The value to assign to the parameter
%    varargin - (Optional) Character strings containing parameter key/value
%               pairs, shown below.
%
% Outputs:
%    wvf      - The wavefront object after manipulation
%
% Optional key/value pairs:
%    Options are divided into sections due to their number.
%    Bookkeeping:
%       'name'                    - Object name
%       'type'                    - Type of object (should always be 'wvf')
%
%    Spatial Sampling
%       'npixels'                 - Number of spatial samples (pixel) for
%                                   pupil function and psf
%       'sample interval domain'  - Which domain has sample interval
%                                   constant with wavelength
%                                   ('psf', 'pupil') Default: psf
%       'pupil plane size'         - Size of sampled pupil plane at
%                                   measurement wavelength (mm)
%       'pupil plane sample interval' -
%                                   Pixel sample interval in pupil plane at
%                                   measurement wavelength (mm)
%       'psf sample interval' - Sampling interval for psf at measurment
%                                   wavelength (arcminute/pixel)
%    Calculations
%       'zcoeffs'                 - Zernike coefficients, OSA standard
%                                   numbering/coordinates. These are used
%                                   to synthesize the pupil function in
%                                   microns, and should therefore be passed
%                                   in those units.
%       'calc pupil size'         - Pupil size for calculation (mm, *)
%       'calc optical axis'       - Optical axis to compute for (deg)
%       'calc observer accommodation' -
%                                   Observer accommodation at calculation
%                                   time (diopters)
%       'calc observer focus correction' -
%                                   Focus correction added optically for
%                                   observer at calculation time (diopters)
%       'calc wave'               - Wavelengths to calculate over (nm, *)
%       'calc cone psf info'      - Structure with cone sensitivities and
%                                   weight spectrum for computing cone psfs
%    Retinal scale
%       'um per degree'           - Conversion factor degree of visual angle
%                                   and um on retina
%    LCA method
%       'lca method'              - 'none', 'human', function handle
%                                    for a custom LCA 
%                                   
%    Stiles Crawford Effect
%       'sce params'              - The Stiles-Crawford Effect structure
%
%    Measured Data - Not much used for our simulations
%       'measured pupil size'     - The pupil size for the measured
%                                   wavefront aberration (mm)
%       'measured wave'           - The wavefront aberration measurement
%                                   wavelength (nm)
%       'measured optical axis'   - Measured optical axis (deg)
%       'measured observer accommodation' -
%                                   Observer accommodation at aberration
%                                   measurement time (diopters)
%       'measured observer focus correction' -
%                                   Focus correction added for observer at
%                                   measurement time (diopters)
%
% References:
%    The Strehl ratio, http://en.wikipedia.org/wiki/Strehl_ratio
%
% Notes:
%	 05/17/12  dhb  When we pass fewer than 65 coefficients, should we zero
%                   out the higher order ones, or leave them alone?  The
%                   current code leaves them alone, which seems a little
%                   dangerous.
%              dhb  There are two underlying field sizes, one in the pupil
%                   plane and one in the plane of the retina. The pixel
%                   dimensions in these two fields are implicitly linked by
%                   the conversion between pupil function and psf, and our
%                   conversion code uses the same number of pixels in each
%                   representation. One could get fancier and explicitly
%                   specify the units of each representation, and
%                   appropiately convert. An important consideration is for
%                   the dimensions to be chosen so that both pupil function
%                   & psf are adequately sampled.
%
% See Also:
%    wvfGet, wvfCreate, wvfComputePupilFunction, wvfComputePSF, sceCreate,
%    sceGet, s_wvfDiffraction, v_opticsWVF
%

% History:
%    xx/xx/11  DHB/BW  (c) Wavefront Toolbox Team 2011, 2012
%    11/01/17  jnm     Comments & formatting
%    01/18/18  jnm     Formatting update to match Wiki.
%    01/16/18  dhb     Make example work.
%    07/05/22  npc     Custom LCA

% Examples:
%{
   wvf = wvfCreate;
   sce = sceCreate;
   wvf = wvfSet(wvf, 'measured pupil', 8);
   wvf = wvfSet(wvf, 'stiles crawford', sce);
   wvf = wvfSet(wvf, 'name', 'test wvf');
   wvf = wvfSet(wvf, 'zcoeffs', 0);
%}

%% Arg checks and parse.
%
% The switch on what we're setting is broken out into several pieces
% below to allow use of cells, and so that autoindent does something
% reasonable with our block comment style.
if ~exist('parm', 'var') || isempty(parm)
    error('Parameter must be defined');
end
if ~exist('val', 'var'), error('val must be defined'); end

parm = ieParamFormat(parm);
parm = wvfKeySynonyms(parm);

%% Set the parameters in a big case statement
switch parm

    %% Bookkeeping
    case 'name'
        % This specific object's name
        wvf.name = val;

    case 'type'
        % Type should always be 'wvf'
        if (~strcmp(val, 'wvf'))
            error('Can only set type of wvf structure to ''wvf''');
        end
        wvf.type = val;

        %% The measured values
        % These are the values that describe the assumed measurement
        % conditions for the zernicke coefficients.
        %
        % When we perform a calculation, we may adjust some of the
        % parameters (say the wavelength) and derive the prediction
        % correcting for these background assumptions and the calculation.
        % For example, the wavelength at calculation might differ from the
        % measured wavelength. We add a chromatic abberration correction.
        % Or the pupil size of the calculation might differ, and we account
        % for that.
        %
        % The differences are accounted for in the
        % wvfComputePupilFunction, mainly. It is possible that there are
        % other functions or scripts that compare the data as well.
        %

        %% Zernike coefficients and related
        %
        % These specify the measured (or assumed) wavefront aberrations in
        % terms of a Zernike polynomial expansion. Exanding these gives us
        % the wavefront abberations in microns over the measured pupil.
        % That is, these coefficients are in units of microns.
        %
        % The coefficients represent measurements that were made (or
        % assumed to be made) at a particular optical axis, state of
        % accommodation of the observer, wavelength, and over a particular
        % pupil size diameter. We specify all of this size information
        % along with the coefficients, even though we don't know quite how
        % to use all of it at present.
        %
        % Zernike coeffs 0, 1, 2 (piston, verticle tilt, horizontal tilt)
        % are typically 0 since they are either constant (piston) or only
        % change the point spread location, not quality, as measured in
        % wavefront aberrations. We use the "j" single-index scheme of OSA
        % standards
    
    case {'zcoeffs', 'zcoeff', 'zcoef'}
        % wvfSet(wvf, 'zcoeffs', val, jIndex);
        % jIndex is optional, and can be a vector of j values or a string
        % array of coefficient names that are converted to indices using
        % wvfOSAIndexToVectorIndex.
        %
        % Note that j indices start at 0, and that is the convention
        % followed here. We add 1 in the routine to be compliant with
        % Matlab indexing.
        %
        % The length of jIndex must match that of val. The assignment is
        %   zcoeffs(jIndices) = val;
        %
        % For this method to work properly, when the stored vector of
        % zcoeffs is shorter than required by jIndex, the vector is padded
        % with zeros prior to the insertion of the passed coefficients.
        if (isempty(varargin))
            % No names, so just set the zcoeffs to the vector sent in
            wvf.zcoeffs = val;
        else
            % We have a cell array of names.  Convert to indices and set
            % appropriately
            idx = wvfOSAIndexToVectorIndex(varargin{1});
            maxidx = max(idx);
            if (maxidx > length(wvf.zcoeffs))
                % Extend with zeroes
                wvf.zcoeffs(length(wvf.zcoeffs) + 1:maxidx) = 0;
            end            
            for ii=1:numel(idx)
                wvf.zcoeffs(idx(ii)) = val(ii);
            end

        end
        wvf.PUPILFUNCTION_STALE = true;

        %% Spatial sampling parameters
        %
        % In the end, we calculate using discretized sampling. Because
        % the pupil function and the psf are related by a Fourier
        % transform, it is natural to use the same number of spatial
        % samples for both the pupil function and the corresponding
        % psf.  The parameters here specify the sampling.
        %
        % Note that this may be done independently of the wavefront
        % measurements, because the spatial scale of those is defined by
        % pupil size over which the Zernike coefficients define the
        % wavefront aberrations.
        %
        % There are a number of parameters that are yoked together here,
        % because the sampling intervals in the pupil and psf domains are
        % yoked, and because the overall size of the sampled quantities is
        % determined from the sampling intervals and the number of pixels.
        %
        % As a general matter, it will drive us nuts to have the number of
        % pixels varying with anything, because then we can't sum over
        % wavelength easily. So we set the number of number of pixels and
        % size of the sampling in the pupil plane at the measurement
        % wavelength, and then compute/set everything else as needed.
        %
        % Because the sampling in the pupil and psf domains is yoked, it is
        % important to choose values that do not produce discretization
        % artifacts in either domain. We don't have an automated way to do
        % this, but the default numbers here were chosen by experience
        % (well, really by Heidi Hofer's experience) to work well. Be
        % attentive to this aspect if you decide you want to change them by
        % very much.
        %
        % The other thing that is tricky is that the relation between the
        % sampling in the pupil and psf domains varies with wavelength. So,
        % you can't easily have the sample interval stay constant over
        % wavelength in both the pupil and psf domains. You have to choose
        % one or the other. We will typically force equal sampling in the
        % psf domain, but we allow specification of which.
    case {'sampleintervaldomain'}
        % Determine what's held constant with calculated wavelength.
        % Choices are 'psf' and 'pupil'
        wvf.constantSampleIntervalDomain = val;

    case {'npixels', 'numberspatialsamples', 'spatialsamples',  ...
            'fieldsizepixels'}
        % The number of pixels.  This is the same in the pupil and psf
        % planes. 
        %
        wvf.nSpatialSamples = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'pupilplanesize','refpupilplanesize', 'refpupilplanesizemm', 'fieldsizemm'}
        % Total size of computed field in pupil plane. This is for the
        % measurement wavelength. In principle, this value can vary with
        % wavelength, but this one sets the scale for all the other
        % wavelengths.
        %
        % 
        %
        % TO CHECK:  Is this diameter or radius?  Or is this a square?
        %
        % This is a stored value.
        wvf.refSizeOfFieldMM = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'pupilplanemmperpixel','refpupilplanesampleinterval', 'fieldsamplesize', ...
            'refpupilplanesampleintervalmm', 'fieldsamplesizemmperpixel'}
        % Together, the field size and sampling interval determine the
        % reference field size.  The latter is the quantity that is saved,
        % not the sampling size.
        %
        % BW:  TODO
        % This code allows setting the delta of the sampling, but it does
        % not actually save it.  It just adjusts the field size.  BW is not
        % in favor.
        %
        % Pixel sampling interval of sample pupil field. This is for the
        % measurement wavelength. The value can vary with wavelength, but
        % this one sets the scale for all the other wavelengths.
        wvf.refSizeOfFieldMM = val * wvf.nSpatialSamples;
        wvf.PUPILFUNCTION_STALE = true;

    case {'psfsampleinterval','refpsfsampleinterval' 'refpsfarcminpersample', ...
            'refpsfarcminperpixel'}
        % wvfSet(wvf,'psf sample interval',val)
        %
        % See 'psf sample spacing', just below for a simple way to set
        % the spacing with spatial units
        %
        % val is the arc minutes per pixel specified in radians?
        %
        % Sets the arc minutes per pixel of the sampled psf at the measurement
        % wavelength.
        %
        % When we convert between the pupil function and the PSF, we use
        % the fft. Thus the size of the image in pixels is the same for the
        % sampled pupil function and the sampled psf.
        %
        % The number of arc minutes per pixel in the sampled PSF is related
        % to the number of mm per pixel for the pupil function, with the
        % relationship depending on the wavelength. The formula in the
        % pupil plane is that the pixel sampling interval in cycles/radian
        % is:
        %
        %   pupilPlaneCyclesRadianPerPix = pupilPlaneField/(lambda * npixels)
        %
        % where npixels is the number of linear pixels and lambda is the
        % wavelength. This formula may be found as Eq 10 of Ravikumar et
        % al. (2008), "Calculation of retinal image quality for
        % polychromatic light, " JOSA A, 25, 2395-2407, at least if we
        % think their quantity d is the size of the pupil plane field being
        % sampled.
        %
        % Now, remember how units convert when we do the fft. The number of
        % radians in the PSF image is the inverse of the sampling interval:
        %
        %   radiansInPsfImage = [lambda * npixels] / pupilPlaneField
        %
        % which then gives us the number of radiansPerPixel in the PSF
        % image as
        %
        %   radiansPerPixel = lambda / pupilPlaneField
        %
        % The formula below implements this, with a conversion from radians
        % to minutes with factor (180 * 60 / 3.1416) and converts
        % wavelength to mm from nm with factor (.001 * .001)
        %
        % DHB, 5/22/12, based on earler comments that were here. Someone
        % else might take a look at the paper referenced above and the
        % logic of this comment and check that it all seems right. Did I
        % think through the fft unit conversion correctly?  And, there must
        % be a more fundamental reference than the paper above, and for
        % which one wouldn't have to guess quite as much about what is
        % meant.
        %
        % BW: July, 2023.  Reading through here.  Hope to check. See my
        % comments above, complaining about the interaction between field
        % size, sample spacing, and number of samples.
        %                
        radiansPerPixel = val / (180 * 60 / 3.1416);
        tmp = wvfGet(wvf, 'measured wl', 'mm') / radiansPerPixel;

        % 2025:10:25
        % Not sure why but there was a missing wvf on the set side (BW).
        wvf = wvfSet(wvf,'field size mm', tmp);

        % Original
        % wvf.refSizeOfFieldMM = wvfGet(wvf, 'measured wl', 'mm') ...
        %    / radiansPerPixel;
        wvf.PUPILFUNCTION_STALE = true;

    case {'psfsamplespacing','psfdx'}
        % wvfSet(wvf,'psf sample spacing',valMM)
        %
        % This is documented in t_wvfOverview.mlx.

        psf_spacingMM = val;
        lambdaMM = wvfGet(wvf,'wave','mm');
        focallengthMM = wvfGet(wvf,'focal length','mm');
        nPixels = wvfGet(wvf,'npixels');

        if numel(lambdaMM) > 1, warning('Using wave %.1f nm',lambdaMM(1)*1e6); end
        % compute the pupil sample spacing that matches this PSF sample
        % spacing in the image plane.
        pupil_spacingMM = lambdaMM(1) * focallengthMM / (psf_spacingMM * nPixels);

        % This implements the change in PSF dx
        wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);
       
    case {'focallength','flength'}
        % Default unit for focal length is millimeters
        %
        %   wvf = wvfSet(wvf,'focal length',17e-3,'m');
        %
        % When we convert the psf in angle units to spatial samples we may
        % need to know the focal length.  This is necessary, for example
        % to specific deg per mm on the film (imaging) surface. We use this
        % wvf parameter to convert from angle (the natural calculation
        % space of the phase aberrations) to spatial samples.
        
        unit = 'mm';
        if ~isempty(varargin), unit = varargin{1}; end

        % Convert units to microns, per below
        val = (val/ieUnitScaleFactor(unit))*1e+6;

        % Not sure whether tand(1) or 2*tand(0.5)
        umPerDeg = 2*tand(0.5)*val;
        wvf = wvfSet(wvf,'um per degree',umPerDeg);
        wvf.PUPILFUNCTION_STALE = true;

        %% Calculation parameters
        % These parameters are used for the specific calculations with this,
        % interpolating the measured values that are stored above.
    case { 'calcpupildiameter', 'calculatedpupildiameter', ...
            'calcpupilsize','calculatedpupil'}
        % Pupil diameter in mm - must be smaller than measurements
        if (val-wvf.measpupilMM > 1e-6)
            warning(['Pupil diameter used for calculation is expected to be '...
                'smaller than measured diameter.']);
        end
        wvf.calcpupilMM = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'calcopticalaxis'}
        % Specify observer accommodation at calculation time
        if (val ~= wvfGet(wvf, 'measuredopticalaxis'))
            error(['We do not currently know how to deal with values '...
                'that differ from measurement time']);
        end
        wvf.calcOpticalAxisDegrees = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'calcobserveraccommodation'}
        % Specify observer accommodation at calculation time
        %
        % If we ever decide to use this, it should be done when we compute
        % the pupil function.  Currently we throw an error if it differs
        % from the specified observer accommodation at measurement time.
        % Also need to understand how this should be integrated with the
        % focus correction parameters.
        wvf.calcObserverAccommodationDiopters = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'calcobserverfocuscorrection', 'defocusdiopters'}
        % Specify optical correction added to observer focus at the
        % calculation time
        error('This value is no longer used, so setting it will not lead to good things.')
        % wvf.calcObserverFocusCorrectionDiopters = val;
        % wvf.PUPILFUNCTION_STALE = true;

    case {'calcwave', 'calcwavelengths', 'wavelengths', 'wavelength', ...
            'wls', 'wave'}
        % Normally just a vector of wavelengths in nm but allow SToWls case
        % for PTB users.
        %
        % wvfSet(wvfP, 'wave', 400:10:700)  OR
        % wvfSet(wvfP, 'wave', [400 10 31])
        %
        % Note that it isn't sufficient just to call SToWls (which will
        % pass a vector of evenly spaced wls through, because we might want
        % to allow unevenly spaced wls.)
        if size(val, 2) == 3 && size(val, 1) == 1 % SToWls case
            % Row vector with 3 entries.
            % Noticed a bug when wave is 500,600,700 it is
            % mis-interpreted.  Need to fix (BW).
            wls = SToWls(val);
            wvf.wls = MakeItWls(wls);
        else  % A column vector case
            wvf.wls = val(:);
        end
        wvf.PUPILFUNCTION_STALE = true;

    case {'calcconepsfinfo'}
        % Structure that has cone sensitivities and a weighting function
        % for aggregating the polychromatic psf down to cone psfs.
        wvf.conePsfInfo = val;

    case {'umperdegree'}
        % Factor used to convert between um on the retina and degrees of
        % visual angle. It might be that we don't need to set the stale
        % flag when we change this, but doing so is safe for sure.
        %
        % We need the ability to manage focal length, too.  So, we added
        % the duplicative parameter (ugh) but change them in tandem.  Bad,
        % but there it is for now.  My preference would be just use focal
        % length.
        wvf.umPerDegree = val;

        % Keep focal length consistent.
        % tand(1) = opp/adj (right triangle, point at the lens)
        %   adj = focal length, stored in mm
        %   opp = umPerDegree
        % wvf.focallength = (val*1e-6/tand(1));  % also, convert um to m
        wvf.PUPILFUNCTION_STALE = true;
    
        %{
        case {'fnumber'}
             % We do not allow setting the fnumber in the wavefront
             % There are ways to do this in oiSet and opticsSet()
             %
             % We adjust the fnumber by changing the pupil diameter, leaving the
             % focal length unchanged. This differs from ISETCam, which has the
             % fnumber and focal length as parameters and infers the pupil
             % diameter.
             disp('Setting fnumber by adjusting pupil diameter.  Focal length is fixed.')
             fLength = wvfGet(wvf,'focal length','mm');
             wvf     = wvfSet(wvf,'calc pupil diameter',fLength/val,'mm');
        %}

    case {'lcamethod'}
        % 'none', 'human', function handle for a custom LCA
        wvf.lcaMethod = val;

    case {'sceparams', 'stilescrawford'}
        % Stiles-Crawford Effect structure.
        %
        % Angular dependence of the cone absorptions are calculated by the
        % parameters in this structure. Values from the structure are
        % retrieved and set using sceGet/Set
        %
        % The structure of sce is defined in sceCreate
        wvf.sceParams = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'measuredpupilsize', 'measuredpupil', 'measuredpupilmm', ...
            'measuredpupildiameter','pupildiameter'}
        % TO CHECK:
        % Added pupildiameter here (BW).
        % Removed pure 'pupilsize' because it was ambiguous.  And no
        % complaints after a couple of years.
        %         if isequal(parm,'pupilsize')
        %             disp('Use (measured) pupil diameter, not size');
        %         end
        % Pupil diameter in mm over for which wavefront expansion is valid
        wvf.measpupilMM = val;

    case {'measuredwave', 'measuredwl', 'measuredwavelength'}
        % Measurement wavelength (nm)
        % There should be only one wavelength for the measurement.
        wvf.measWlNM = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'measuredopticalaxis', 'measuredopticalaxisdeg'}
        % Measurement optical axis, degrees eccentric from fovea
        wvf.measOpticalAxisDeg = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'measuredobserveraccommodation', ...
            'measuredobserveraccommodationdiopters'}
        % Observer accommodation, in diopters relative to the relaxed state
        % of the eye
        wvf.measObserverAcommodationDiopters = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'measuredobserverfocuscorrection', ...
            'measuredobserverfocuscorrectiondiopters'}
        % Focus correction added optically for observer at the measurement
        % time (diopters)
        error('This value is no longer used, so setting it will not lead to good things.')
        % Also, there is a typo below since this case is setting the wrong
        % field.  Not fixing because that field is going way.
        wvf.measObserverAcommodationDiopters = val;
        wvf.PUPILFUNCTION_STALE = true;

    case {'flippsfupsidedown'}
        wvf.flipPSFUpsideDown = val;

    case {'rotatepsf90degs'}
        wvf.rotatePSF90degs = val;

    otherwise
        error('Unknown parameter %s\n', parm);

end

end
