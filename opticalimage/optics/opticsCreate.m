function [optics, wvfP]  = opticsCreate(opticsType,varargin)
% Create an optics structure
%
%   [optics, wvfP] = opticsCreate(opticsType,varargin)
%
% Description:
%    This function is typically called through oiCreate. The optics
%    structure is attached to the oi and manipulated by oiSet and oiGet.
%
%    The optics structure contains a variety of parameters, such as
%    f-number and focal length. There are two types of optics models:
%    diffraction limited and shift-invariant. See the discussion in
%    opticsGet for more detail.
%
%    Optics structures do not start out with a wavelength spectrum
%    structure. This information is stored in the optical image.
%
%    For diffraction-limited optics, the only parameter that matters
%    really is the f-number.  The names of the standard types end up
%    producing a variety  of sizes that are only loosely connected to
%    the names. 
%
%    Specifying human optics creates a shift-invariant optics structure
%    with human OTF data.
%
%    Human and general shift-invariant models can also be created by
%    specifying wavefront aberrations using Zernike polynomials. There is a
%    collection of wavefront methods to help with this (see wvfCreate,
%    wvf<TAB>). That is the method used here for 'wvf human'.
%
% Inputs
%  opticsType
%      {'diffraction limited, 'standard (1/4-inch)'} - DEFAULT
%      {'standard (1/3-inch)'}
%      {'standard (1/2-inch)'}
%      {'standard (2/3-inch)'}
%      {'standard (1-inch)'}
%
%   There is the general shift invariant formulation that uses
%   non-diffraction limited OTF
%
%      {'shift invariant'} - A shift invariant representation based on a
%                            small pillbox PSF
%
%      {'human mw', 'human'} - Also shift-invariant, but uses Marimont
%                      and Wandell (Hopkins) method
%
%      {'human wvf'}  - Uses Wavefront toolbox and Thibos data. Has
%                        varargin parameters for pupil diameter,
%                        Zernike Coefficients, wavelengths, and
%                        microns per degree.
%
%    varargin   - (Optional) Additional arguments, such as the following
%                 for a wavefront/Thibos human: (in this order)
%        pupilDiameter: Numeric. Diameter of a human pupil in millimeters.
%                       Default 3mm.
%        zCoefs:        The zernike coefficients. Default pulls from
%                       wvfLoadThibosVirtualEyes.
%        wave:          Vector. Wavelengths. Default 400:10:700.
%        umPerDegree:   Retinal parameter, microns per degree. Default 300.
%        customLCA:     A function handle specifying a custom LCA function
%
% Outputs:
%    optics     - Struct. The created optics structure.
%    wvf        - If the wvf human case, the wvf struct is returned
%
% See Also:
%   oiCreate, opticsSet, opticsGet

% Example:
%   optics = opticsCreate('standard (1/4-inch)');
%   optics = opticsCreate('standard (1-inch)');
%
%   optics = opticsCreate('human');        % 3mm diameter is default
%   optics = opticsCreate('human',0.002);  % 4 mm diameter
%
% See also
%

%%
if ieNotDefined('opticsType'), opticsType = 'default'; end

opticsType = ieParamFormat(opticsType);

switch lower(opticsType)
    case {'default','diffractionlimited','standard(1/4-inch)','quarterinch'}
        % These are all diffraction limited methods.
        optics = opticsDefault;

    case {'standard(1/3-inch)','thirdinch'}
        optics = opticsThirdInch;
    case {'standard(1/2-inch)','halfinch'}
        optics = opticsHalfInch;
    case {'standard(2/3-inch)','twothirdinch'}
        optics = opticsTwoThirdInch;
    case {'standard(1-inch)','oneinch'}
        optics = opticsOneInch;

    case 'shiftinvariant'
        % optics = opticsCreate('shift invariant',oi);
        %
        % Shift-invariant optics based on a Gaussian.  (Used to use
        % SI-pillBox).  The OTF is represented in terms of fx and fy
        % specified in cycles per millimeter.

        if ~isempty(varargin), oi = varargin{1}; else, oi = oiCreate; end
        wave = oiGet(oi,'wave');
        if isempty(wave)
            wave = 400:10:700;
            oi = oiSet(oi,'wave',wave);
        end

        % The default is a Gaussian that is wavelength dependent.
        psfType = 'gaussian';  waveSpread = wave/wave(1);
        xyRatio = ones(1,length(wave));
        optics = siSynthetic(psfType,oi,waveSpread,xyRatio);
        % psfMovie(optics,ieNewGraphWin);

        % Used to create a pillbox like this
        % optics = siSynthetic('custom',oi,'SI-pillBox',[]);

    case {'human','humanmw'}
        % Pupil radius in meters.  Default is 3 mm
        %
        % Significant change on July 26, 2023.  Replaced constant
        % lens transmittance (which was wrong) with human lens model.
        if ~isempty(varargin), pupilRadius = varargin{1};
        else,                  pupilRadius = 0.0015;    % 3mm diameter default
        end
        % This creates a shift-invariant optics.  The other standard forms
        % are diffraction limited.
        optics = opticsHuman(pupilRadius);
        optics = opticsSet(optics,'model','shiftInvariant');
        optics = opticsSet(optics,'name','human-MW');

        % Human, so add default human Lens
        optics.lens = Lens;

    case {'wvfhuman','humanwvf'}
        % opticsCreate('wvf human',pupilDiameterMM, zCoefs, wave, ...
        %               umPerDegree, customLCA)
        %
        % Default optics based on mean Zernike polynomials estimated
        % by Thibos, for 3 mm pupil. Chromatic aberration is included.
        %
        % If you pass a different pupil diameter, the routine will read in
        % Thibos measurements that for a pupil larger than that, and use
        % those to compute the pupil function for your passed diameter.
        % 
        % This is not representative of any particular observer, because
        % the mean Zernike polynomials do not capture the phase
        % information, and indeed positive and negative coefficients across
        % observers will tend to cancel. So as you get serious about a modeling
        % project, you will likely want to control this more directly.
        %
        % If you pass zCoefs, the routine assumes that they correspond to
        % the same measurement diameter as the requested pupil size.  This
        % is not necessarily the case for some use cases, so proceed with
        % caution.
        
         % Defaults
        pupilDiameterMM = 3;      % Default pupil diameter
        wave            = 400:10:700;
        wave            = wave(:);
        umPerDegree     = 300;    % This corresponds to focal length 17.1mm
        customLCA       = [];

        % Set pupil size
        if (~isempty(varargin) && ~isempty(varargin{1}))
            pupilDiameterMM = varargin{1};
            if (pupilDiameterMM > 7.5)
                error('Thibos measurements are limited to pupil diameters below 7.5 mm');
            end
        end

        % Find Thibos pupil that is larger than requested.  We use
        % that as the measured pupil diameter.
        thibosPupilDiametersMM = [3 4.5 6 7.5];
        for dd = 1:length(thibosPupilDiametersMM)
            if (pupilDiameterMM <= thibosPupilDiametersMM(dd))
                measPupilDiameterMM = thibosPupilDiametersMM(dd);
                break;
            end
        end

        % If zCoefs are passed, then the pupilDiameter sent in is used
        % as the measured pupil diameter.
        if (length(varargin) > 1 && ~isempty(varargin{2}))
            zCoefs = varargin{2};

            % If zCoefs are passed, the 'meas pupil diameter' should
            % describe their reference disk.
            measPupilDiameterMM = pupilDiameterMM;
        else
            % Use the Thibos zCoefs
            zCoefs = wvfLoadThibosVirtualEyes(measPupilDiameterMM);
        end

        % Other defaults
        if (length(varargin) > 2 && ~isempty(varargin{3}))
            wave = varargin{3};
            wave = wave(:);
        end
        if (length(varargin) > 3 && ~isempty(varargin{4}))
            % This parameter also sets the focal length.
            umPerDegree = varargin{4};
        end
        if (length(varargin) > 4 && ~isempty(varargin{5}))
            customLCA = varargin{5};
        end

        % Create wavefront parameters. Set both measured and calc
        % pupil size.
        wvfP = wvfCreate('calc wavelengths', wave, 'zcoeffs', zCoefs, ...
            'name', sprintf('human-%d', pupilDiameterMM), ...
            'umPerDegree', umPerDegree, ...
            'customLCA', customLCA);
        wvfP = wvfSet(wvfP, 'measured pupil size', measPupilDiameterMM);
        wvfP = wvfSet(wvfP, 'calc pupil size', pupilDiameterMM);

        % Include human chromatic aberration because this is wvf human        
        wvfP   = wvfCompute(wvfP, 'human lca', true);
        oi     = wvf2oi(wvfP);
        optics = oiGet(oi,'optics');
        optics = opticsSet(optics,'name','humanwvf');

        % Convert from pupil size and focal length to f number and focal
        % length, because that is what we can set. This implies a number of
        % mm per degree, and we back it out the other way here so that it
        % is all consistent.
        % focalLengthMM = (umPerDegree * 1e-3) / (2 * tand(0.5));
        % fLengthMeters = focalLengthMM * 1e-3;
        % pupilRadiusMeters = (pupilDiameterMM / 2) * 1e-3;
        % optics = opticsSet(optics, 'fnumber', fLengthMeters / ...
        %     (2 * pupilRadiusMeters));
        % optics = opticsSet(optics, 'focalLength', fLengthMeters);
        
        % Human, so add default human Lens
        optics.lens = Lens;

        % Store the wavefront parameters
        optics.wvf = wvfP;

    case 'mouse'
        disp('mouse not yet implemented.');
        % Some day might add in a default mouse optics. Here are some
        % guesses about the right parameters:
        %{
        % Pupil radius in meters.
        %   Dilated pupil: 1.009mm = 0.001009m
        %   Contracted pupil: 0.178 mm
        %   (Source: From candelas to photoisomerizations in the mouse eye
        %   by rhodopsin bleaching in situ and the light-rearing dependence
        %   of the major components of the mouse ERG, Pugh, 2004)
        % We use a default value, in between: 0.59 mm.
        %         if ~isempty(varargin)
        %             pupilRadius = varargin{1};
        %             if pupilRadius > 0.001009 || pupilRadius < 0.000178
        %                 warning('Poor pupil size for the  mouse eye.')
        %             end
        %         else
        %             pupilRadius = 0.00059;  % default : 0.59 mm
        %         end
        %         % This creates a shift-invariant optics. The other
        %         % standard forms are diffraction limited.
        %         optics = opticsMouse(pupilRadius);
        %         optics = opticsSet(optics, 'model', 'shiftInvariant');
        %}        

    otherwise
        error('Unknown optics type.');
end

% Default lens transmittance.  Not sure why I chose these wavelengths
optics.transmittance.wave = (370:730)';
optics.transmittance.scale = ones(length(370:730),1);

% Default settings for off axis and pixel vignetting
optics = opticsSet(optics,'offAxisMethod','cos4th');
optics.vignetting =    0;   % Pixel vignetting is off

end

%{
%---------------------------------------
function optics = opticsDiffraction
% Deprecated
% Std. diffraction-limited optics w/ 46 deg. fov & fNumber of 4.
%
% Copied over from ISETBio - this appears to be the same as the quarterinch
% default here.  To check (BW)!  In which case, we should use this
% one, I think.
%
% Syntax:
%   optics = opticsDiffraction
%
% Description:
%    Standard diffraction limited optics with a 46-deg field of view and
%    fnumber of 4. Simple digital camera optics are like this.
%
% Inputs:
%    None.
%
% Outputs:
%    optics - Struct. The optics structure.
%
% Optional key/value pairs:
%    None.
%

optics.type = 'optics';
optics = opticsSet(optics, 'name', 'ideal (small)');
optics = opticsSet(optics, 'model', 'diffraction limited');

% Standard 1/4-inch sensor parameters
sensorDiagonal = 0.004;
FOV = 46;
fLength = inv(tan(FOV / 180 * pi) / 2 / sensorDiagonal) / 2;

optics = opticsSet(optics, 'fnumber', 4);  % focal length / diameter
optics = opticsSet(optics, 'focalLength', fLength);
optics = opticsSet(optics, 'otfMethod', 'dlmtf');

end
%}

%---------------------------------------
function optics = opticsDefault
optics = opticsQuarterInch;
end

%---------------------------------------
function optics = opticsQuarterInch
% Standard optics have a 46-deg field of view degrees

optics.type = 'optics';
optics = opticsSet(optics,'name','standard (1/4-inch)');
optics = opticsSet(optics,'model','diffractionLimited');

% Standard 1/4-inch sensor parameters
sensorDiagonal = 0.004;
FOV = 46;
fLength = inv(tan(FOV/180*pi)/2/sensorDiagonal)/2;

optics = opticsSet(optics,'fnumber',4);  % Ratio of focal length to diameter
optics = opticsSet(optics,'focalLength', fLength);
optics = opticsSet(optics,'otfMethod','dlmtf');

end

%---------------------------------------
function optics = opticsThirdInch
% Standard 1/3-inch sensor has a diagonal of 6 mm
%
optics.type = 'optics';
optics = opticsSet(optics,'name','standard (1/3-inch)');
optics = opticsSet(optics,'model','diffractionLimited');

optics = opticsSet(optics,'fnumber',4);  % Ratio of focal length to diameter

% Standard optics have a 46-deg field of view degrees
FOV = 46;
sensorDiagonal = 0.006;
fLength = inv(tan(FOV/180*pi)/2/sensorDiagonal)/2;

optics = opticsSet(optics,'focalLength', fLength);
optics = opticsSet(optics,'otfMethod','dlmtf');

end

%---------------------------------------
function optics = opticsHalfInch
%

optics.type = 'optics';
optics = opticsSet(optics,'name','standard (1/2-inch)');
optics = opticsSet(optics,'model','diffractionLimited');

optics = opticsSet(optics,'fnumber',4);  % Ratio of focal length to diameter

% Standard optics have a 46-deg field of view degrees
FOV = 46;
sensorDiagonal = 0.008;
fLength = inv(tan(FOV/180*pi)/2/sensorDiagonal)/2;

% Standard 1/2-inch sensor has a diagonal of 8 mm
optics = opticsSet(optics,'focalLength', fLength);
optics = opticsSet(optics,'otfMethod','dlmtf');

end

%---------------------------------------
function optics = opticsTwoThirdInch
%

optics.type = 'optics';
optics = opticsSet(optics,'name','standard (2/3-inch)');
optics = opticsSet(optics,'model','diffractionLimited');

FOV = 46;
sensorDiagonal = 0.011;
fLength = inv(tan(FOV/180*pi)/2/sensorDiagonal)/2;

optics = opticsSet(optics,'fnumber',4);  % Ratio of focal length to diameter
optics = opticsSet(optics,'focalLength', fLength);
optics = opticsSet(optics,'otfMethod','dlmtf');

end

%---------------------------------------
function optics = opticsOneInch
% Standard 1-inch sensor has a diagonal of 16 mm

optics.type = 'optics';
optics = opticsSet(optics,'name','standard (1-inch)');
optics = opticsSet(optics,'model','diffractionLimited');

FOV = 46;
sensorDiagonal = 0.016;
fLength = inv(tan(FOV/180*pi)/2/sensorDiagonal)/2;

optics = opticsSet(optics,'fnumber',4);  % Ratio of focal length to diameter
optics = opticsSet(optics,'focalLength', fLength);
optics = opticsSet(optics,'otfMethod','dlmtf');

end

%---------------------------------------
function optics = opticsHuman(pupilRadius)
% We use the shift-invariant method for the human and add the OTF
% data to the OTF fields.   We return the units in cyc/mm.  We use 300
% microns/deg as the conversion factor.
% EC - 300um/deg corresponds to a distance of 17mm (human focal length)

% We place fnumber and focal length values that
% are approximate for diffraction-limited in those fields, too.  But they
% are not a good description, just the DL bounds for this type of a system.
%
% The pupilRadius should be specified in meters
%

if ieNotDefined('pupilRadius'), pupilRadius = 0.0015; end
fLength = 0.017;  %Human focal length is 17 mm

optics.type = 'optics';
optics.name = 'human';
optics      = opticsSet(optics,'model','shiftInvariant');

% Ratio of focal length to diameter.
optics = opticsSet(optics,'fnumber',fLength/(2*pupilRadius));
optics = opticsSet(optics,'focalLength', fLength);

optics = opticsSet(optics,'otfMethod','humanOTF');

% Compute the OTF and store it.  We use a default pupil radius, dioptric
% power, and so forth.

dioptricPower = 1/fLength;      % About 60 diopters

% We used to assign the same wave as in the current scene to optics, if the
% wave was not yet assigned.
wave = opticsGet(optics,'wave');

% The human optics are an SI case, and we store the OTF at this point.
[OTF2D, frequencySupport] = humanOTF(pupilRadius, dioptricPower, [], wave);
optics = opticsSet(optics,'otfData',OTF2D);

% Support is returned in cyc/deg.  At the human retina, 1 deg is about 300
% microns, so there are about 3 cyc/mm.  To convert from cyc/deg to cyc/mm
% we divide by 0.3. That is:
%  (cyc/deg * (1/mm/deg)) cyc/mm.  1/mm/deg = 1/.3
frequencySupport = frequencySupport * (1/0.3);  % Convert to cyc/mm

fx     = frequencySupport(1,:,1);
fy     = frequencySupport(:,1,2);
optics = opticsSet(optics,'otffx',fx(:)');
optics = opticsSet(optics,'otffy',fy(:)');

optics = opticsSet(optics,'otfWave',wave);

% figure(1); mesh(frequencySupport(:,:,1),frequencySupport(:,:,2),OTF2D(:,:,20));
% mesh(abs(otf2psf(OTF2D(:,:,15))))
%

end

