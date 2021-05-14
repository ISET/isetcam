function wvf = wvfSet(wvf,parm,val,varargin)
% Set wavefront parameters
%
% Syntax
%   wvf = wvfSet(wvf,parm,val,varargin)
%
% Description
%   Wavefront properties are stored as parameters. The wvf toolbox in ISET
%   is slimmed down from the full one in isetbio. Also the strong
%   dependency on human is removed.  If you are working with the human
%   optics, use ISETBIO.
%
%   Parameter names can be written with spaces and upper/lower case.  The
%   strings are converted to lower case and all the spaces are removed by
%   this routine.
%
%   The basic parameters are pupil diameter, wavelengths, and Zernike
%   coefficients.  There are other parameters for spatial sampling.
%
% Examples:
%   wvf = wvfSet(wvf,'name','test wvf');
%   wvf = wvfSet(wvf,'zcoeffs',z);
%   wvf = wvfSet(wvf,'z pupil diameter',z);   % Pupil size for the z coeff rep
%   wvf = wvfSet(wvf,'pupil diameter',z);     % For this calculation
%
%
% Inputs:
%   wvf   - A wavefront structure
%   param - Parameter string
%   val   - Value to set the parameter string
%
% Parameters
%
%  Bookkeeping
%   'name' - Name of this object
%   'type' - Type of this object, should always be 'wvf'
%
%  Calculations
%    'zcoeffs' - Zernike coefficients, OSA standard numbering/coords
%         You can use an Zernike parameter name to specify a particular
%         coefficient, such as
%
%               wvfSet(wvf,'zcoeffs',2,'defocus');
%               wvfSet(wvf,'zcoeffs',0.5,'oblique_astigmatism');
%
%    Use "help wvfOSAIndexToName" to see the names.  The OSA indices start
%    with 0 while Matlab indexes from 1.  So if you send in the an OSA
%    index of val, we return zcoeff(val+1)
%
%    'pupil diameter' - Pupil size for calculation (mm,*)
%
%  Spatial sampling parameters
%    'sample interval domain' -
%       Which domain has sample interval held constant with
%       wavelength ('psf', 'pupil')
%    'number spatial samples' -
%        Number of spatial samples (pixel) for pupil function and psf
%    'ref pupil plane size' -
%        Size of sampled pupil plane at measurement wavelength (mm)
%    'ref pupil plane sample interval' -
%        Pixel sample interval in pupil plane at measurement wavelength (mm)
%    'ref psf sample interval' -
%        Sampling interval for psf at measurment wavelength (arcminute/pixel)
%
% History
%  Based on (DHB/BW) (c) Wavefront Toolbox Team 2011, 2012 Vastly reduced
%  and simplified by Imageval for basic wavefront calculations.
%
% See also:
%   wvfCreate, wvfGet, wvfComputePupilFunction, wvfComputePSF, psf2zcoeff

%% Arg checks and parse.

% The switch on what we're setting is broken out into several pieces
% below to allow use of cells, and so that autoindent does something
% reasonable with our block comment style.
if ~exist('parm','var') || isempty(parm), error('Parameter must be defined'); end
if ~exist('val','var'), error('val must be defined'); end

parm = ieParamFormat(parm);

%% Set the parameters in a big case statement
switch parm
    
    %% Bookkeeping
    case 'name'
        % This specific object's name
        wvf.name = val;
        
    case 'type'
        % Type should always be 'wvf'
        if (~strcmp(val,'wvf'))
            error('Can only set type of wvf structure to ''wvf''');
        end
        wvf.type = val;
        
        %% The measured values
        % These are the values that describe the assumed measurement
        % conditions for the Zernike coefficients.
        %
        % When we perform a calculation, we may adjust some of the
        % parameters (say the wavelength) and derive the prediction
        % correcting for these background assumptions and the calculation.
        % For example, the wavelength at calculation might differ from the
        % measured wavelength.  We add a chromatic abberration correction.
        % Or the pupil size of the calculation might differ, and we account
        % for that.
        %
        % The differences are accounted for in the
        % wvfComputePupilFunction, mainly.  It is possible that there are
        % other functions or scripts that compare the data as well.
        %
        %{
    case {'umperdegree'}
        % Applies to human calculations.
        % This is the factor used to convert between um on the retina and degrees of
        % visual angle. This is typically 300, but we have it as a
        % parameter for historical reasons.  They value does matter.
        wvf.umPerDegree = val;
        %}
        %% Calculation parameters
        %
        %  Zernike coefficients and related
        
    case {'zcoeffs', 'zcoeff','zcoef'}
        % wvfSet(wvf,'zcoeffs',val, jIndex);
        % wvfSet(wvf,'zcoeffs',2,'defocus');
        %  or equivalent: wvfSet(wvf,'zcoeffs',2,4);
        %
        % jIndex is optional, and can be a vector of j values
        % or a string array of coefficient names that are converted to
        % indices using wvfOSAIndexToVectorIndex.
        %
        % These specify the measured (or assumed) wavefront aberrations in
        % terms of a Zernike polynomial expansion.  Exanding these gives us
        % the wavefront abberations in microns over the measured pupil.
        %
        % The coefficients represent measurements that were made (or
        % assumed to be made) at a particular optical axis, state of
        % accommodation of the observer, wavelength, and over a particular
        % pupil size diameter.  The wvf structure contains all of this
        % information.
        %
        % Zernike coeffs 0,1,2 (piston, verticle tilt, horizontal tilt) are
        % typically 0 since they are either constant (piston) or only
        % change the point spread location, not quality, as measured in
        % wavefront aberrations.
        %
        % We use the "j" single-index scheme of OSA standards
        %
        % Note that j indices start at 0, and that is the convention followed
        % here.  We add 1 in the routine to be compliant with Matlab
        % indexing.
        %
        % The length of jIndex must match that of val. The assignment is
        %   zcoeffs(jIndices) = val;
        %
        % When the stored vector of zcoeffs is shorter than required by
        % jIndex, the vector is padded with zeros prior to the insertion of
        % the passed coefficients.
        if (isempty(varargin))
            % User sent in a vector of coefficients in val
            wvf.zcoeffs = val;
        else
            % The arguments in jIndex are either numbers or strings.  If
            % strings, the strings are interpreted to be the jIndices in
            % this routine.  Use help on this name to see the relationship
            % between integers and names
            idx = wvfOSAIndexToVectorIndex(varargin{1});
            
            % Check that zcoeffs has enough slots, and if not expand it.
            % Remember that Matlab indexes from 1 but OSA from 0.
            maxidx = max(idx);
            if (maxidx > length(wvf.zcoeffs))
                wvf.zcoeffs(length(wvf.zcoeffs)+1:maxidx) = 0;
            end
            wvf.zcoeffs(idx) = val;
        end
        
    case 'zpupildiameter'
        % Pupil diameter for the zcoeff measurements (millimeters)
        wvf.zpupilDiameter = val;
    case 'zwavelength'
        % Wavelength for the zcoeff measurements
        wvf.zwls = val;
        % These parameters are used for the specific calculations with this,
        % interpolating the measured values that are stored above.
    case {'pupildiameter','pupilsize'}
        % This value is currently mm.  We should change to meters and
        % account for that everywhere, sigh.
        disp('Pupil diameter in mm.  This will change to meters some day');
        wvf.pupilDiameter = val;
        
    case {'focallength','flength'}
        % wvf = wvfSet(wvf,'focal length',17e-3);
        %
        % When we convert the psf in angle units to spatial samples we may
        % need to know the focal length.  This is necessary, for example,
        % to specific deg per mm on the film (imaging) surface. We use this
        % wvf parameter to convert from angle (the natural calculation
        % space of the phase aberrations) to spatial samples.
        wvf.focalLength = val;
        
    case {'wave','wavelength','wavelengths'}
        % A vector of wavelengths in nm, forced to be column vector.
        %
        % I removed the SToWls case for PTB users.
        %
        % wvfSet(wvfP,'wave',400:10:700)  OR
        % Removed: wvfSet(wvfP,'wave',[400 10 31])
        %
        % Note that it isn't sufficient just to call SToWls
        % (which will pass a vector of evenly spaced wls
        % through, because we might want to allow unevenly
        % spaced wls.)
        %         if size(val,2) == 3 && size(val,1) == 1 % SToWls case
        %             % Row vector with 3 entries.
        %             wls = SToWls(val);
        %             wvf.wls = MakeItWls(wls);
        %         else  % A column vector case
        wvf.wls = val(:);
        %         end
        
        %% Spatial sampling parameters
        %
        % In the end, we calculate using discretized sampling.  Because
        % the pupil function and the psf are related by a fourier transform,
        % it is natural to use the same number of spatial samples for both
        % the pupil function and the corresponding psf.   The parameters
        % here specify the sampling.
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
        % wavelength easily.  So we set the number of number of pixels and
        % size of the sampling in the pupil plane at the measurement
        % wavelength, and then compute/set everything else as needed.
        %
        % Because the sampling in the pupil and psf domains is yoked, its
        % important to choose values that do not produce discretization
        % artifacts in either domain.  We don't have an automated way to do
        % this, but the default numbers here were chosen by experience
        % (well, really by Heidi Hofer's experience) to work well.  Be
        % attentive to this aspect if you decide you want to change them by
        % very much.
        %
        % The other thing that is tricky is that the relation between the
        % sampling in the pupil and psf domains varies with wavelength. So,
        % you can't easily have the sample interval stay constant over
        % wavelength in both the pupil and psf domains.  You have to choose
        % one or the other. We will typically force equal sampling in the
        % psf domain, but we allow specification of which.
    case {'sampleintervaldomain'}
        % Determine what's held constant with calculated wavelength.
        % Choices are 'psf' and 'pupil'
        wvf.constantSampleIntervalDomain = val;
        
    case {'numberspatialsamples','spatialsamples', 'npixels', 'fieldsizepixels'}
        % Number of pixels that both pupil and psf planes are discretized
        % with.
        %
        % This is a stored value.
        wvf.nSpatialSamples = val;
        
    case {'refpupilplanesize', 'refpupilplanesizemm', 'fieldsizemm'}
        % Total size of computed field in pupil plane.  This is for the measurement
        % wavelength.  The value can vary with wavelength, but this one
        % sets the scale for all the other wavelengths.
        %
        % This is a stored value.
        wvf.refSizeOfFieldMM = val;
        
    case {'refpupilplanesampleinterval', 'refpupilplanesampleintervalmm', 'fieldsamplesize','fieldsamplesizemmperpixel'}
        % Pixel sampling interval of sample pupil field.  This is for the measurement
        % wavelength.  The value can vary with wavelength, but this one
        % sets the scale for all the other wavelengths.
        wvf.refSizeOfFieldMM = val*wvf.nSpatialSamples;
        
    case {'refpsfsampleinterval' 'refpsfarcminpersample', 'refpsfarcminperpixel'}
        % Arc minutes per pixel of the sampled psf at the measurement
        % wavelength.
        %
        % When we convert between the pupil function and the PSF,
        % we use the fft.  Thus the size of the image in pixels
        % is the same for the sampled pupil function and the sampled
        % psf.
        %
        % The number of arc minutes per pixel in the sampled PSF is
        % related to the number of mm per pixel for hte pupil function,
        % with the relation depending on the wavelength.  The fundamental
        % formula in the pupil plane is that the pixel sampling interval
        % in cycles/radian is:
        %
        %   pupilPlaneCyclesRadianPerPix = pupilPlaneField/[lambda*npixels]
        %
        % where npixels is the number of linear pixels and lambda is the
        % wavelength. This formula may be found as Eq 10 of Ravikumar et
        % al. (2008), "Calculation of retinal image quality for
        % polychromatic light," JOSA A, 25, 2395-2407, at least if we think
        % their quantity d is the size of the pupil plane field being
        % sampled.
        %
        % If we now remember how units convert when we do the fft, we
        % obtain that the number of radians in the PSF image is the inverse
        % of the sampling interval:
        %
        %   radiansInPsfImage = [lambda*npixels]/pupilPlaneField
        %
        % which then gives us the number of radiansPerPixel in the
        % PSF image as
        %
        %   radiansPerPixel = lambda/pupilPlaneField
        %
        % The formula below implements this, with a conversion from radians
        % to minutes with factor (180*60/3.1416) and converts wavelength to
        % mm from nm with factor (.001*.001)
        %
        % DHB, 5/22/12, based on earler comments that were here.  Someone
        % else might take a look at the paper referenced above and the
        % logic of this comment and check that it all seems right.  Did I
        % think through the fft unit conversion correctly?  And, there must
        % be a more fundamental reference than the paper above, and for
        % which one wouldn't have to guess quite as much about what is
        % meant.
        radiansPerPixel = val/(180*60/3.1416);
        wvf.refSizeOfFieldMM = wvfGet(wvf,'measured wl','mm')/radiansPerPixel;
        
    otherwise
        error('Unknown parameter %s\n',parm);
        
end

end
