function optics = opticsSet(optics,parm,val,varargin)
% Set optics structure parameters
%
%   optics = opticsSet(optics,parm,val,varargin)
%
% The optics structure contains the basic optics parameters used to control
% image formation. The parameters define parameters used in the
% diffraction-limited, shift-invariant, or ray trace optics models.
%
% See oiCompute for further information about these models.
%
% See opticsGet for information about many derived quantities you can
% calculate about the optics model.
%
% The optics structure is normally part of the optical image and can be
% retrieved using
%
%   optics = oiGet(oi,'optics');
%
% For programming convenience, you can set optics parameters using this
% syntax from oiSet
%
%      oi = oiSet(oi,'optics <param>',val), generally
%      oi = oiSet(oi,'optics fnumber',5.6), for an example
%
%Example:spec
%   optics = opticsSet(optics,'fnumber',2.8);
%   optics = opticsSet(optics,'model','diffractionLimited');
%
% To set the aperture you must change either the focal length or the
% f# = fL/aperture, so aperture = fL/f#
%
% Optics parameters that can be set:
%
% Optics model  -
%      {'model'}  -  DiffractionLimited, ShiftInvariant, RayTrace, or
%                    UserSupplied
%
% Diffraction limited optics specifications.
%      {'name'}    - This optics name
%      {'type'}    - Always 'optics'
%
%      {'fnumber'}       - f# is focal length / aperture (dimensionless)
%      {'focallength'}   - Focal distance for image at infinity (meters)
%
% Lens transmittance
%      {'transmittance'} - Wavelength transmittance  ([0,1])
%         {'transmittance wave'}  - Wavelength samples
%         {'transmittance scale'} - Transmittance scale factors
%
% OTF Information for shift-invariant optics model
%      {'otfmethod'}   - diffractionlimited, shiftinvariant, raytrace, {'usersupplied','custom'}, or ...
%      {'otfdata'}     - Used to store custom data.  Row x Col x Wave
%      {'otffx'}       - frequency samples across col of otfdata (cyc/mm)
%      {'otffy'}       - frequency samples down rows of otfdata  (cyc/mm)
%      {'otfwave'}     - otf wavelengths
%
% Relative illumination data
%      {'relillummethod'}-
%      {'off axis method'}  - Set to 'Skip' to turn off or 'cos4th'
%      {'cos4th function'}   - Function for calculating cos4th
%      {'cos4th data'}      - Cached cos4th data
%
% Ray trace optics specifications
%     {'raytrace'}     - The entire ray trace structure
%      {'rtopticsprogram'}     - Optics program used (Zemax or Code V)
%      {'rtlensfile'}          - Lens file name
%      {'rteffectivefnumber'}  - Effective f-number
%      {'rtfnumber'}           - F-number
%      {'rtmagnification'}     - Magnification
%      {'rtreferencewavelength'}  - Lens design reference wavelength
%      {'rtobjectdistance'}       - Lens design object distance
%         % Distance to object plane in mm.  NOTE bad unit!
%      {'rtfieldofview'}          - Maximum horizontal field of view
%         % Maximum field of view for the ray trace calculation (not the
%         % computed image).  This is horizontal field of view.  DB Wants us
%         % to change to diagonal.
%      {'rteffectivefocallength'}  - Effective focal length (units?)
%         % Effective focal length computed by the ray trace program.
%      {'rtpsf'} - PSF structure
%      {'rtpsfdata'}
%         % Data are stored as 4D (row,col,fieldHeight,wavelength) images
%         You can set opticsSet(.,.,fieldHeight,wavelength);
%        {'rtpsfwavelength'}    - Sample wavelengths
%        {'rtpsffieldheight'}   - Sample image field heights
%        {'rtpsfsamplespacing','rtpsfspacing'}  - Spacing of PSF samples
%         % These are stored in mm
%      {'rtrelillum'}  - Relative illumination structure
%        {'rtrifunction'}
%        {'rtriwavelength'}
%        {'rtrifieldheight'}
%      {'rtgeometry'}  - Geometrical distortion function
%      {'rtgeomfunction','rtgeometryfunction','rtdistortionfunction','rtgeomdistortion'}
%         % opticsGet(optics,'rtdistortionfunction',wavelength);
%         % Either return the whole thing or just the one at the called
%         % wavelength, which is specified by an index into the function.
%         % Maybe this should really be wavelength and we look it up.
%      {'rtgeometrywavelength'}
%      {'rtgeometryfieldheight'}
%
% Computational parameters
%      {'rtPSFSpacing'} - Wedge size for PSF calculation (meters)
%
% Copyright ImagEval Consultants, LLC, 2005.


if ~exist('optics','var') || isempty(optics),  error('No optics specified.'); end
if ~exist('parm','var') || isempty(parm),      error('No parameter specified.'); end
if ~exist('val','var'),                        error('No value.'); end

parm = ieParamFormat(parm);
switch parm
    
    case 'name'
        optics.name = val;
    case 'type'
        % Should always be 'optics'
        if ~strcmp(val,'optics'), warning('Non standard optics type setting'); end
        optics.type = val;
        
    case {'model','opticsmodel'}
        % Valid choices are diffractionLimited, shiftInvariant, rayTrace,
        % skip, or userSupplied.  The case and spaces do not matter.
        optics.model = ieParamFormat(val);
        
    case {'fnumber','f#'}
        optics.fNumber = val;
    case {'focallength','flength'}
        optics.focalLength = val;
        
    case {'transmittance','transmittancescale'}
        % opticsSet(optics,'transmittance scale',scaleValues);
        %
        % Default is to set the transmittance to all ones at a high
        % wavelength sampling and then interpolate.  Occasionally people
        % insert a different lens transmittance function.
        
        % The transmittance scale should be [0,1] and match the dimension
        % of the number of wavelengths
        if max(val)>1 || min(val)<0
            error('Transmittance should be in [0,1].')
        elseif length(val) ~= length(optics.transmittance.wave)
            error('Transmittance must match wave dimension');
        end
        
        optics.transmittance.scale = val(:);
        
    case {'transmittancewave'}
        % opticsSet(optics,'transmittance wave',wave)
        oldWave = opticsGet(optics,'transmittance wave');
        oldScale = opticsGet(optics,'transmittance scale');
        
        % Update wavelength and transmittance scale
        optics.transmittance.wave = val(:);
        optics.transmittance.scale = interp1(oldWave,oldScale,val)';
        
        % ---- Relative illumination calculations
    case {'relativeillumination','offaxismethod','cos4thflag'}
        % Flag determining whether you use the cos4th method
        % Bad naming because of history.
        optics.offaxis = val;
    case {'cos4thfunction','cos4thmethod'}
        % We only have cos4th offaxis implemented, and this probably is all
        % we will ever use.
        optics.cos4th.function = val;
    case {'cos4th','cos4thdata','cos4thvalue'}
        % Numerical values.  Should change field to data from value.
        optics.cos4th.value = val;
        
        % ---- OTF information for shift-invariant calculations
    case {'otffunction','otfmethod'}
        % This should probably not be here.
        % We should probably only be using the 'model' option
        % But it is used, so we need to carefully debug
        % Current choices are 'dlmtf' ... - MP, BW
        optics.OTF.function = val;
    case {'otf','otfdata'}
        % Fraction of amplitude transmitted at each frequency and
        % wavelength.
        optics.OTF.OTF = val;
    case {'otffx'}
        % Units are cyc/mm
        %- frequency samples across col of otfdata
        optics.OTF.fx = val;
    case {'otffy'}
        % Units are cyc/mm
        %- frequency samples down rows of otfdata
        optics.OTF.fy = val;
    case {'otfwave','otfwavelength','wave'}
        % - otf wavelengths (nm)
        % Don't we always need to resample the OTF data when we change the
        % wavelength?
        optics.OTF.wave = val;
        
        %---- Ray trace parameters used in non shift-invariant calculations
    case {'raytrace','rt',}
        optics.rayTrace = val;
    case {'rtname'}
        optics.rayTrace.name = val;
        
    case {'opticsprogram','rtopticsprogram'}
        optics.rayTrace.program = val;
    case {'lensfile','rtlensfile'}
        optics.rayTrace.lensFile = val;
        
    case {'rteffectivefnumber','rtefff#'}
        optics.rayTrace.effectiveFNumber = val;
        
    case {'rtfnumber'}
        optics.rayTrace.fNumber = val;
    case {'rtmagnification','rtmag'}
        optics.rayTrace.mag = val;
    case {'rtreferencewavelength','rtrefwave'}
        % Nanometers
        optics.rayTrace.referenceWavelength = val;
    case {'rtobjectdistance','rtobjdist','rtrefobjdist','rtreferenceobjectdistance'}
        % Distance to object plane in (meters, typical is infinite)
        optics.rayTrace.objectDistance = val;
    case {'rtfieldofview','rtfov','rthorizontalfov','rtmaximumfieldofview','rtmaxfov'}
        % Maximum field of view for the ray trace calculation (not the
        % computed image).  This is horizontal field of view.
        % Specified in degrees
        % Dimitry Bakin wants us to change to diagonal.
        optics.rayTrace.maxfov = val;
    case {'rteffectivefocallength','rtefl','rteffectivefl'}
        % Effective focal length computed by the ray trace program.
        optics.rayTrace.effectiveFocalLength = val;
        
    case {'rtpsf'}
        % Structure with psf information
        optics.rayTrace.psf =val;
    case {'rtpsffunction','rtpsfdata'}
        % Data are stored as 4D (row,col,fieldHeight,wavelength) images
        % field height  units:  meters
        % wavelength units:     nanometers
        % s = opticsGet(optics,'rtPSFData',1e-3,450); mesh(s)
        % s = opticsGet(optics,'rtPSFData',0,450); mesh(s)
        % s = opticsGet(optics,'rtPSFData',1e-3,550); mesh(s)
        % s = opticsGet(optics,'rtPSFData',0,550); mesh(s)
        if checkfields(optics,'rayTrace','psf','function'),
            if ~isempty(varargin)
                % Return the psf at a particular field height and wavelength
                % psf = opticsGet(optics,'rtpsfdata',fieldHeight,wavelength);
                fhIdx   = ieFieldHeight2Index(opticsGet(optics,'rtPSFfieldHeight'),varargin{1});
                waveIdx = ieWave2Index(opticsGet(optics,'rtpsfwavelength'),varargin{2});
                optics.rayTrace.psf.function(:,:,fhIdx,waveIdx) = val;
            else
                % Set the entire psf data matrix
                % psfFunction = opticsGet(optics,'rtpsfdata');
                optics.rayTrace.psf.function = val;
            end
        end
        
    case {'rtpsfwavelength'}
        % PSF wavelengths (nanometers)
        optics.rayTrace.psf.wavelength = val;
        
        % What are the spatial units by default?
    case {'rtpsffieldheight'}
        % Stored in millimeters. Typical value is 0.1 millimeter
        optics.rayTrace.psf.fieldHeight = val;
    case {'rtpsfsamplespacing','rtpsfspacing'}
        % Stored in millimeters. Typical value is .25 microns (0.00025)
        optics.rayTrace.psf.sampleSpacing = val;
    case {'rtrelillum'}
        % Relative units
        optics.rayTrace.relIllum = val;
    case {'rtrifunction','rtrelativeilluminationfunction','rtrelillumfunction'}
        optics.rayTrace.relIllum.function = val;
    case {'rtriwavelength','rtrelativeilluminationwavelength'}
        optics.rayTrace.relIllum.wavelength = val;
        
    case {'rtrifieldheight','rtrelativeilluminationfieldheight'}
        % Stored in millimeters. Typical value 0.1
        optics.rayTrace.relIllum.fieldHeight = val;
    case {'rtgeometry'}
        % Structure
        optics.rayTrace.geometry = val;
    case {'rtgeomfunction','rtgeometryfunction','rtdistortionfunction','rtgeomdistortion'}
        % Matrix storing field height at several wavelength values
        if isempty(varargin), optics.rayTrace.geometry.function = val;
        else
            idx = ieWave2Index(opticsGet(optics,'rtGeomWavelength'),varargin{1});
            optics.rayTrace.geometry.function(:,idx) = val;
        end
    case {'rtgeomwavelength','rtgeometrywavelength'}
        % Vector storing wavelengths of geometric functions
        optics.rayTrace.geometry.wavelength = val;
    case {'rtgeomfieldheight','rtgeometryfieldheight'}
        % These are stored in millimeters.
        optics.rayTrace.geometry.fieldHeight = val;
    case {'rtcomputespacing'}
        % Doesn't seem to exist any more
        optics.rayTrace.computation.psfSpacing = val;
    otherwise
        error('Unknown parameter')
end

return;

