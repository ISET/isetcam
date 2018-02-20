function pixel = pixelCreate(pixelType,wave,pixelSizeM)
%Create a pixel data structure
%
%  pixel = pixelCreate(pixelType,[wave],[pixelSizeM])
%
% The pixel structure describes the pixel parameters.  
%
% We initialize the values for simplicity and  the user  sets values from
% data within their own environment.  For example, the photodetector is
% initialized to a spectral QE of 1 at all wavelengths.
%
% At present, we create these default pixel types:
%
%    'aps','default', a 2.8 um active pixel sensor
%    'humanCone'
%    'mouseCone'
%    'ideal'  - 100% fill factor, 1.5 micron, see below for the rest
%
% See also: sensorCreate, pixelSet, pixelGet
%
% Examples
%  pixel = pixelCreate('aps')
%  pixel = pixelCreate('aps',400:1:700)
%  pixel = pixelCreate('human')
%  pixel = pixelCreate('ideal',400:5:700,1e-6);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('pixelType'), pixelType = 'default'; end
if ieNotDefined('wave')
    wave = (400:10:700); 
    wave = wave(:); 
end
if ieNotDefined('pixelSizeM'), pixelSizeM = 2.8e-6; end

pixelType = ieParamFormat(pixelType);
switch lower(pixelType)
    case 'ideal'
        % Create structure with default parameters
        pixel = pixelAPSInit();

        % Set up perfect parameters
        pixel = pixelSet(pixel,'readNoiseVolts',0);
        pixel = pixelSet(pixel,'darkVoltage',0);
        pixel = pixelSet(pixel,'height',pixelSizeM);
        pixel = pixelSet(pixel,'width',pixelSizeM);
        pixel = pixelSet(pixel,'pdwidth',pixelSizeM);
        pixel = pixelSet(pixel,'pdheight',pixelSizeM);
        pixel = pixelPositionPD(pixel,'center');
        pixel = pixelSet(pixel,'darkVoltage',0);
        pixel = pixelSet(pixel,'voltage swing',1e6);
        
    case 'default'
        pixel = pixelAPSInit();
    case 'aps'
        pixel = pixelAPSInit();
    case {'human','humancone'}
        pixel = pixelHuman;
    case 'mouse'
        pixel = pixelMouse;
    otherwise,
        error('Unknown pixelType.');
end

% Initialize with flat photodetector spectral QE
pixel = pixelSet(pixel,'wave',wave);
pixel = pixelSet(pixel,'pd Spectral QE',ones(size(wave)));
% pixel = pixelSet(pixel,'size constant fill factor',pixelSizeM);

return;

%----------------------------------------------
function pixel = pixelAPSInit()
% A typical 2.8 um active pixel sensor
%   

pixel.name = 'aps';
pixel = pixelSet(pixel,'type','pixel');

pixel = pixelSet(pixel,'width',2.8e-6);
pixel = pixelSet(pixel,'height',2.8e-6);
pixel = pixelSet(pixel,'widthGap',0);
pixel = pixelSet(pixel,'heightGap',0);

% Photodetector size is set to 80% fill factor of default.
defaultFillFactor = 0.75;
pdSize = sqrt(pixelGet(pixel,'width')*pixelGet(pixel,'width')*defaultFillFactor);
pixel = pixelSet(pixel,'pdWidth',pdSize);
pixel = pixelSet(pixel,'pdHeight',pdSize);

pixel = pixelPositionPD(pixel,'center');

pixel = pixelSet(pixel,'conversionGain',1.0e-4);    % [V/e-]
pixel = pixelSet(pixel,'voltageSwing',1);           % [V]

% Dark Current density defines how quickly the pixel fills up with
% dark current.  The units are Amps/meter^2.
% In electrons per pixel per second: dkCurDens*pdArea / q  : ((chg/sec)/m2)(m2)(chg/e-)
% In volts per pixel per sec: (dkCurDens*pdArea/q)*conversionGain : ((chg/sec)/m2)(m2)/(chg/e-)(V/e-)
%
% We set the density so that the well-capacity fills up
% from dark current in 10 sec. 
% This means in volts/pix/sec we want
%           0.1 = (dkCurDens*pdArea/q)*conversionGain
% so:     dkCurDens = 0.1*q/(pdArea*conversionGain);     Units are Amps/m^2

% We want the dark voltage to fill up the voltage swing in 10 s
%     So, desired is: darkVoltagePerSec = voltageSwing/10
% In terms of current density, the dark voltage per pixel per sec is:
% darkVoltage = 'conversiongain'*'darkcurrentdensity'*'pdarea'/'q';
% (voltageSwing/10) (q / (convGain*pdArea)) = darkcurrentdensity
  
% V/sec * Chg/e- / (m^2 * V/e-) = (Chg/sec)/m^2 = Amps/M^2
pixel = pixelSet(pixel,'darkVoltage',pixelGet(pixel,'voltageSwing')/1000);

% 1 millivolt against 1 V total swing.  not much
pixel = pixelSet(pixel,'readNoiseVolts',0.001);  % Volts

% Always starts with air and ends with silicon. 
% We assume in between is silicon nitride and oxide 
pixel = pixelSet(pixel,'refractiveindices',[1 2 1.46 3.5]);  %

% These thicknesses makes the pixel 7 microns high.  
% Peter C thinks they are around 9, but Micron is shorter.
pixel = pixelSet(pixel,'layerthickness',[2 5]*10^-6);  % In microns.  Air and material are infinite.

return;

%----------------------------------------------
function pixel = pixelHuman
% A typical human cone properties.
%
% Data source:
%  Wandell's book.  Baylor.  Other people.
% Elaborate here, and make this better.
%
pixel.name = 'humancone';

pixel = pixelSet(pixel,'type','pixel');

% Human cones are 2 microns, roughly, just outside the foveola
pixel = pixelSet(pixel,'width',2e-6);
pixel = pixelSet(pixel,'height',2e-6);
pixel = pixelSet(pixel,'widthGap',0);
pixel = pixelSet(pixel,'heightGap',0);

% We make it 100 percent fill factor
pixel = pixelSet(pixel,'pdWidth',2e-6);
pixel = pixelSet(pixel,'pdHeight',2e-6);
pixel = pixelPositionPD(pixel,'center');

% Not sure what this should really be.  It specifies the dynamic range,
% effectively.
pixel = pixelSet(pixel,'conversionGain',1.0e-5);    % [V/e-]
pixel = pixelSet(pixel,'voltageSwing',1);           % [V]

% Noise properties
pixel = pixelSet(pixel,'darkVoltage',pixelGet(pixel,'voltageSwing')/1000);

% 1 millivolt against 1 V total swing.  not much
pixel = pixelSet(pixel,'readNoiseVolts',0.001);  % Volts

% Always starts with air and ends with silicon.  We assume in between is
% silicon nitride and oxide 
pixel = pixelSet(pixel,'refractiveindices',[1 2 1.46 3.5]);  %

% These thicknesses makes the pixel 5 microns high.
pixel = pixelSet(pixel,'layerthickness',[0.5 4.5]*10^-6);  % In microns

return;

%----------------------------------------------
function pixel = pixelMouse
% A typical mouse cone. 
%
% The mouse has no fovea, this is any retina cone. The cones are
% much sparser than on the human fovea, since there are many rods
% interspaced with cones.
%
% Data source : "The Major Cell Populations of the Mouse Retina", 
% Jeon Strettoi Masland, 1998
%  
% Contributed by Estelle Comment

pixel.name = 'mousecone';
pixel = pixelSet(pixel,'type','pixel');

% Mouse cones are 2 microns, roughly (like human cones).
% Measured on figure 1 in Masland paper.
% But they do not fill the whole space on the retina (rods are there!)
% Fill factor:
% Average cone density on the mouse retina : 12,400 cones/mm2 (Masland paper)
% => 8.0645e-05 mm2/cone = 0.0090mm*0.0090mm /cone
% => fill factor of 0.0494 : not very much!

% pixel size = cone spacing
pixel = pixelSet(pixel,'width',9e-6);
pixel = pixelSet(pixel,'height',9e-6);
pixel = pixelSet(pixel,'widthGap',0);
pixel = pixelSet(pixel,'heightGap',0);

% photodetector size = cone size
pixel = pixelSet(pixel,'pdWidth',2e-6);
pixel = pixelSet(pixel,'pdHeight',2e-6);
pixel = pixelPositionPD(pixel,'center');

% TODO : find appropriate values for this
% Not sure what this should really be.  It specifies the dynamic range,
% effectively.
pixel = pixelSet(pixel,'conversionGain',1.0e-5);    % [V/e-]

% Trying other values, to avoid saturation of cones... -EC
pixel = pixelSet(pixel,'voltageSwing',0.2); % in between value!

% Noise properties
pixel = pixelSet(pixel,'darkVoltage',0); % no dark noise

% 1 millivolt against 1 V total swing.  not much
pixel = pixelSet(pixel,'readNoiseVolts',0); % no read noise

% We need to set the color filter elsewhere.

return;

