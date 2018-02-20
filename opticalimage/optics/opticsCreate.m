function optics = opticsCreate(opticsType,varargin)
% Create an optics structure
%
%   optics = opticsCreate(opticsType,varargin)
%
% The optics structure contains a variety of parameters, such as f-number
% and focal length. 
%
% Optics structures do not contain a spectrum structure.  Rather this is
% stored in the optical image that also holds the optics information.
%
% For diffraction-limited optics, the only parameter that matters really is
% the f-number.  The names of the standard types end up producing a variety
% of sizes that are only loosely connected to the names.
%
%      {'diffraction limited, 'standard (1/4-inch)'} - DEFAULT
%      {'standard (1/3-inch)'}
%      {'standard (1/2-inch)'}
%      {'standard (2/3-inch)'}
%      {'standard (1-inch)'}
%
% There is the general shift invariant formulation that uses
% non-diffraction limited OTF
%
%      {'shift invariant'} - A shift invariant representation based on a
%                            small pillbox PSF
%      
% There is one special case of shift-invariant based on human optics.  This
% creates an optics structure with human OTF data
%
%      {'human'}     - Also shift-invariant, but uses Marimont
%                      and Wandell (Hopkins) method
%
% Example:
%   optics = opticsCreate('standard (1/4-inch)');
%   optics = opticsCreate('standard (1-inch)');
%
%   optics = opticsCreate('human');        % 3mm diameter is default
%   optics = opticsCreate('human',0.002);  % 4 mm diameter
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('opticsType'), opticsType = 'default'; end

opticsType = ieParamFormat(opticsType);

switch lower(opticsType)
    case {'diffractionlimited','default','standard(1/4-inch)','quarterinch'}
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
        % Shift-invariant optics based on an example data set (SI-pillBox).
        % The OTF is represented in terms of fx and fy specified in cycles
        % per millimeter.
        if ~isempty(varargin), oi = varargin{1}; else, oi = oiCreate; end
        optics = siSynthetic('custom',oi,'SI-pillBox',[]);
        optics = opticsSet(optics,'model','shiftInvariant');
        
    case 'human'
        % Pupil radius in meters.  Default is 3 mm
        if ~isempty(varargin), pupilRadius = varargin{1};
        else,                  pupilRadius = 0.0015;    % 3mm diameter default
        end
        % This creates a shift-invariant optics.  The other standard forms
        % are diffraction limited.
        optics = opticsHuman(pupilRadius);
        optics = opticsSet(optics,'model','shiftInvariant');
        optics = opticsSet(optics,'name','human-MW');
        
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

